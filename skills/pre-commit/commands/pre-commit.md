---
name: pre-commit
description: Fast pre-commit quality gate: scans staged files for secrets, dead code, naming issues, merge conflict markers, and direct-to-main commits. Installs as a git hook via /pre-commit install.
---

# pre-commit

Invoked via `/pre-commit`. This skill acts as a pre-commit quality gate — it runs a fast subset of checks before committing and blocks the commit if critical issues are found. It can also install itself as a git hook.

---

## Mode A — Run checks now (default)

When invoked without arguments, run immediately against staged files (or all modified files if nothing is staged):

1. Use Bash to get the list of files to check:
   ```bash
   git diff --cached --name-only 2>/dev/null || git diff --name-only
   ```

2. **Secret scan** — Use Grep across all staged files for hardcoded secret patterns:
   - `(?i)(password|passwd|pwd)\s*=\s*['"][^'"]{4,}['"]`
   - `(?i)(api_key|apikey|api_token|access_token|secret_key|secret)\s*=\s*['"][^'"]{8,}['"]`
   - `(?i)(aws_access_key_id|aws_secret_access_key)\s*=\s*['"][^'"]{16,}['"]`
   - Private key headers: `-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----`
   - Exclude: `*.example`, `*.sample`, `*.test.*`, `*.spec.*`, `node_modules/`, `vendor/`
   - **BLOCKER if found.** Report file and line number. Do not commit.

3. **Dead code scan** — Use Grep across staged source files for:
   - `^\s*//.*` blocks of 3+ consecutive commented-out code lines (not doc comments)
   - Common placeholder strings: `TODO`, `FIXME`, `HACK`, `XXX`, `impl later`, `stub`, `placeholder`
   - Exclude: `*.md`, `*.txt`, documentation files
   - **WARNING** (non-blocking) for TODO/FIXME; **BLOCKER** for stub/placeholder in non-test files.

4. **Naming check** — Use Read on each staged source file. Load naming conventions from `CLAUDE.md` if present (Grep for "naming" section). Apply:
   - Flag obvious violations: ALL_CAPS variable names outside constants, single-letter variables outside loop counters, names < 3 chars in function signatures
   - **WARNING** (non-blocking).

5. **No direct main check** — Use Bash to confirm the current branch is NOT `main`:
   ```bash
   git branch --show-current
   ```
   If on `main`, **BLOCKER**: "You are committing directly to main. Create a branch first."

6. **Trailing whitespace / merge conflicts** — Use Grep across staged files for:
   - `<<<<<<< HEAD` — unfixed merge conflict marker → **BLOCKER**
   - Trailing whitespace on lines → **WARNING**

7. **Report results** — Print a summary table:
   ```
   Pre-Commit Gate Results
   ──────────────────────
   ✓ Secret scan       PASSED
   ✗ Dead code         BLOCKED — skills/foo/skill.md:42: "stub"
   ⚠ Naming            WARNING — 2 issues (non-blocking)
   ✓ Branch check      PASSED (branch: feature/my-feature)
   ✓ Conflict markers  PASSED

   Status: BLOCKED — fix 1 blocker before committing.
   ```

8. If any BLOCKER exists: exit with a non-zero message and do NOT proceed with the commit.
   If only WARNINGs: inform the user and ask "Proceed with commit anyway? (y/n)"
   If all PASSED: confirm "All checks passed. Safe to commit."

---

## Mode B — Install as git hook

When invoked as `/pre-commit install`:

1. Use Bash to confirm `.git/` exists in the current working directory.
2. Use Write to create `.git/hooks/pre-commit` with a shell script that:
   - Runs `claude -p "/pre-commit"` (non-interactively)
   - Exits with code 1 if Claude reports any BLOCKER
   - Falls back gracefully if Claude Code is not installed (prints warning, allows commit)
3. Use Bash to make the hook executable: `chmod +x .git/hooks/pre-commit`
4. Confirm installation. Remind the user this hook runs locally only — team members must run `/pre-commit install` themselves (or add it to project setup scripts).

---

## Mode C — Uninstall hook

When invoked as `/pre-commit uninstall`:
1. Use Bash to check if `.git/hooks/pre-commit` exists.
2. Remove it with Bash.
3. Confirm removal.
