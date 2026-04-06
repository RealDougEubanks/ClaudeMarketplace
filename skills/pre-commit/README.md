# pre-commit

A Claude Code skill that acts as a fast pre-commit quality gate. It scans staged files for common problems before you commit — and can install itself as a git hook so checks run automatically every time you commit.

---

## What It Does

When you run `/pre-commit`, the skill inspects all staged files (or all modified files if nothing is staged) and runs five checks:

| Check | What It Catches | Severity |
|---|---|---|
| Secret scan | Hardcoded passwords, API keys, AWS credentials, private key headers | BLOCKER |
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

Writes a `pre-commit` shell script to `.git/hooks/pre-commit` and makes it executable. After installation, the checks run automatically every time you run `git commit`.

The hook falls back gracefully if Claude Code is not installed — it prints a warning and allows the commit to proceed rather than blocking your workflow.

Note: git hooks are local to your machine. Each team member must run `/pre-commit install` in their own clone, or you can add it to your project's setup/bootstrap script.

### Mode C — Uninstall the hook

```
/pre-commit uninstall
```

Removes `.git/hooks/pre-commit` if it exists and confirms removal.

---

## What Each Check Catches

### Secret scan

Searches staged files for patterns that indicate hardcoded credentials:
- `password = "..."`, `passwd = '...'`, and similar assignments
- `api_key`, `apikey`, `api_token`, `access_token`, `secret_key`, `secret` assignments
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` assignments
- PEM private key headers (`-----BEGIN RSA PRIVATE KEY-----`, etc.)

Files matching `*.example`, `*.sample`, `*.test.*`, `*.spec.*`, and paths under `node_modules/` or `vendor/` are excluded from the secret scan.

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

To remove the hook:

```
/pre-commit uninstall
```

---

## Skipping in Emergencies

If you need to bypass the hook in a genuine emergency (e.g., reverting a broken deploy), you can use:

```bash
git commit --no-verify
```

**Use this sparingly and deliberately.** Bypassing the hook means none of the quality checks run. Only use `--no-verify` when you have a clear, time-critical reason — for example, reverting a production incident. After the emergency is resolved, review the bypassed commit and address any issues that would have been caught.

Never make `--no-verify` part of a routine workflow.
