---
name: golden-rules
description: Installs mandatory security, coding, naming, design, testing, error handling, API contract, and performance standards into CLAUDE.md as always-on context for every Claude Code session.
---

# Golden Rules — Always-On Project Standards

Install mandatory security, coding, design, testing, error handling, API contract, and performance standards into this project's CLAUDE.md so they are active for every Claude Code session automatically.

## Instructions

1. Use Read to check if `./CLAUDE.md` exists in the current working directory.

2. Use Grep to search `./CLAUDE.md` for the string `## Golden Rules` (if the file exists).
   - If the section header is found: inform the user the Golden Rules are already installed and stop.
   - If not found: proceed to step 3.

3. If `CLAUDE.md` does not exist, use Write to create it with the Golden Rules Block below as the full content.
   If `CLAUDE.md` exists but lacks the section, use Edit to append the Golden Rules Block to the end of the file.

4. Confirm to the user what was written and that the Golden Rules are now active for every Claude Code session in this project.

## Golden Rules Block

Write or append the following content verbatim:

---

## Golden Rules

GOLDEN RULES (MANDATORY — ALL WORK IN THIS PROJECT MUST FOLLOW THESE)

1. Security is paramount. Every design, implementation, and review decision must prioritize security. When in doubt, choose the more secure option and document the assumption in docs/assumptions.md.

2. Do not store secrets, passwords, keys, PII, or other sensitive data insecurely.
   - Passwords: Hash with a strong adaptive function (Argon2, bcrypt, scrypt). Never store plaintext or reversibly encrypted passwords.
   - API keys, tokens, secrets: Use environment variables or a secrets manager. Never commit to the repo or log.
   - PII: Encrypt at rest and in transit. Minimize collection and retention. Follow applicable privacy rules.
   - Other sensitive data: Use encryption or hashing as appropriate. Document non-obvious choices in docs/assumptions.md.

3. Always assume the application could be the target of exploitation. Design for untrusted input, defense in depth, least privilege, and secure defaults. Document any accepted risks in docs/assumptions.md.

CODING & NAMING GUIDELINES (apply unless project explicitly overrides in docs/assumptions.md)

- camelCase for variables, functions, and filenames (see language-specific table below).
- Language-specific naming conventions:

  | Language | Variables/Functions | Files | Classes |
  |----------|-------------------|-------|---------|
  | JavaScript/TypeScript | camelCase | camelCase | PascalCase |
  | Python | snake_case | snake_case | PascalCase |
  | Go | camelCase (unexported) / PascalCase (exported) | snake_case | PascalCase |
  | SQL | snake_case | snake_case | N/A |
  | CSS classes | kebab-case | kebab-case | N/A |

- Strict typing and schema validation (e.g. Zod, Pydantic, or language-equivalent) for all inputs and boundaries.
- No hardcoded API keys, credentials, or secrets — use configuration or secrets management.
- No placeholder or stub code in production paths — write complete, functional code.
- Move task notes to docs/ToDo.md or docs/ — do not leave // TODO in the codebase for project tracking.
- Remove dead code before committing — commented-out code blocks, unused imports, unreachable functions, and orphaned files are not acceptable in production paths.

DESIGN & UX GUIDELINES (apply unless project explicitly overrides)

- Caching: Prefer designs that support caching where appropriate (HTTP cache headers, CDN, app-level) to improve performance.
- Light and dark mode: Support both themes with easy switching (toggle, system preference, or both). Persist user preference.
- Visual design: Prefer minimalist, clean designs. Avoid clutter; use clear hierarchy and whitespace.
- Responsive design: Layouts must be responsive — usable across mobile, tablet, and desktop. Use fluid layouts and touch-friendly targets.
- Accessibility: Choose accessible and pleasant color palettes. WCAG AA contrast minimum. Do not rely on color alone for meaning.

GIT HYGIENE (MANDATORY)

- Never commit or push directly to `main`. All changes must go through a branch and PR, no exceptions.
- Branch from the current release branch (or `main` if no release branch exists). Name branches `feature/`, `fix/`, `hotfix/`, or `claude/` as appropriate.
- If you find yourself on `main` with uncommitted changes, stash or move them to a new branch before committing.
- No PR may be merged without at least one approval from a reviewer other than the author. Self-merge is not permitted.

TESTING STANDARDS (MANDATORY)

- Every module with logic must have corresponding tests. No untested business logic in production.
- Name tests descriptively: `test_<unit>_<scenario>_<expected>` or `describe/it` equivalents. A failing test name must explain what broke.
- Test behavior, not implementation. Mock external dependencies; do not mock the unit under test.
- Write the test first when fixing a bug — reproduce it as a failing test, then fix.
- Do not test framework internals, trivial getters/setters, or auto-generated code.
- Integration tests must cover critical paths: auth flows, payment flows, and data persistence boundaries.
- Tests must be deterministic — no flaky tests. Remove or fix any test that fails intermittently.

ERROR HANDLING (MANDATORY)

- Never swallow exceptions silently. Every catch block must log, re-throw, or return a meaningful error.
- Use structured error objects with a machine-readable code, human-readable message, and optional context. No bare string throws.
- Log errors with severity level, timestamp, request/correlation ID, and enough context to reproduce. No PII in logs.
- Distinguish client errors (4xx / validation) from server errors (5xx / unexpected). Return appropriate status codes.
- Fail fast on invalid state. Validate preconditions at function entry; do not let bad data propagate.
- Define and use a project-wide error hierarchy or error code enum. No ad-hoc error strings scattered across the codebase.

API & DATA CONTRACTS (MANDATORY)

- Validate all inputs at system boundaries with schema validation (Zod, Pydantic, JSON Schema, or equivalent). Reject invalid payloads before processing.
- Sanitize all user-supplied strings before use in queries, templates, or downstream calls. Assume all external input is hostile.
- Version APIs explicitly (URL path, header, or query param). Never introduce breaking changes to an existing version.
- Backward compatibility is required for at least one prior version. Deprecate before removing — never drop fields or endpoints without notice.
- Document every public endpoint or contract with request/response schemas. Undocumented APIs are not shippable.
- Use consistent naming across all API surfaces: plural resource nouns, standard HTTP verbs, consistent date/enum formats.

PERFORMANCE BASICS (MANDATORY)

- No N+1 queries. Use eager loading, joins, or batch fetches. Profile queries on realistic data volumes before shipping.
- All list endpoints must support pagination. No unbounded result sets. Default to reasonable page sizes.
- Use async/non-blocking I/O for network calls, file I/O, and any operation that can block the event loop or thread pool.
- Cache expensive computations and frequently-read data. Define TTLs and invalidation strategy — no stale-forever caches.
- Set timeouts on every external call (HTTP, DB, queue). No indefinite waits. Define retry policy with backoff for transient failures.
- Do not optimize prematurely, but do not ship known O(n^2) or worse algorithms on unbounded inputs. Document accepted performance trade-offs in docs/assumptions.md.

ASSUMPTIONS TRACKING

Any time a non-obvious decision is made, record it in docs/assumptions.md:
- Assumption: one clear sentence
- Why: rationale
- Recorded by: <agent or developer name>
- Date: YYYY-MM-DD

---

## Output Format

Report to the user:
- Whether `CLAUDE.md` was created new or updated (appended).
- That the `## Golden Rules` section is now active.
- That every future Claude Code session in this project directory will load these rules automatically as context.
