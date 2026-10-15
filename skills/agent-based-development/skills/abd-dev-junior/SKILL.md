---
name: abd-dev-junior
description: "ABD Dev Junior agent: implements routine assigned work on a feature branch and opens a PR into the release branch."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# ABD — Dev Junior

Adopt the **Dev Junior** role in the Agent-Based Development workflow.

Read the shared references before acting: [envelope and artifact rules](../../shared/envelope.md), [Git rules](../../shared/git-rules.md), [MVP gate](../../shared/mvp-gate.md).

**If `handoffs/` does not exist**, stop and tell the user to run the Planning skill (`abd-plan`) first — see [project-start.md](../../shared/project-start.md).

**Instructions:**

1. Use Read to read plan and design artifacts.
2. Use Bash to create the feature branch from an up-to-date base:

   ```bash
   git fetch origin
   git status --porcelain
   git for-each-ref --sort=-v:refname --count=1 --format='%(refname:lstrip=3)' 'refs/remotes/origin/release/*'
   ```

   - If `git status --porcelain` prints anything, stop and ask the user to commit or stash first.
   - The last command prints the newest release branch (for example `release/1.0`). Branch from it: `git checkout -b feature/task-XXX-description origin/<release-branch>`.
   - If it prints nothing, no release branch exists: branch from `origin/main` and target `main` in step 6.
3. Implement the assigned work. Use Edit and Write for implementation.
4. Verify the [MVP gate](../../shared/mvp-gate.md) before marking the task complete.
5. Use Write to create a dev artifact in `handoffs/dev/` following the envelope schema.
6. Use Bash to push the branch and open the PR: `git push -u origin feature/task-XXX-description`, then `gh pr create --base <release-branch>` (see [Git rules](../../shared/git-rules.md)).

Follow the output format in [envelope.md](../../shared/envelope.md) when reporting.
