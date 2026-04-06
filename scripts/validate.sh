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

# Check commands file has YAML frontmatter with name and description
COMMANDS_FILE="$SKILL_DIR/commands/$SKILL_NAME.md"
if [ -f "$COMMANDS_FILE" ]; then
  if ! head -1 "$COMMANDS_FILE" | grep -q '^---$'; then
    echo "MISSING: YAML frontmatter (---) at top of commands/$SKILL_NAME.md"
    errors=$((errors + 1))
  else
    if ! grep -q '^name:' "$COMMANDS_FILE"; then
      echo "MISSING FIELD in commands/$SKILL_NAME.md frontmatter: name"
      errors=$((errors + 1))
    fi
    if ! grep -q '^description:' "$COMMANDS_FILE"; then
      echo "MISSING FIELD in commands/$SKILL_NAME.md frontmatter: description"
      errors=$((errors + 1))
    fi
  fi
fi

# Validate metadata.json has required fields
if [ -f "$SKILL_DIR/metadata.json" ]; then
  missing=$(python3 - "$SKILL_DIR/metadata.json" <<'PYEOF'
import json, sys
required = ['name', 'version', 'description', 'author', 'tags']
try:
    d = json.load(open(sys.argv[1]))
    missing = [f for f in required if f not in d]
    if missing:
        for f in missing:
            print(f)
except Exception as e:
    print(f"PARSE_ERROR: {e}")
PYEOF
)
  if [ -n "$missing" ]; then
    while IFS= read -r field; do
      echo "MISSING FIELD in metadata.json: $field"
      errors=$((errors + 1))
    done <<< "$missing"
  fi
fi

echo "---"
if [ "$errors" -gt 0 ]; then
  echo "FAILED: $errors error(s) found."
  exit 1
else
  echo "PASSED: Skill structure is valid."
fi
