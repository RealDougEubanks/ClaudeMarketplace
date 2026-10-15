---
name: pre-commit
description: "Fast pre-commit quality gate: scans staged files for secrets, dead code, naming issues, merge conflict markers, and direct-to-main commits. Installs as a git hook via /pre-commit install."
argument-hint: "[install|uninstall]"
model: haiku
allowed-tools: Bash, Grep, Read, Write, Glob
disable-model-invocation: true
---

# pre-commit

Invoked via `/pre-commit`. This skill acts as a pre-commit quality gate — it runs a fast subset of checks before committing and blocks the commit if critical issues are found. It can also install itself as a git hook.

---

## Mode A — Run checks now (default)

When invoked without arguments, run immediately against staged files (or all modified files if nothing is staged):

1. Use Bash to get the list of files to check. `git diff` exits 0 even when it prints nothing, so an `||` fallback would never fire; test for empty output explicitly:
   ```bash
   FILES=$(git diff --cached --name-only --diff-filter=ACMR)
   if [ -z "$FILES" ]; then
     FILES=$(git diff --name-only --diff-filter=ACMR)
   fi
   printf '%s\n' "$FILES"
   ```
   If both lists are empty, report "Nothing staged or modified — nothing to check." and stop.

2. **Secret scan** — Use Grep across all staged files for hardcoded secret patterns:
   - Assignments (`=` or `:` — covers code, YAML, and JSON): `(?i)(password|passwd|pwd|api_key|apikey|api_token|access_token|secret_key|client_secret|secret)\s*[=:]\s*['"][^'"]{8,}['"]`
   - Shell exports: `export\s+[A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z_]*=\S{8,}`
   - AWS: `(?i)(aws_access_key_id|aws_secret_access_key)\s*[=:]\s*['"][^'"]{16,}['"]` and literal `AKIA[0-9A-Z]{16}`
   - Modern token prefixes: `sk-ant-`, `sk-proj-`, `github_pat_`, `ghp_`, `glpat-` (GitLab), `npm_` (npm), `AIza` (Google API key), `xox[baprs]-`, `sk_live_`
   - Private key headers: `-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----`
   - High-entropy heuristic: any assignment of a 32+ char mixed-case alphanumeric literal to a variable whose name contains `key`, `token`, `secret`, or `auth`
   - Exclude: `*.example`, `*.sample`, `node_modules/`, `vendor/`
   - **BLOCKER if found**, except in test files (`*.test.*`, `*.spec.*`), where a match is a **WARNING**: fixtures usually hold fake values, but real credentials do get pasted into tests, so they are still scanned and reported. Report file and line number. When reporting, redact the matched value (show the first 4 characters only).

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
   ✗ Dead code         BLOCKED — src/foo/handler.ts:42: "stub"
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

Conventions shared with other skills that install a `pre-commit` hook (doc-refresh uses the same ones):

- **Marker:** the hook's second line is the exact comment `# claude-skill-hook: pre-commit`. Install and uninstall only treat a hook as this skill's own when that line is present.
- **Backup and chain:** an existing foreign hook is moved to `pre-commit.backup.pre-commit` in the same hooks directory, and the new hook runs it first, passing its arguments through and stopping on a non-zero exit. Each skill uses its own backup name (`pre-commit.backup.<skill-name>`), so two skills can stack without overwriting each other's backup.

1. Use Bash to confirm this is a git work tree and resolve the hooks directory. `--git-path hooks` honors `core.hooksPath` and linked worktrees, unlike a hard-coded `.git/hooks`:
   ```bash
   git rev-parse --is-inside-work-tree
   HOOKS_DIR=$(git rev-parse --git-path hooks)
   git config --get core.hooksPath || true
   echo "$HOOKS_DIR"
   ```
2. If `core.hooksPath` is set, a hook manager such as husky or lefthook probably owns the hooks. Warn the user that a file written to `$HOOKS_DIR` may be overwritten by that tool or committed to the repo, and suggest calling the checks from the manager's own config instead. Stop unless the user explicitly says to install anyway.
3. Inspect `$HOOKS_DIR/pre-commit`:
   - **Missing:** continue to step 4.
   - **Contains the line `# claude-skill-hook: pre-commit`:** this is an earlier install of this skill. Overwrite it in place (an upgrade); do not create a backup.
   - **Any other hook:** if `$HOOKS_DIR/pre-commit.backup.pre-commit` already exists, stop and tell the user. Never overwrite an existing backup — it may be the only copy of their original hook. Otherwise move the hook aside, keeping its mode:
     ```bash
     mv "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.backup.pre-commit"
     ```
     Tell the user the existing hook was backed up and will run first on every commit.
