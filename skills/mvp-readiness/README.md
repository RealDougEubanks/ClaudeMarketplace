<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# mvp-readiness

This skill runs a quality-gate audit before you declare a project MVP-ready. The full audit
checks 23 items in 8 sections. The report gives PASS, FAIL, or N/A for each item, with
file-level evidence and a list of blockers.

## Usage

| Slash command | Mode | Use |
|---|---|---|
| `/mvp-readiness` | Full audit | Before launch. Checks all 8 sections. |
| `/mvp-readiness --quick` | Quick scan | During daily work. Checks only the 5 hard blockers. Completes in less than 30 seconds. |

Run the slash command from the root of your project. The skill audits the current working
directory.

## What It Does

### Full audit

1. Reads `README.md` and the files in `docs/`.
2. Uses Glob to find source files, config files, and entry points.
3. Uses Grep to find hardcoded secrets, placeholder code, and external calls with no error handling.
4. Reads `.gitignore` to confirm that it covers `.env`.
5. Searches `README.md` for clone, install, and run instructions.
6. Examines the package manifests for unpinned versions, abandoned packages, and a missing lockfile.
7. Looks for performance problems: no pagination, sync calls in async handlers, and foreign keys with no index.
8. Gives each checklist item a status of PASS, FAIL, or N/A. Each N/A has a written reason.
9. Writes a Markdown report with a summary, a results table, and a list of blockers.

The project is **NOT READY** if one or more items are FAIL and have no written N/A reason.

### Quick scan

The quick scan runs 5 Bash or Grep checks. It does not read files one at a time.

| Check | FAIL condition |
|---|---|
| Secret scan | A `password = "..."` match outside test files |
| README exists | `README.md` is missing or is 100 bytes or smaller |
| External call error handling | More than 5 `fetch`, `axios`, `.query(`, or `.connect(` calls with no `try`, `catch`, `rescue`, or `.then(` on the same line (a heuristic) |
| Secrets in git history | A `.env` file shows in `git log --all` |
| Placeholder code | `TODO`, `FIXME`, `stub`, `placeholder`, or `impl later` in non-test files |

The status line shows `READY` only if all 5 checks pass.

## The Checklist

| Section | Items |
|---|---|
| 1. Stability & Error Handling | Error checks on all external calls (DB, API, file system). No crash on invalid input. Repeated runs do not corrupt state. |
| 2. Configuration & Environment | Required env vars validated at startup (fail fast). No hardcoded magic strings, URLs, or ports. No secrets in the repo. |
| 3. Logging & Observability | Logs have timestamps and severity levels. No silent failures. |
| 4. Security (Golden Rules) | All user input validated or sanitized. Least privilege. Sensitive features off by default. |
| 5. Documentation & UX | README goes from clone to run in fewer than 3 steps. `--help` or usage examples. Web projects: WCAG 2.2 AA contrast and mobile support. |
| 6. Implementation Integrity | No placeholder code in production paths. Naming follows the project convention. README has stack, license, and troubleshooting sections. |
| 7. Dependency Health | Versions pinned or range-constrained. No abandoned or deprecated packages. Lockfile committed. |
| 8. Performance Baseline | No N+1 queries or unindexed foreign keys. Pagination on list endpoints. No sync blocking calls in async handlers. |

## Example Output

Full audit:

```markdown
## MVP Readiness Report — my-app — 2026-01-15

### Summary
**Status:** NOT READY
**Blockers:** 2

### Checklist Results
| # | Section | Item | Status | Evidence |
|---|---------|------|--------|----------|
| 1 | Stability & Error Handling | Error boundaries on all external calls | PASS | All DB calls in src/db.ts wrapped in try/catch |
| 2 | Stability & Error Handling | No crash on invalid input | FAIL | CLI crashes with TypeError on non-numeric --port (src/cli.ts:42) |
...

### Blockers (must fix before MVP)
- [#2] `src/cli.ts:42` — CLI crashes on non-numeric --port. Add input validation before parseInt.
```

Quick scan:

```
## MVP Quick Scan — <project> — <date>

✓ Secret scan: PASSED
✗ README: FAILED — README.md not found
✓ Error handling: PASSED (heuristic)
✓ Git history: PASSED
⚠ Placeholder code: WARNING — 3 TODOs in src/ (non-blocking)

Status: NOT READY — 1 blocker. Run /mvp-readiness for full audit.
```

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "mvp-readiness@claude-skills-marketplace": true
  }
}
```

Then run `/mvp-readiness` in a Claude Code session.

## Related Skills

- `/golden-rules`: installs always-on security and coding standards.
- `/full-security-review`: a deep security audit with OWASP coverage.
- `/agent-based-development`: a multi-agent workflow with an MVP gate.
