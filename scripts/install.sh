#!/usr/bin/env bash
# install.sh — Install a skill from the marketplace into the local Claude Code config.
# Usage: ./scripts/install.sh skills/example-skill [target-directory]

set -euo pipefail

SKILL_DIR="${1:?Usage: install.sh <skill-directory> [target-directory]}"
TARGET_DIR="${2:-$HOME/.claude/skills}"

SKILL_NAME=$(basename "$SKILL_DIR")

if [ ! -f "$SKILL_DIR/skill.md" ]; then
  echo "Error: $SKILL_DIR/skill.md not found. Is this a valid skill?"
  exit 1
fi

mkdir -p "$TARGET_DIR/$SKILL_NAME"
cp "$SKILL_DIR/skill.md" "$TARGET_DIR/$SKILL_NAME/"
cp "$SKILL_DIR/metadata.json" "$TARGET_DIR/$SKILL_NAME/" 2>/dev/null || true

echo "Installed '$SKILL_NAME' to $TARGET_DIR/$SKILL_NAME"
