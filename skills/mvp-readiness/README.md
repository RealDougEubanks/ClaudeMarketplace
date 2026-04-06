# mvp-readiness

Run a structured quality-gate audit before declaring a project MVP-ready. Claude checks 18 criteria across stability, security, logging, documentation, and implementation integrity, then produces a pass/fail report with file-level evidence and a blockers list.

## What It Does

When you run `/mvp-readiness`, Claude:

1. Reads `README.md`, `docs/`, and key config files.
2. Uses Glob to discover source files and project structure.
3. Uses Grep to check for hardcoded secrets, placeholder code, and missing error handling.
4. Evaluates each checklist item as **PASS**, **FAIL**, or **N/A** (with justification).
5. Produces a markdown report with a summary, full results table, and a blockers list.

The project is declared **NOT READY** if any item is FAIL without written N/A justification.

## The Checklist

### Stability & Error Handling
- All external calls (DB, API, file system) have error boundaries.
- No crashes on invalid input.
- Repeated runs do not corrupt state (idempotency).

### Configuration & Environment
- Required env vars validated on startup, fail fast if missing.
- No hardcoded magic strings, URLs, or ports.
- No secrets committed to the repo.

### Logging & Observability
- Logs include timestamps and severity (INFO, WARN, ERROR).
- No silent failures.

### Security (Golden Rules)
- All user input validated or sanitized.
- Least privilege principle applied.
- Sensitive features off by default.

### Documentation & UX
- README: clone-to-run in fewer than 3 steps.
- Help commands or usage examples present.
- Web projects: WCAG AA contrast, mobile-responsive.

### Implementation Integrity
- No placeholder or stub code in production paths.
- Consistent naming conventions.
- README includes stack, license, troubleshooting.

## Usage

```
/mvp-readiness
```

Invoke in the root of your project. Claude audits the current working directory.

## Example Output

```markdown
## MVP Readiness Report — my-app — 2026-01-15

### Summary
**Status:** NOT READY
**Blockers:** 2

### Checklist Results
| # | Item | Status | Evidence |
|---|------|--------|----------|
| 1 | Error boundaries on external calls | PASS | All DB calls wrapped in try/catch |
| 2 | No crash on invalid input | FAIL | src/cli.ts:42 crashes on non-numeric --port |
...

### Blockers
- [#2] src/cli.ts:42 — Add input validation before parseInt call.
```

## Installation

```bash
./scripts/install.sh skills/mvp-readiness /path/to/your/project
```

## Related Skills

- `/golden-rules` — install always-on security and coding standards
- `/security-review` — deep security audit with OWASP coverage
- `/agent-based-development` — full multi-agent workflow with built-in MVP gate
