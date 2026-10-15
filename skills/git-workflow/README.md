<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# git-workflow

This skill applies the release-branch Git model and runs the git operations for each task. It starts new work, opens a PR with a review check, cuts a release, resolves merge conflicts, and manages stashes. It also prints the workflow reference.

## What It Does

When you run `/git-workflow`, Claude asks which action you want. Then Claude runs that action:

| Action | What Claude Does |
|--------|-----------------|
| **View docs** | Prints the full release-branch workflow reference |
| **Start new work** | Fetches `origin`, stops if the working tree is not clean, finds the highest `release/*` branch, and creates a `feature/` or `fix/` branch from it |
| **Open a PR** | Checks `handoffs/reviews/` for unresolved `critical`, `severe`, or `moderate` findings, pushes the branch, and runs `gh pr create` |
| **Cut a release** | Opens a release PR into `main`. After the merge, creates an annotated (or signed) tag on `main`. |
| **Resolve a merge conflict** | Explains both sides of each conflicted file, applies the resolution you choose, and completes the rebase or merge |
| **Manage stashes** | Inspects, applies, pops, or drops stashes. Asks for confirmation before a drop. |

If no `release/*` branch exists, Claude creates the branch from `main`, and the PR targets `main`.

## Branch Model

```
main                  ← production only; never commit directly
  └── release/1.0     ← integration; never commit directly
        ├── feature/task-001-auth
        ├── feature/task-002-blog-list
        └── fix/task-003-login-crash
```

When the release is ready: `release/1.0` → PR → `main` → tag `v1.0.0`

The skill never commits or pushes directly to `main`. It never force-pushes to `main`.

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Feature branch | `feature/task-NNN-description` | `feature/task-042-user-auth` |
| Fix branch | `fix/task-NNN-description` | `fix/task-107-login-crash` |
| Release branch | `release/<version>` | `release/1.0` |
| Version tag | `vMAJOR.MINOR.PATCH` (annotated or signed) | `v1.0.0` |

## PR Safety Gate

Before Claude opens a PR, it reads the review artifacts in `handoffs/reviews/`. If a finding with severity `critical`, `severe`, or `moderate` is not resolved, Claude blocks the PR. The Planning agent resolves the finding with `/abd-triage`.

## Usage

| Slash command | Action |
|---------------|--------|
| `/git-workflow` | Claude asks which action you want |
| `/git-workflow start` | Start new work |
| `/git-workflow pr` | Open a PR for the current branch |
| `/git-workflow release` | Cut a release |
| `/git-workflow conflict` | Resolve a merge conflict on the current branch |
| `/git-workflow stash` | Manage stashes |

```
/git-workflow
/git-workflow start
/git-workflow release
```

To resolve a conflict, Claude asks you to choose rebase or merge. Rebase gives a linear history. Merge keeps the history of both sides and is safer for shared branches. Claude stages only the resolved files by name, never `git add .`.

> **CAUTION:** A rebase rewrites history. Do not rebase a branch that other people use.

1. If you chose rebase, push with `git push --force-with-lease origin <branch>`.
2. If you chose merge, push with `git push origin <branch>`.

> **WARNING:** A stash drop or `git stash clear` deletes stashed changes permanently. Inspect the stash before you confirm.

To drop a stash, select the drop sub-action and confirm the prompt.

## Who Does What

| Action | Responsible |
|--------|------------|
| Create feature/fix branch | Planning or Dev |
| Open PR | Dev (the agent that did the work) |
| Code review | Tech Review + Security |
| Approve PR | Tech Review + Security; Planning after triage |
| Merge to release | Planning or designated agent |
| Cut release | Planning or DevOps |
| Create changelog | Documentation agent |

After a release, Claude tells you to run `/abd-docs` to create the changelog in `docs/CHANGELOG.md` or `docs/changelogs/<version>.md`.

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "git-workflow@claude-skills-marketplace": true
  }
}
```

Then run `/git-workflow` in any Claude Code session.

## Related Skills

- `/agent-based-development`: full workflow that contains git-workflow
- `/full-security-review`: security audit to run before you open a PR
- `/mvp-readiness`: quality gate to run before you cut a release
