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

# Validate metadata.json has required fields
if [ -f "$SKILL_DIR/metadata.json" ]; then
  for field in name version description author tags; do
    if ! grep -q "\"$field\"" "$SKILL_DIR/metadata.json"; then
      echo "MISSING FIELD in metadata.json: $field"
      errors=$((errors + 1))
    fi
  done
fi

echo "---"
if [ "$errors" -gt 0 ]; then
  echo "FAILED: $errors error(s) found."
  exit 1
else
  echo "PASSED: Skill structure is valid."
fi
