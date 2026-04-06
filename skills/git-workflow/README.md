# git-workflow

Enforce and execute the release-branch Git model. Claude guides you through the correct git operations for your current context — starting new work, opening a PR (with security review gate), cutting a release, or viewing the full workflow reference.

## What It Does

When you run `/git-workflow`, Claude asks what you're trying to do and then executes:

| Action | What Claude Does |
|--------|-----------------|
| **View docs** | Prints the full release-branch workflow reference |
| **Start new work** | Detects the release branch, asks for task info, creates `feature/` or `fix/` branch |
| **Open a PR** | Checks for unresolved `critical/severe/moderate` findings first, then generates PR with `gh pr create` |
| **Cut a release** | Merges release branch to `main`, creates version tag, prompts to push |

## Branch Model

```
main                  ← production only; never commit directly
  └── release/1.0     ← integration; never commit directly
        ├── feature/task-001-auth
        ├── feature/task-002-blog-list
        └── fix/task-003-login-crash
```

When the release is ready: `release/1.0` → PR → `main` → tag `v1.0.0`

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Feature branch | `feature/task-NNN-description` | `feature/task-042-user-auth` |
| Fix branch | `fix/task-NNN-description` | `fix/task-107-login-crash` |
| Release branch | `release/<version>` | `release/1.0` |
| Version tag | `vMAJOR.MINOR.PATCH` | `v1.0.0` |

## PR Safety Gate

Before opening a PR, Claude checks `handoffs/reviews/` for unresolved findings with severity `critical`, `severe`, or `moderate`. If any exist, the PR is blocked until they are resolved by the Planning agent (via `/abd-triage`).

## Usage

```
/git-workflow
```

Claude will prompt you for the specific action. Or specify inline:

```
/git-workflow — start new work for task-042
/git-workflow — open PR
/git-workflow — cut release 1.0.0
```

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

## Installation

```bash
./scripts/install.sh skills/git-workflow /path/to/your/project
```

## Related Skills

- `/agent-based-development` — full workflow where git-workflow is embedded
- `/security-review` — run a security audit before opening PRs
- `/mvp-readiness` — quality gate to run before cutting a release
