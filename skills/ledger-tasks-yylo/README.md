# ledger-tasks-yylo

> Operate the YYLO Ledger kanban board from Claude Code — create, search, dependency-link, sequence, and land development tasks through the `yy` CLI.

## What It Does

This skill is a comprehensive guide for the [YYLO Ledger](https://github.com/yylo-dev/yylo-skills) task-management CLI. It covers every task lifecycle command (`create`, `list`, `search`, `get`, `mark`, `update`, `archive`, `deps`, `ready`, `order`, `merge`), dependency management between tasks, cross-project routing, and the workflow patterns for agent-driven development — so Claude can drive your Kanban board instead of guessing at commands.

Use it when you need to interact with a YYLO Ledger board: planning work, registering tasks, checking dependency readiness, or landing finished tasks.

## Installation

Enable via the Claude Code marketplace by adding to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "ledger-tasks-yylo@claude-skills-marketplace": true
  }
}
```

## Usage

Invoke with:

```
/ledger-tasks-yylo
```

## Example

```
/ledger-tasks-yylo create a backend task for rate limiting and link it after the auth task
```

Claude runs the equivalent of:

```bash
yy ledger create "Add rate limiting to API" --status backlog --tags feature,backend
yy ledger deps <new-task> --after <auth-task>
yy ledger ready <new-task>
```

and reports the created task IDs and their dependency chain.

## Source

Maintained upstream by the [YYLO team](https://github.com/yylo-dev) at [yylo-dev/yylo-skills](https://github.com/yylo-dev/yylo-skills) (MIT). YYLO also ships companion skills for wiki, workflow, artifact records, and project understanding.
