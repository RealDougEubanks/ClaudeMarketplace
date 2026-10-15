# pre-commit

A Claude Code skill that acts as a fast pre-commit quality gate. It scans staged files for common problems before you commit — and can install itself as a git hook so checks run automatically every time you commit.

---

## What It Does

When you run `/pre-commit`, the skill inspects all staged files (or all modified files if nothing is staged) and runs five checks:

| Check | What It Catches | Severity |
|---|---|---|
| Secret scan | Hardcoded passwords, API keys, AWS credentials, private key headers | BLOCKER (WARNING in `*.test.*` / `*.spec.*`) |
| Dead code scan | `stub`, `placeholder` strings in non-test files | BLOCKER |
| Dead code scan | `TODO`, `FIXME`, `HACK`, `XXX`, commented-out code blocks | WARNING |
| Naming check | ALL_CAPS non-constants, single-letter function params, names < 3 chars | WARNING |
| Branch check | Committing directly to `main` | BLOCKER |
| Conflict markers | Unfixed `<<<<<<< HEAD` merge conflict markers | BLOCKER |
| Trailing whitespace | Lines ending with whitespace | WARNING |

**BLOCKER** — the commit is blocked until the issue is resolved.
**WARNING** — non-blocking; you are asked to confirm before proceeding.

---

## Three Modes

### Mode A — Run checks now (default)

```
/pre-commit
```

Runs all checks against staged files immediately. Prints a summary table and either:
- Blocks the commit if any BLOCKER is found, listing each violation with file and line number.
- Asks for confirmation if only WARNINGs are present.
- Confirms "All checks passed. Safe to commit." if everything is clean.

### Mode B — Install as a git hook

```
/pre-commit install
```

Writes a `pre-commit` shell script to the repository's hooks directory (resolved with `git rev-parse --git-path hooks`, normally `.git/hooks/pre-commit`) and makes it executable. If `core.hooksPath` is set (husky, lefthook), the installer warns and stops unless you confirm. After installation, the checks run automatically every time you run `git commit`.

The blocking checks are plain shell and work without Claude Code. If the `claude` CLI is not installed, the optional advisory review is skipped.

Note: git hooks are local to your machine. Each team member must run `/pre-commit install` in their own clone, or you can add it to your project's setup/bootstrap script.

### Mode C — Uninstall the hook

```
/pre-commit uninstall
```

Removes the hook only if it carries this skill's marker line (`# claude-skill-hook: pre-commit`). If a previous hook was backed up at install time, it is restored as the active hook. A hook installed by anything else is left alone.

---

## What Each Check Catches

### Secret scan

Searches staged files for patterns that indicate hardcoded credentials:
- `password = "..."`, `passwd = '...'`, and similar assignments
- `api_key`, `apikey`, `api_token`, `access_token`, `secret_key`, `secret` assignments
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` assignments
- PEM private key headers (`-----BEGIN RSA PRIVATE KEY-----`, etc.)
- Token prefixes: `sk-ant-`, `sk-proj-`, `github_pat_`, `ghp_`, `glpat-`, `npm_`, `AIza`, `xox[baprs]-`, `sk_live_`

Files matching `*.example` and `*.sample`, and paths under `node_modules/` or `vendor/`, are excluded from the secret scan. Test files (`*.test.*`, `*.spec.*`) are scanned, but a match there is a WARNING instead of a BLOCKER.

### Dead code scan

Searches staged source files (excluding `.md` and `.txt`) for:
- The strings `stub` or `placeholder` in non-test files — these indicate incomplete implementation and are **BLOCKERs**.
- `TODO`, `FIXME`, `HACK`, `XXX`, `impl later` — tracked as **WARNINGs**.
- Blocks of 3+ consecutive commented-out code lines — tracked as **WARNINGs**.

### Naming check

Reads each staged source file and checks for naming convention violations based on rules in `CLAUDE.md` if present:
- ALL_CAPS variable names that are not constants
- Single-letter variable names outside of loop counters (`i`, `j`, `k`)
- Function parameter names shorter than 3 characters

Naming issues are **WARNINGs** only and do not block the commit.

### Branch check

Confirms you are not committing directly to `main`. Direct commits to `main` are a **BLOCKER**. Create a feature branch and submit a pull request instead.

### Conflict markers and trailing whitespace

Searches for `<<<<<<< HEAD` merge conflict markers — a **BLOCKER** indicating an unresolved merge conflict. Also flags lines with trailing whitespace as a **WARNING**.

---

## How to Install as a Git Hook

Run once per repository clone:

```
/pre-commit install
```

This creates `.git/hooks/pre-commit`. From that point on, every `git commit` in that repository will trigger the checks automatically before the commit is recorded.

The installed hook enforces its blockers with deterministic shell checks (secret patterns, conflict markers, direct-to-main) — it works and blocks even when Claude Code is unavailable. If the `claude` CLI is present, the hook additionally runs an advisory review, capped at 60 seconds, whose output can only warn and never blocks or approves a commit.

If a pre-commit hook already exists (for example one installed by the doc-refresh skill), the installer moves it to `pre-commit.backup.pre-commit` in the hooks directory and the new hook runs it first on every commit. The installer refuses to overwrite an existing backup. Reinstalling over this skill's own hook (identified by the `# claude-skill-hook: pre-commit` marker) upgrades it in place.

To remove the hook:

```
/pre-commit uninstall
```

---

## Skipping in Emergencies

If you need to bypass the hook in a genuine emergency (e.g., reverting a broken deploy), prefer the hook-specific escape hatch, which skips only this hook:

```bash
SKIP_PRE_COMMIT=1 git commit ...
```

`git commit --no-verify` also works, but it skips **all** hooks — including the secret scan — so reserve it for cases where every hook must be bypassed.

**Use either bypass sparingly and deliberately.** Bypassing the hook means none of the quality checks run. Only use `--no-verify` when you have a clear, time-critical reason — for example, reverting a production incident. After the emergency is resolved, review the bypassed commit and address any issues that would have been caught.

Never make `--no-verify` part of a routine workflow.
