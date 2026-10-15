<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# onboarding

This skill reads a codebase and writes a developer onboarding guide to `docs/ONBOARDING.md`.
The guide includes a directory map, entry points, environment variables, key commands, and a
Mermaid architecture diagram.

## Usage

| Slash command | Arguments | Result |
|---|---|---|
| `/onboarding` | None | Writes `docs/ONBOARDING.md` for the current repository. |

```
/onboarding
```

Use the skill when you start work in a codebase that you do not know. This applies to a new
developer and to a new Claude agent.

## What It Does

1. Reads `README.md`. Then reads `package.json`, `pyproject.toml`, `go.mod`, `CLAUDE.md`, and `docs/assumptions.md` if they exist.
2. Maps the top-level directories and gives the purpose of each one.
3. Finds the entry points (`index.*`, `main.*`, `server.*`, `app.*`, `cmd/**/*`) and reads the primary one.
4. Reads `Makefile`, the `package.json` scripts, or `Taskfile.yml` to find the install, run, test, build, and lint commands.
5. Finds `.env.example` or other env var documentation and lists the required variables.
6. Counts the source files for each detected language.
7. Makes a Mermaid architecture diagram from the entry point, the infrastructure config files, and the imports.
8. Reads `docs/agentRoster.md` if it exists and adds the agent roster to the guide.
9. Writes the guide to `docs/ONBOARDING.md` and gives you a summary of its sections.

> **SECURITY:** The skill reads `.env.example` only. It does not read `.env` or other files
> with real credentials, and it writes variable names and descriptions only. Do not add real
> secret values to the guide when you edit it.

## Output

The skill writes `docs/ONBOARDING.md` with these sections:

| Section | Content |
|---|---|
| What This Project Does | A summary of 1 or 2 sentences from the README |
| Tech Stack | Language, framework, database, CI/CD |
| Directory Map | A path-to-purpose table for each top-level folder |
| Getting Started | Shell commands to install, configure, and run |
| Key Entry Points | Primary files with line references |
| Environment Variables | Required and optional variables, with descriptions |
| Key Commands | What each npm, make, or task command does |
| Architecture | A Mermaid diagram (`sequenceDiagram`, `graph LR`, or `graph TD`) with a note that it was auto-generated |
| Architecture Overview | A short description of the data or request flow |
| Agent Roster | Only if `docs/agentRoster.md` exists |
| How to Contribute | A summary of the project's own branch, review, and merge rules |

The skill reads the "How to Contribute" rules from `CONTRIBUTING.md`, `CLAUDE.md`, or
`.github/PULL_REQUEST_TEMPLATE.md` in the target project. If none of these files exist, the
section tells the reader to confirm the conventions with a maintainer.

## When to Use

- On the first day on a new project.
- When a new team member joins. Let Claude write the guide, then review it.
- After a large refactor, to replace stale documentation.
- Before you give a codebase to a new Claude agent.

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "onboarding@claude-skills-marketplace": true
  }
}
```

Then run `/onboarding` in a Claude Code session.
