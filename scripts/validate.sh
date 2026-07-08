#!/usr/bin/env bash
# validate.sh — Validate that a skill directory has the required structure.
# Usage: ./scripts/validate.sh skills/my-skill

set -euo pipefail

SKILL_DIR="${1:?Usage: validate.sh <skill-directory>}"

errors=0

check() {
  if [ ! -f "$1" ]; then
    echo "MISSING: $1"
    errors=$((errors + 1))
  else
    echo "    OK: $1"
  fi
}

echo "Validating skill at: $SKILL_DIR"
echo "---"

SKILL_NAME=$(basename "$SKILL_DIR")
check "$SKILL_DIR/commands/$SKILL_NAME.md"
check "$SKILL_DIR/metadata.json"
check "$SKILL_DIR/README.md"
check "$SKILL_DIR/.claude-plugin/plugin.json"

# Check commands file has YAML frontmatter with name and description.
# Fields are checked inside the frontmatter block only (between the first
# two `---` lines), not anywhere in the file body. Additional frontmatter
# fields (model, effort, allowed-tools, argument-hint, ...) are permitted.
COMMANDS_FILE="$SKILL_DIR/commands/$SKILL_NAME.md"
if [ -f "$COMMANDS_FILE" ]; then
  if ! head -1 "$COMMANDS_FILE" | grep -q '^---$'; then
    echo "MISSING: YAML frontmatter (---) at top of commands/$SKILL_NAME.md"
    errors=$((errors + 1))
  else
    # Extract the frontmatter block: lines after the opening --- up to the
    # closing ---.
    frontmatter=$(awk 'NR==1{next} /^---$/{exit} {print}' "$COMMANDS_FILE")
    if ! echo "$frontmatter" | grep -q '^name:'; then
      echo "MISSING FIELD in commands/$SKILL_NAME.md frontmatter: name"
      errors=$((errors + 1))
    else
      fm_name=$(echo "$frontmatter" | grep '^name:' | head -1 | sed 's/^name:[[:space:]]*//; s/[[:space:]]*$//')
      if [ "$fm_name" != "$SKILL_NAME" ]; then
        echo "MISMATCH: frontmatter name '$fm_name' != skill directory name '$SKILL_NAME'"
        errors=$((errors + 1))
      fi
    fi
    if ! echo "$frontmatter" | grep -q '^description:'; then
      echo "MISSING FIELD in commands/$SKILL_NAME.md frontmatter: description"
      errors=$((errors + 1))
    fi
  fi
fi

# Validate metadata.json has required fields and that commands[] includes
# the slash command matching the command file (/<skill-dir-name>).
if [ -f "$SKILL_DIR/metadata.json" ]; then
  problems=$(python3 - "$SKILL_DIR/metadata.json" "$SKILL_NAME" <<'PYEOF'
import json, sys
required = ['name', 'version', 'description', 'author', 'tags', 'commands']
skill_name = sys.argv[2]
try:
    d = json.load(open(sys.argv[1]))
    for f in required:
        if f not in d:
            print(f"MISSING FIELD in metadata.json: {f}")
    if d.get('name') and d['name'] != skill_name:
        print(f"MISMATCH: metadata.json name '{d['name']}' != skill directory name '{skill_name}'")
    commands = d.get('commands', [])
    if commands and f"/{skill_name}" not in commands:
        print(f"MISMATCH: metadata.json commands {commands} does not include '/{skill_name}' (commands/{skill_name}.md)")
except Exception as e:
    print(f"PARSE_ERROR in metadata.json: {e}")
PYEOF
)
  if [ -n "$problems" ]; then
    while IFS= read -r problem; do
      echo "$problem"
      errors=$((errors + 1))
    done <<< "$problems"
  fi
fi

echo "---"
if [ "$errors" -gt 0 ]; then
  echo "FAILED: $errors error(s) found."
  exit 1
else
  echo "PASSED: Skill structure is valid."
fi
