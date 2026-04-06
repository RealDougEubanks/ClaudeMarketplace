#!/usr/bin/env bash
# new-skill.sh — Scaffold a new skill directory from templates.
# Usage: ./scripts/new-skill.sh <skill-name-in-kebab-case>

set -euo pipefail

SKILL_NAME="${1:?Usage: new-skill.sh <skill-name-in-kebab-case>}"

# Validate kebab-case format
if ! echo "$SKILL_NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "Error: skill name must be kebab-case (e.g. my-skill, git-workflow)."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/$SKILL_NAME"
TEMPLATES_DIR="$REPO_ROOT/templates"

if [ -d "$SKILL_DIR" ]; then
  echo "Error: $SKILL_DIR already exists. Choose a different name or edit the existing skill."
  exit 1
fi

mkdir -p "$SKILL_DIR/commands"

# Scaffold the command file from template
sed "s/SKILL_NAME/$SKILL_NAME/g" "$TEMPLATES_DIR/skill.md" > "$SKILL_DIR/commands/$SKILL_NAME.md"

# Write pre-filled metadata.json
cat > "$SKILL_DIR/metadata.json" << METAEOF
{
  "name": "$SKILL_NAME",
  "version": "1.0.0",
  "description": "Short description of what the skill does (max 200 chars)",
  "author": {
    "name": "Doug Eubanks",
    "github": "realdougeubanks"
  },
  "license": "MIT",
  "category": "productivity",
  "tags": ["$SKILL_NAME"],
  "commands": ["/$SKILL_NAME"],
  "triggers": [],
  "tools": []
}
METAEOF

# Write README.md stub
cat > "$SKILL_DIR/README.md" << READMEEOF
# $SKILL_NAME

> One-line description of what this skill does.

## What It Does

Describe what the skill does and when to use it.

## Installation

\`\`\`bash
./scripts/install.sh skills/$SKILL_NAME
\`\`\`

## Usage

Invoke with:

\`\`\`
/$SKILL_NAME
\`\`\`

## Example

Provide a short example showing what Claude produces when this skill runs.
READMEEOF

echo "Scaffolded: $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit skills/$SKILL_NAME/commands/$SKILL_NAME.md — instructions Claude follows literally"
echo "  2. Edit skills/$SKILL_NAME/metadata.json           — set description, category, tags, tools"
echo "  3. Edit skills/$SKILL_NAME/README.md               — human-readable docs"
echo "  4. Run: ./scripts/validate.sh skills/$SKILL_NAME"
echo "  5. Add your skill to skills/registry.json"
echo "  6. Open a PR!"
