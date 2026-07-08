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

mkdir -p "$SKILL_DIR/commands" "$SKILL_DIR/.claude-plugin"

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

# Write .claude-plugin/plugin.json (Claude Code plugin manifest)
cat > "$SKILL_DIR/.claude-plugin/plugin.json" << PLUGINEOF
{
  "name": "$SKILL_NAME",
  "version": "1.0.0",
  "description": "Short description of what the skill does (max 200 chars)",
  "author": {
    "name": "$AUTHOR_NAME",
    "url": "https://github.com/$AUTHOR_GITHUB"
  },
  "license": "MIT"
}
PLUGINEOF

# Write README.md stub
cat > "$SKILL_DIR/README.md" << READMEEOF
# $SKILL_NAME

> One-line description of what this skill does.

## What It Does

Describe what the skill does and when to use it.

## Installation

Enable via the Claude Code marketplace by adding to \`~/.claude/settings.json\`:

\`\`\`json
{
  "enabledPlugins": {
    "$SKILL_NAME@claude-skills-marketplace": true
  }
}
\`\`\`

## Usage

Invoke with:

\`\`\`
/$SKILL_NAME
\`\`\`

## Example

Provide a short example showing what Claude produces when this skill runs.
READMEEOF

# Register the new skill in registry.json and marketplace.json if they exist
# (they are absent when scaffolding outside the marketplace repo).
REGISTERED=false
if [ -f "$REPO_ROOT/skills/registry.json" ] || [ -f "$REPO_ROOT/.claude-plugin/marketplace.json" ]; then
  python3 - "$REPO_ROOT" "$SKILL_NAME" "$AUTHOR_NAME" "$AUTHOR_GITHUB" << 'PYEOF'
import json
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
name, author_name, author_github = sys.argv[2], sys.argv[3], sys.argv[4]
description = "Short description of what the skill does (max 200 chars)"

registry_path = repo_root / "skills" / "registry.json"
if registry_path.exists():
    registry = json.load(open(registry_path))
    if not any(s.get("name") == name for s in registry.get("skills", [])):
        registry["skills"].append({
            "name": name,
            "path": f"skills/{name}",
            "description": description,
            "tags": [name],
            "version": "1.0.0",
            "category": "productivity",
        })
        with open(registry_path, "w") as f:
            json.dump(registry, f, indent=2, ensure_ascii=False)
            f.write("\n")
        print(f"  Registered in skills/registry.json")

mp_path = repo_root / ".claude-plugin" / "marketplace.json"
if mp_path.exists():
    mp = json.load(open(mp_path))
    if not any(p.get("name") == name for p in mp.get("plugins", [])):
        mp["plugins"].append({
            "name": name,
            "source": f"./skills/{name}",
            "description": description,
            "version": "1.0.0",
            "author": {
                "name": author_name,
                "url": f"https://github.com/{author_github}",
            },
            "keywords": [name],
            "category": "productivity",
        })
        with open(mp_path, "w") as f:
            json.dump(mp, f, indent=2, ensure_ascii=False)
            f.write("\n")
        print(f"  Registered in .claude-plugin/marketplace.json")
PYEOF
  REGISTERED=true
fi

echo "Scaffolded: $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit skills/$SKILL_NAME/commands/$SKILL_NAME.md — update name, description frontmatter and instructions"
echo "  2. Edit skills/$SKILL_NAME/metadata.json           — set description, category, tags, tools"
echo "  3. Edit skills/$SKILL_NAME/.claude-plugin/plugin.json — set description"
echo "  4. Edit skills/$SKILL_NAME/README.md               — human-readable docs"
if [ "$REGISTERED" = true ]; then
  echo "  5. Update the placeholder description/category/tags in skills/registry.json and .claude-plugin/marketplace.json (entries added automatically)"
else
  echo "  5. Add your skill to skills/registry.json AND .claude-plugin/marketplace.json"
fi
echo "  6. Run: ./scripts/validate.sh skills/$SKILL_NAME && ./scripts/sync-versions.sh --check"
echo "  7. Open a PR!"
