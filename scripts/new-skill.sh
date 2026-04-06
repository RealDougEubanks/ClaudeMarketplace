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

if [ -d "$SKILL_DIR" ]; then
  echo "Error: $SKILL_DIR already exists. Choose a different name or edit the existing skill."
  exit 1
fi

mkdir -p "$SKILL_DIR/commands"

# Detect author info from git config
AUTHOR_NAME=$(git config user.name 2>/dev/null || echo "Your Name")
AUTHOR_GITHUB=$(git config user.email 2>/dev/null | sed 's/@.*//' || echo "your-username")

# Write commands/<skill-name>.md with YAML frontmatter
cat > "$SKILL_DIR/commands/$SKILL_NAME.md" << SKILLEOF
---
name: $SKILL_NAME
description: Short description of what this skill does (max 200 chars).
---

# Skill Name

One-line description of what this skill does.

## Instructions

<!--
  Write clear, step-by-step instructions for Claude to follow.
  - Be specific about which tools to use (Read, Edit, Bash, etc.)
  - Define the expected output format
  - Include error-handling guidance if needed
-->

1. Step one
2. Step two
3. Step three

## Output Format

Describe the expected output format here.
SKILLEOF

# Write pre-filled metadata.json
cat > "$SKILL_DIR/metadata.json" << METAEOF
{
  "name": "$SKILL_NAME",
  "version": "1.0.0",
  "description": "Short description of what the skill does (max 200 chars)",
  "author": {
    "name": "$AUTHOR_NAME",
    "github": "$AUTHOR_GITHUB"
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
echo "  1. Edit skills/$SKILL_NAME/commands/$SKILL_NAME.md — update name, description frontmatter and instructions"
echo "  2. Edit skills/$SKILL_NAME/metadata.json           — set description, category, tags, tools"
echo "  3. Edit skills/$SKILL_NAME/README.md               — human-readable docs"
echo "  4. Run: ./scripts/validate.sh skills/$SKILL_NAME"
echo "  5. Add your skill to skills/registry.json"
echo "  6. Open a PR!"
