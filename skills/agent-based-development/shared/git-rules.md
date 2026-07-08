# Git Workflow — Release-Branch Model

Shared reference for all ABD agents.

**Branches:**

- `main`: production-ready history. Never commit directly.
- `release/<version>` (e.g. `release/1.0`): integration branch. Never commit directly.
- `feature/task-XXX-description`: one per task, created from the release branch.
- `fix/task-XXX-description`: bug fixes, created from the release branch.

**Flow:** `feature/*` or `fix/*` → PR into `release/<version>` → when release is ready, `release/<version>` → PR into `main` → tag (e.g. `v1.0.0`).

**Who does what:**

| Action | Responsible Agent |
|--------|------------------|
| Create feature/fix branch | Planning or Dev |
| Open PR | Dev (the agent that did the work) |
| Code review | Tech Review + Security |
| Approve PR | Tech Review + Security; Planning after triage |
| Merge to release branch | Planning or designated agent |
| Cut release (release → main + tag) | Planning or DevOps |
| Create changelog | Documentation |

**Never commit directly to `main` or the release branch.** Always use feature/fix branches and PRs.