4. Use `mkdir -p "$HOOKS_DIR"`, then Write to create `$HOOKS_DIR/pre-commit` with the canonical script below **verbatim** — do not regenerate, paraphrase, or "improve" it. The deterministic checks are the enforcement path; the optional Claude call is advisory only and can never block or approve a commit.

   ```bash
   #!/usr/bin/env bash
   # claude-skill-hook: pre-commit
   # pre-commit hook installed by the pre-commit skill.
   # Enforcement is deterministic (grep-based). Claude, if present, is advisory only.
   # Bypass once: SKIP_PRE_COMMIT=1 git commit ...
   # (git commit --no-verify also works but skips ALL hooks, including this secret scan.)
   set -euo pipefail

   # Chain the hook that was here before install, if any. It runs even when
   # SKIP_PRE_COMMIT is set, because SKIP_PRE_COMMIT only skips this hook.
   CHAINED="$(dirname "$0")/pre-commit.backup.pre-commit"
   if [ -x "$CHAINED" ]; then
     "$CHAINED" "$@" || exit $?
   fi

   if [ -n "${SKIP_PRE_COMMIT:-}" ]; then
     exit 0
   fi

   STAGED=$(git diff --cached --name-only --diff-filter=ACMR || true)
   if [ -z "$STAGED" ]; then
     exit 0
   fi

   FAIL=0

   # 1. Block direct commits to main/master
   BRANCH=$(git branch --show-current)
   if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
     echo "BLOCKED: committing directly to $BRANCH. Create a branch first." >&2
     FAIL=1
   fi

   # 2. Secret scan on staged content (redacts matches in output).
   #    Test files are scanned too, but a match there is a warning, not a block.
   SECRET_RE='-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----|AKIA[0-9A-Z]{16}|sk-ant-[A-Za-z0-9_-]{10,}|sk-proj-[A-Za-z0-9_-]{10,}|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{30,}|glpat-[A-Za-z0-9_-]{20,}|npm_[A-Za-z0-9]{36}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,}|sk_live_[A-Za-z0-9]{16,}'
   ASSIGN_RE="(password|passwd|pwd|api_key|apikey|api_token|access_token|secret_key|client_secret|aws_secret_access_key)[[:space:]]*[=:][[:space:]]*['\"][^'\"]{8,}['\"]|export[[:space:]]+[A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z_]*=[^[:space:]]{8,}"

   while IFS= read -r f; do
     case "$f" in
       *.example|*.sample|node_modules/*|vendor/*) continue ;;
     esac
     MATCHES=$(git show ":$f" 2>/dev/null | grep -Ec -e "$SECRET_RE" || true)
     ASSIGNS=$(git show ":$f" 2>/dev/null | grep -icE -e "$ASSIGN_RE" || true)
     if [ "${MATCHES:-0}" -gt 0 ] || [ "${ASSIGNS:-0}" -gt 0 ]; then
       case "$f" in
         *.test.*|*.spec.*)
           echo "WARNING: possible secret in staged test file: $f (matches redacted; confirm it is a fake value)" >&2
           ;;
         *)
           echo "BLOCKED: possible secret in staged file: $f (matches redacted; inspect the file)" >&2
           FAIL=1
           ;;
       esac
     fi
   done <<< "$STAGED"

   # 3. Merge conflict markers
   while IFS= read -r f; do
     if git show ":$f" 2>/dev/null | grep -qE '^(<<<<<<< |>>>>>>> )'; then
       echo "BLOCKED: merge conflict markers in staged file: $f" >&2
       FAIL=1
     fi
   done <<< "$STAGED"

   if [ "$FAIL" -ne 0 ]; then
     echo "" >&2
     echo "pre-commit: commit blocked by deterministic checks above." >&2
     echo "Bypass once: SKIP_PRE_COMMIT=1 git commit ..." >&2
     exit 1
   fi

   # 4. Optional advisory review — output is informational only and never gates.
   #    PRE_COMMIT_ADVISORY guards against recursion (claude may run git commands).
   if [ -z "${PRE_COMMIT_ADVISORY:-}" ] && command -v claude >/dev/null 2>&1; then
     if command -v timeout >/dev/null 2>&1; then
       PRE_COMMIT_ADVISORY=1 SKIP_PRE_COMMIT=1 timeout 60 claude -p "/pre-commit" 2>/dev/null || true
     else
       PRE_COMMIT_ADVISORY=1 SKIP_PRE_COMMIT=1 claude -p "/pre-commit" 2>/dev/null || true
     fi
     echo "pre-commit: advisory review done (warnings above, if any, are non-blocking)."
   fi

   exit 0
   ```

5. Use Bash to make the hook executable: `chmod +x "$HOOKS_DIR/pre-commit"`
6. Confirm installation, naming the hooks directory used and any backup created. Remind the user:
   - The hook runs locally only — team members must run `/pre-commit install` themselves (or add it to project setup scripts).
   - Skip once with `SKIP_PRE_COMMIT=1 git commit ...`. A chained earlier hook still runs.
   - `git commit --no-verify` also bypasses it, but that skips ALL hooks including the secret scan — prefer `SKIP_PRE_COMMIT=1`.
   - The Claude advisory step is optional, capped at 60 seconds where `timeout` exists, and can only warn — the deterministic checks are what block.

---

## Mode C — Uninstall hook

When invoked as `/pre-commit uninstall`:

1. Use Bash to resolve the hooks directory: `HOOKS_DIR=$(git rev-parse --git-path hooks)`.
2. If `$HOOKS_DIR/pre-commit` does not exist, report that no hook is installed and stop.
3. Check for the marker: `grep -qx '# claude-skill-hook: pre-commit' "$HOOKS_DIR/pre-commit"`. If it is absent, the active hook belongs to something else (another tool, or another skill installed on top of this one). Do not touch it; tell the user which hook is active and stop.
4. If `$HOOKS_DIR/pre-commit.backup.pre-commit` exists, restore it as the active hook so the user's original hook keeps running:
   ```bash
   mv "$HOOKS_DIR/pre-commit.backup.pre-commit" "$HOOKS_DIR/pre-commit"
   ```
   Otherwise remove the hook: `rm "$HOOKS_DIR/pre-commit"`.
5. Confirm what was removed and whether a previous hook was restored.
