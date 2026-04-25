# Claude Code Skills Marketplace — Project Context

This is the **Claude Code Skills Marketplace** repository. It is a collection of reusable prompt skills for Claude Code — each skill is a directory under `skills/` containing a `commands/` subdirectory with the skill instruction file, `metadata.json` (machine-readable metadata), and `README.md` (human docs).

When working in this repo, your job is to help build, validate, and publish skills. Always follow the contribution conventions below.

## Contribution Conventions

- Skill directory names must be **kebab-case** (e.g. `git-workflow`, `golden-rules`).
- Each skill directory has this structure: `commands/<skill-name>.md` (with YAML frontmatter), `metadata.json`, `README.md`. There is NO `skill.md` at the root.
- `metadata.json` must validate against `schema/metadata.schema.json`.
- After creating or editing a skill, run `./scripts/validate.sh skills/<skill-name>`.
- After adding a skill directory, update `skills/registry.json` and run `./scripts/check-registry.sh`.
- Use `./scripts/new-skill.sh <name>` to scaffold a new skill from templates.
- Skills are distributed via the Claude Code marketplace — there is no manual install script. Direct users to add this repo as a marketplace in `~/.claude/settings.json`.
- Do not modify `skills/example-skill/` — it is the canonical reference for contributors.

## Pre-Commit Checklist (MANDATORY — run before every commit)

Always run these checks before committing. CI will fail if any are skipped.

1. **Validate skill structure** — `./scripts/validate.sh skills/<name>` for each changed skill.
2. **Sync registry versions** — `skills/registry.json` version must match `metadata.json` version for every skill. Update registry.json whenever you bump a skill version.
3. **Bump versions** — Any skill whose `commands/<name>.md`, `metadata.json`, or `README.md` changed must have its version incremented in **all four places**: `metadata.json`, `skills/registry.json`, `.claude-plugin/marketplace.json`, and `skills/<name>/.claude-plugin/plugin.json`. Use semver patch bumps for fixes, minor bumps for new features or layout changes.
4. **Run ShellCheck** — `shellcheck scripts/*.sh`. All scripts must pass with no errors.
5. **Run markdownlint** — `npx markdownlint-cli2 "skills/**/*.md" "*.md"`. No bare URLs — wrap emails and URLs in backticks or angle brackets.
6. **Check registry** — `./scripts/check-registry.sh` to confirm all three version fields agree.

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
- PRs targeting shared or release branches require at least one approval from a reviewer other than the author. For solo-maintainer repositories, self-merge is permitted — but CI must pass and the author must self-review the diff before merging.

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

CODE EFFICIENCY & DEPENDENCY HYGIENE (MANDATORY)

- Every line of code must have a clear purpose. No speculative abstractions, no dead branches, no unused exports, no "just in case" features.
- Minimize dependencies. Before adding a new package (npm, pip, cargo, NuGet, gem, go module), justify it: does the value outweigh the size, security surface, and maintenance cost? Prefer the standard library or a small focused implementation.
- Minimize binary and bundle size. Avoid heavyweight libraries when a small utility will do. Watch for dependency explosions — transitive bloat counts.
- Prefer clarity over cleverness. Avoid deep inheritance or abstraction layers that obscure what the runtime is actually doing — assume 80% of effort is debugging, so write code that is easy to step through.

RESOURCE STEWARDSHIP (MANDATORY)

- Treat RAM and CPU cycles as valuable commodities. Don't poll when you can subscribe; don't refresh when nothing changed; don't recompute what you can cache.
- Prefer async / non-blocking calls over sync calls when there is no added complexity penalty. Never block the UI thread on I/O (disk, network, IPC) — move it to a worker.
- Be cache- and allocation-aware in hot paths. Respect locality, batch work, and avoid unnecessary allocations or memory fragmentation, especially in native code (C/C++/Rust).
- Support a degraded or "lean" mode when the application could run on resource-constrained hardware. Failing to start is worse than degraded operation.
- Truthful telemetry: performance metrics must reflect actual system state. Do not smooth, round, or fabricate numbers for UI aesthetics.
- Apply language- and platform-specific best practices. The rules above describe intent; idiomatic implementation is contextual to the stack and the goals of the project.

PYTHON ENVIRONMENT (MANDATORY)

- Never install Python packages into the OS Python install. Always use a virtual environment.
- Create a venv at the project root: `python3 -m venv .venv`
- Activate before running or installing: `source .venv/bin/activate`
- Add `.venv/` to `.gitignore` — never commit it.
- Pin all dependencies in `requirements.txt` (or `pyproject.toml`). Use `pip freeze > requirements.txt` after installing.

CLAUDE CODE PLUGIN & SKILL LAYOUT (MANDATORY)

Skills and plugins installed via the Claude Code plugin system must follow this layout so they are discovered automatically as slash commands:

```
skills/<skill-name>/
  commands/
    <skill-name>.md     ← skill content with YAML frontmatter (name, description)
  metadata.json
  README.md
```

- The command file must be at `commands/<skill-name>.md` — NOT at `skill.md` in the plugin root.
- The YAML frontmatter in `commands/<skill-name>.md` must include `name` and `description` fields.
- Run `./scripts/validate.sh skills/<skill-name>` after creating or editing a skill.
- Use `./scripts/new-skill.sh <name>` to scaffold; it generates the correct structure automatically.

ASSUMPTIONS TRACKING

Any time a non-obvious decision is made, record it in docs/assumptions.md:
- Assumption: one clear sentence
- Why: rationale
- Recorded by: <agent or developer name>
- Date: YYYY-MM-DD
