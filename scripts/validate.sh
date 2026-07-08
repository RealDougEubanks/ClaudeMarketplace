#!/usr/bin/env bash
# validate.sh — Validate that a skill plugin directory has the required structure.
# Usage: ./scripts/validate.sh skills/my-skill
#
# Layouts (see docs/decisions/0001-migrate-to-skill-md-layout.md):
#   Single-skill plugin (the default):
#     skills/<name>/SKILL.md            ← skill content, frontmatter name == <name>
#     skills/<name>/metadata.json
#     skills/<name>/README.md
#     skills/<name>/.claude-plugin/plugin.json
#   Multi-skill plugin (e.g. agent-based-development):
#     skills/<name>/skills/<sub>/SKILL.md   ← one per skill, frontmatter name == <sub>
#     (metadata.json / README.md / plugin.json at plugin root as above)
#
# The legacy commands/ directory is no longer valid; its presence is an error.

set -euo pipefail

SKILL_DIR="${1:?Usage: validate.sh <skill-directory>}"
# Normalize: strip trailing slash
SKILL_DIR="${SKILL_DIR%/}"

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

if [ ! -d "$SKILL_DIR" ]; then
  echo "MISSING: $SKILL_DIR (not a directory)"
  echo "---"
  echo "FAILED: 1 error(s) found."
  exit 1
fi

# Migration completeness: the legacy commands/ layout must be gone.
if [ -d "$SKILL_DIR/commands" ]; then
  echo "ERROR: legacy commands/ directory present — migrate to SKILL.md (see ADR 0001)"
  errors=$((errors + 1))
fi

# Discover SKILL.md files for both layouts.
ROOT_SKILL="$SKILL_DIR/SKILL.md"
nested_skills=()
if [ -d "$SKILL_DIR/skills" ]; then
  while IFS= read -r f; do
    nested_skills+=("$f")
  done < <(find "$SKILL_DIR/skills" -mindepth 2 -maxdepth 2 -name 'SKILL.md' -type f | sort)
fi

if [ -f "$ROOT_SKILL" ] && [ ${#nested_skills[@]} -gt 0 ]; then
  echo "ERROR: both root SKILL.md and skills/*/SKILL.md present — pick one layout"
  errors=$((errors + 1))
fi

if [ ! -f "$ROOT_SKILL" ] && [ ${#nested_skills[@]} -eq 0 ]; then
  echo "MISSING: $SKILL_DIR/SKILL.md (or skills/*/SKILL.md for a multi-skill plugin)"
  errors=$((errors + 1))
fi

# validate_frontmatter <skill-md-file> <expected-name>
validate_frontmatter() {
  local file="$1"
  local expected="$2"
  if ! head -1 "$file" | grep -q '^---$'; then
    echo "MISSING: YAML frontmatter (---) at top of ${file#"$SKILL_DIR"/}"
    errors=$((errors + 1))
    return
  fi
  # Extract the frontmatter block: lines after the opening --- up to the
  # closing ---. Fields are checked inside the block only. Additional
  # frontmatter fields (model, effort, allowed-tools, argument-hint,
  # disable-model-invocation, paths, ...) are permitted.
  local frontmatter fm_name
  frontmatter=$(awk 'NR==1{next} /^---$/{exit} {print}' "$file")
  if ! echo "$frontmatter" | grep -q '^name:'; then
    echo "MISSING FIELD in ${file#"$SKILL_DIR"/} frontmatter: name"
    errors=$((errors + 1))
  else
    fm_name=$(echo "$frontmatter" | grep '^name:' | head -1 | sed 's/^name:[[:space:]]*//; s/[[:space:]]*$//')
    if [ "$fm_name" != "$expected" ]; then
      echo "MISMATCH: frontmatter name '$fm_name' != expected skill name '$expected' (${file#"$SKILL_DIR"/})"
      errors=$((errors + 1))
    fi
  fi
  if ! echo "$frontmatter" | grep -q '^description:'; then
    echo "MISSING FIELD in ${file#"$SKILL_DIR"/} frontmatter: description"
    errors=$((errors + 1))
  fi
}

if [ -f "$ROOT_SKILL" ]; then
  check "$ROOT_SKILL"
  validate_frontmatter "$ROOT_SKILL" "$SKILL_NAME"
fi
for nested in ${nested_skills[@]+"${nested_skills[@]}"}; do
  check "$nested"
  validate_frontmatter "$nested" "$(basename "$(dirname "$nested")")"
done

check "$SKILL_DIR/metadata.json"
check "$SKILL_DIR/README.md"
check "$SKILL_DIR/.claude-plugin/plugin.json"

# Validate metadata.json has required fields and that commands[] documents
# the plugin's skills: /<plugin-name> for a root SKILL.md, /<sub-skill-name>
# for each nested skills/<sub>/SKILL.md.
if [ -f "$SKILL_DIR/metadata.json" ]; then
  expected_cmds="/$SKILL_NAME"
  if [ ${#nested_skills[@]} -gt 0 ]; then
    expected_cmds=""
    for nested in "${nested_skills[@]}"; do
      expected_cmds="$expected_cmds /$(basename "$(dirname "$nested")")"
    done
    expected_cmds="${expected_cmds# }"
  fi
  problems=$(python3 - "$SKILL_DIR/metadata.json" "$SKILL_NAME" "$expected_cmds" <<'PYEOF'
import json, sys
required = ['name', 'version', 'description', 'author', 'tags', 'commands']
skill_name = sys.argv[2]
expected_cmds = sys.argv[3].split()
try:
    d = json.load(open(sys.argv[1]))
    for f in required:
        if f not in d:
            print(f"MISSING FIELD in metadata.json: {f}")
    if d.get('name') and d['name'] != skill_name:
        print(f"MISMATCH: metadata.json name '{d['name']}' != skill directory name '{skill_name}'")
    desc = d.get('description', '')
    if len(desc) > 200:
        print(f"TOO LONG: metadata.json description is {len(desc)} chars (schema max 200)")
    commands = d.get('commands', [])
    if commands:
        for cmd in expected_cmds:
            if cmd not in commands:
                print(f"MISMATCH: metadata.json commands {commands} does not include '{cmd}'")
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
