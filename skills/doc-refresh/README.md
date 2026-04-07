# doc-refresh

> Complete documentation refresh. Audits stale docs, creates missing docs, and rewrites
> everything assuming the reader was paged at 2am with zero context.

## What It Does

This skill performs a full documentation overhaul on any project:

- **Audits** every `.md` file for dead file references, removed commands, and missing env vars.
- **Deletes** docs that are no longer valid (wrong is worse than missing).
- **Creates** standard docs that are absent: `README.md`, `docs/RUNBOOK.md`, `CONTRIBUTING.md`,
  `SECURITY.md`, `docs/ENV_VARS.md`.
- **Rewrites** stale docs using the 2am-engineer persona: no assumed context, numbered steps,
  mandatory security callouts, tables over prose, AI-friendly heading structure.

### The 2am-Engineer Persona

Every doc is written as if the reader was just paged, is not fully awake, and has never seen
the codebase. Short sentences. Numbered procedures. Security warnings before any sensitive step.
No jargon without a definition. This also makes docs highly consumable by AI agents.

## Installation

Add this repo as a marketplace in `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "doc-refresh@claude-skills-marketplace": true
  }
}
```

## Usage

| Command | What it does |
|---------|-------------|
| `/doc-refresh` | Full refresh: audit, purge stale, fill gaps |
| `/doc-refresh runbook` | Generate `docs/RUNBOOK.md` only |
| `/doc-refresh check` | Audit only — no writes. Good for CI. |
| `/doc-refresh install` | Install as a post-commit git hook |
| `/doc-refresh uninstall` | Remove the post-commit hook |

## Example Output

```
doc-refresh Results
───────────────────────────────────
Stale docs purged:    1  (docs/OLD_SETUP.md)
Docs created:         2  (docs/RUNBOOK.md, SECURITY.md)
Docs rewritten:       1  (README.md — 3 dead command references fixed)
Docs unchanged:       2  (CONTRIBUTING.md, docs/assumptions.md)

Security callouts added: 6
2am-engineer persona applied: all docs ✓

Next: commit these changes, then run /pre-commit to verify.
```

## Pre-Commit Hook

Run `/doc-refresh install` to attach this skill as a pre-commit git hook. Before each commit
that touches source or doc files, the hook runs `/doc-refresh`, then auto-stages any updated
docs so they land in the **same commit** as the code change. Skip a single run with
`SKIP_DOC_REFRESH=1 git commit ...`. The hook never blocks a commit — if Claude is unavailable
it warns and continues.
