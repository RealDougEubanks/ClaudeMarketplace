# MVP Readiness Audit

Run a structured quality-gate audit before declaring any project an MVP. Check every item. Report pass/fail with evidence. Flag blockers.

## Instructions

1. Use Read to load `README.md` and any files found in `docs/`.

2. Use Glob to discover the project structure:
   - Source files: `src/**/*`, `lib/**/*`, `app/**/*` (adapt to the project layout)
   - Config files: `package.json`, `pyproject.toml`, `go.mod`, `.env.example`, `.gitignore`
   - Entry points: `index.*`, `main.*`, `server.*`, `app.*`

3. Use Grep to check for common problems across the codebase:
   - Hardcoded secret patterns: `password\s*=`, `api_key\s*=`, `SECRET\s*=`, `token\s*=` (case-insensitive, exclude `.env.example`)
   - Placeholder strings: `TODO`, `FIXME`, `impl later`, `stub`, `placeholder` (in source files only)
   - Missing error handling: look for calls to external systems (fetch, axios, db., fs., open(), connect()) without adjacent try/catch or .catch()

4. Use Read to check `.gitignore` for `.env` entries.

5. Use Grep to search `README.md` for setup instructions (clone, install, run).

6. For each checklist item below, determine: **PASS**, **FAIL**, or **N/A** (with written justification).

7. Produce the MVP Readiness Report (see Output Format).

## MVP Checklist

### 1. Stability & Error Handling
- [ ] All external calls (DB, API, file system) have try/catch/except blocks or equivalent error checks.
- [ ] The application does not crash on invalid input — provides a clean error message and exits/returns gracefully.
- [ ] Repeated runs do not cause duplicate data or corrupted state (idempotency, where applicable).

### 2. Configuration & Environment
- [ ] The app validates required environment variables or config files on startup and fails fast if missing.
- [ ] No hardcoded "magic strings," URLs, or ports — all moved to config or env.
- [ ] No secrets committed to the repo (`.gitignore` covers `.env` and credential files; Grep finds no secrets in code).

### 3. Logging & Observability
- [ ] Logs include timestamps and severity levels (INFO, WARN, ERROR).
- [ ] No silent failures — every error condition is logged with enough context to debug.

### 4. Security (Golden Rules)
- [ ] All user input (CLI args, HTTP params, file contents) is validated or sanitized before use.
- [ ] The app only requests minimum permissions it needs (least privilege).
- [ ] Sensitive features are off by default unless explicitly configured (secure defaults).

### 5. Documentation & UX
- [ ] README explains how to go from "clone" to "run" in fewer than 3 steps.
- [ ] Help commands (`--help`) or README usage examples are provided.
- [ ] (For web projects) Meets WCAG AA contrast and works on mobile.

### 6. Implementation Integrity
- [ ] No placeholder or "impl later" comments in production code paths.
- [ ] Naming follows camelCase (or the language convention documented in `docs/assumptions.md`).
- [ ] README includes stack, license, and troubleshooting sections.

## Output Format

Produce a markdown report in this exact format:

---

## MVP Readiness Report — <Project Name> — <Date>

### Summary

**Status:** READY / NOT READY
**Blockers:** <count>

### Checklist Results

| # | Item | Status | Evidence |
|---|------|--------|----------|
| 1 | Error boundaries on all external calls | PASS | All DB calls in src/db.ts wrapped in try/catch |
| 2 | No crash on invalid input | FAIL | CLI crashes with TypeError on non-numeric --port (src/cli.ts:42) |
| ... | | | |

### Blockers (must fix before MVP)

- [#2] `src/cli.ts:42` — CLI crashes on non-numeric --port. Add input validation before parseInt.

### N/A Items

- [#X] reason (e.g. "No web UI — accessibility check not applicable")

---

The project is **NOT MVP-ready** if any item is FAIL unless explicitly marked N/A with written justification.
