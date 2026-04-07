# Onboarding Skill

Generates a comprehensive developer onboarding guide for any codebase and writes it to `docs/ONBOARDING.md`.

## Usage

```
/onboarding
```

Run this command when landing in an unfamiliar codebase — either as a new developer joining a project or as Claude beginning work in a new repository.

## What It Does

1. Reads project metadata: `README.md`, `package.json` / `pyproject.toml` / `go.mod`, `CLAUDE.md`, and `docs/assumptions.md` if present.
2. Maps the top-level directory structure and describes the purpose of each folder.
3. Finds and reads the primary application entry point (`index.*`, `main.*`, `server.*`, `app.*`, `cmd/**/*`).
4. Reads `package.json` scripts, Makefile, or `Taskfile.yml` to extract key commands (install, run, test, build, lint).
5. Finds `.env.example` or equivalent env documentation and lists all required environment variables.
6. Counts files by detected language type.
7. Checks for `docs/agentRoster.md` and includes the agent roster if found.
8. Writes the complete guide to `docs/ONBOARDING.md`.

## Output

The skill writes a structured Markdown document to `docs/ONBOARDING.md` containing:

- **What This Project Does** — 1-2 sentence summary
- **Tech Stack** — language, framework, database, CI/CD
- **Directory Map** — path-to-purpose table for every top-level folder
- **Getting Started** — copy-paste shell commands to install, configure, and run
- **Key Entry Points** — primary files with line references
- **Environment Variables** — full table of required and optional vars
- **Key Commands** — what each npm/make/task command does
- **Architecture Overview** — brief description of data/request flow
- **Agent Roster** — team of agents (if `docs/agentRoster.md` exists)
- **How to Contribute** — branching strategy and PR process

## When to Use

- First day on a new project
- Onboarding a new team member (have Claude generate the guide, then review it)
- After a large refactor to refresh stale documentation
- Before handing a codebase to a new Claude agent

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "onboarding@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/onboarding` in any Claude Code session.
