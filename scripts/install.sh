#!/usr/bin/env bash
# install.sh — Install a skill from the marketplace into a Claude Code project.
# Usage: ./scripts/install.sh skills/<skill-name> [project-dir]
#
# Installs to .claude/commands/<skill-name>.md (relative to project-dir or CWD).
# For skills with "category": "base", also appends skill content to CLAUDE.md.

set -euo pipefail

SKILL_DIR="${1:?Usage: install.sh <skill-directory> [project-dir]}"
PROJECT_DIR="${2:-$(pwd)}"

SKILL_NAME=$(basename "$SKILL_DIR")
COMMANDS_DIR="$PROJECT_DIR/.claude/commands"
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
SKILL_MD="$SKILL_DIR/commands/$SKILL_NAME.md"

if [ ! -f "$SKILL_MD" ]; then
  echo "Error: $SKILL_MD not found. Is this a valid skill directory?"
  exit 1
fi

if [ ! -f "$SKILL_DIR/metadata.json" ]; then
  echo "Error: $SKILL_DIR/metadata.json not found. Is this a valid skill directory?"
  exit 1
fi

# Install the skill command and metadata to .claude/commands/
mkdir -p "$COMMANDS_DIR"
cp "$SKILL_MD" "$COMMANDS_DIR/$SKILL_NAME.md"
cp "$SKILL_DIR/metadata.json" "$COMMANDS_DIR/$SKILL_NAME.metadata.json"
echo "Installed: $COMMANDS_DIR/$SKILL_NAME.md"
echo "Installed: $COMMANDS_DIR/$SKILL_NAME.metadata.json"

# For base category skills, also append content to CLAUDE.md (idempotent)
CATEGORY=$(python3 -c "
import json, sys
try:
    d = json.load(open('$SKILL_DIR/metadata.json'))
    print(d.get('category', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

if [ "$CATEGORY" = "base" ]; then
  SKILL_DISPLAY_NAME=$(python3 -c "
import json
d = json.load(open('$SKILL_DIR/metadata.json'))
name = d.get('name', '$SKILL_NAME')
print(' '.join(w.capitalize() for w in name.split('-')))
" 2>/dev/null || echo "$SKILL_NAME")

  SECTION_HEADER="## $SKILL_DISPLAY_NAME"

  if [ -f "$CLAUDE_MD" ] && grep -qF "$SECTION_HEADER" "$CLAUDE_MD"; then
    echo "Skipped CLAUDE.md: section '$SECTION_HEADER' already present (idempotent)."
  else
    {
      printf '\n%s\n\n' "$SECTION_HEADER"
      cat "$SKILL_MD"
      printf '\n'
    } >> "$CLAUDE_MD"
    echo "Appended to: $CLAUDE_MD  (section: $SECTION_HEADER)"
  fi
fi

echo ""
echo "Done. '$SKILL_NAME' installed to $PROJECT_DIR"
echo "Invoke with: /$SKILL_NAME"
