# Example Skill — Hello Project

A sample skill that greets the user and gives a quick summary of the current project.

## Usage

```
/hello-project
```

## What it does

1. Reads project metadata (README, package.json)
2. Scans the top-level directory
3. Returns a friendly summary with language/framework detection

## Note

This is a **contributor reference skill**, not a production skill. It exists to demonstrate the expected directory structure and file format. See [CONTRIBUTING.md](../../CONTRIBUTING.md) if you want to build your own skill based on this template.

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "example-skill@claude-skills-marketplace": true
  }
}
```
