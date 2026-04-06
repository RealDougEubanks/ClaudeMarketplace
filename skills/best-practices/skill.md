# Skill: best-practices

Invoked via `/best-practices`.

## Purpose

Audit an entire codebase against best practices for its detected language, framework, and architecture. Produce a prioritized improvement backlog — ordered by impact — with a level of effort estimate for each item. This is a strategic improvement advisor, not a PR reviewer.

---

## Instructions

### Step 1 — Stack Detection

Use Glob and Read to auto-detect the full technology stack:

**Language detection** (check for these files in order):
- TypeScript: `tsconfig.json`, `**/*.ts`
- JavaScript: `package.json`, `**/*.js`
- Python: `pyproject.toml`, `setup.py`, `requirements.txt`, `**/*.py`
- Go: `go.mod`, `**/*.go`
- Ruby: `Gemfile`, `**/*.rb`
- PHP: `composer.json`, `**/*.php`
- Java: `pom.xml`, `build.gradle`, `**/*.java`
- C#: `*.csproj`, `*.sln`, `**/*.cs`
- Rust: `Cargo.toml`, `**/*.rs`

**Framework detection** (read package.json / pyproject.toml / go.mod / composer.json):
- Frontend: React, Vue, Angular, Svelte, Next.js, Nuxt, Remix, Astro
- Backend: Express, Fastify, NestJS, FastAPI, Django, Flask, Rails, Laravel, Spring Boot, ASP.NET, Gin, Echo
- ORM/DB: Prisma, TypeORM, Sequelize, SQLAlchemy, Django ORM, GORM, ActiveRecord, Eloquent
- Testing: Jest, Vitest, pytest, Go test, RSpec, PHPUnit, JUnit, xUnit
- State: Redux, Zustand, Pinia, MobX

**Infrastructure detection:**
- Docker: `Dockerfile`, `docker-compose*.yml`
- CI/CD: `.github/workflows/**`, `bitbucket-pipelines.yml`, `.gitlab-ci.yml`
- Cloud: `serverless.yml`, `terraform/**`, `cdk/**`, `pulumi/**`
- Reverse proxy: `nginx.conf`, `apache.conf`

Report detected stack to the user before proceeding. Ask if anything is missing or incorrect.

---

### Step 2 — Codebase Mapping

Use Glob to build a structural map:
- Count files by type and directory
- Identify the largest files (likely complexity hotspots): find files > 300 lines
- Identify the entry points, main router, and key modules
- Check for test files and calculate approximate test coverage ratio (test files / source files)
- Look for documentation: `README.md`, `docs/`, inline docstrings/JSDoc, `CHANGELOG.md`, `CONTRIBUTING.md`

Use Read on:
- Entry points and main router
- The 5 largest source files
- Auth/session handling code
- Database models/schema
- Any existing architecture documentation

---

### Step 3 — Best Practices Audit

Run ALL checks below. Apply language/framework-specific checks only when that stack is detected.

---

#### UNIVERSAL CHECKS (all stacks)

**Code Structure:**
- [ ] Files > 300 lines — likely violates Single Responsibility Principle
- [ ] Functions > 30 lines — complex, hard to test
- [ ] Cyclomatic complexity > 10 (count if/else/switch/for/while/catch branches per function)
- [ ] Deeply nested code (> 4 levels of indentation)
- [ ] Duplicate logic blocks (same pattern repeated in 3+ places — DRY violation)
- [ ] Magic numbers/strings (unexplained literals that should be named constants)
- [ ] Dead code (commented-out blocks, unreachable code, unused exports)
- [ ] God files (one file doing too many unrelated things)

**Naming & Readability:**
- [ ] Inconsistent naming conventions across the codebase
- [ ] Unclear abbreviations in function/variable names (single letters outside loops)
- [ ] Boolean variable names not prefixed with `is`, `has`, `can`, `should`
- [ ] Functions named with nouns instead of verbs

**Error Handling:**
- [ ] Missing error handling on async operations (unhandled promise rejections, missing try/catch)
- [ ] Empty catch blocks (swallowing errors silently)
- [ ] Generic error messages returned to callers without context
- [ ] No top-level error boundary / global error handler

**Testing:**
- [ ] Source files with no corresponding test file
- [ ] Test files with only happy-path cases (no edge cases, no error cases)
- [ ] Tests that test implementation details rather than behavior
- [ ] No integration tests for critical user flows
- [ ] Test coverage ratio < 60%

**Documentation:**
- [ ] Missing or empty README
- [ ] README lacks: setup instructions, environment variables, how to run tests, architecture overview
- [ ] Public functions/methods without docstrings or JSDoc
- [ ] No CHANGELOG or CONTRIBUTING guide
- [ ] Unresolved TODO/FIXME comments in source (count and flag as debt)

**Dependencies:**
- [ ] Unpinned dependency versions
- [ ] Missing lockfile
- [ ] Significantly outdated dependencies (major versions behind)
- [ ] Unused dependencies (in package.json/requirements.txt but not imported anywhere)
- [ ] Dev dependencies in production dependencies list

**Configuration:**
- [ ] No `.env.example` documenting required environment variables
- [ ] Hard-coded environment-specific values (URLs, ports, hostnames) in source
- [ ] No validation of required env vars on startup
- [ ] Sensitive defaults (e.g. debug mode default to true)

**Performance:**
- [ ] Synchronous operations that could be async (blocking the event loop)
- [ ] Missing pagination on list operations
- [ ] N+1 query patterns (query inside a loop)
- [ ] Missing caching for expensive repeated computations
- [ ] Unnecessary sequential awaits that could be parallelized (`await a; await b` → `Promise.all`)

**Architecture:**
- [ ] No clear separation of concerns (business logic in route handlers, DB queries in controllers)
- [ ] Circular dependencies between modules
- [ ] Direct coupling to third-party services (no abstraction layer / interface)
- [ ] No dependency injection — hard-coded dependencies make unit testing impossible
- [ ] Monolithic files that mix multiple responsibilities

---

#### JAVASCRIPT / TYPESCRIPT

- [ ] `any` type used extensively — defeats TypeScript's purpose
- [ ] Missing `strict: true` in `tsconfig.json`
- [ ] `var` instead of `const`/`let`
- [ ] `==` instead of `===`
- [ ] `console.log` left in production code paths
- [ ] No ESLint or Prettier config
- [ ] Missing `.eslintrc` rules for security (`no-eval`, `no-implied-eval`)
- [ ] `require()` mixed with ES module `import`
- [ ] Callback-style async code instead of async/await
- [ ] Missing `package.json` `engines` field (Node version not specified)

**React (if detected):**
- [ ] `useEffect` with missing or incorrect dependency array
- [ ] Missing `key` prop on list items
- [ ] State mutation instead of returning new state
- [ ] Large components doing data fetching + rendering + business logic (should split)
- [ ] No error boundaries around critical UI sections
- [ ] Prop drilling more than 2 levels deep (consider context or state management)
- [ ] Inline function definitions in JSX causing unnecessary re-renders
- [ ] Images without `alt` attributes (accessibility)

**Node/Express (if detected):**
- [ ] Error handling middleware not registered last
- [ ] Missing `helmet` for HTTP security headers
- [ ] Missing rate limiting middleware
- [ ] `app.use(express.json({ limit: '50mb' }))` — unnecessarily large body limit
- [ ] Routes not grouped by resource with consistent naming
- [ ] Synchronous file operations (`fs.readFileSync`) in request handlers

---

#### PYTHON

- [ ] Missing type hints on function signatures (Python 3.5+)
- [ ] No virtual environment documentation (`venv`, `poetry`, `pipenv`)
- [ ] `requirements.txt` without pinned versions (`==`)
- [ ] Mutable default arguments (`def foo(lst=[]): ...`)
- [ ] Bare `except:` clauses (catches everything including `KeyboardInterrupt`)
- [ ] `print()` statements in non-script code (use `logging`)
- [ ] No `__all__` in modules with public API
- [ ] Missing `if __name__ == "__main__":` guard in scripts
- [ ] F-string vs `%s` vs `.format()` inconsistency
- [ ] No linting config (`flake8`, `ruff`, `pylint`, `mypy`)

**Django (if detected):**
- [ ] `DEBUG = True` not restricted to development
- [ ] `ALLOWED_HOSTS = ['*']` in production settings
- [ ] Raw SQL queries instead of ORM
- [ ] Missing `select_related`/`prefetch_related` (N+1 queries)
- [ ] No `__str__` method on models
- [ ] Signals used for business logic (hard to trace)
- [ ] No database indexes on frequently filtered/ordered fields

**FastAPI (if detected):**
- [ ] Response models not defined (returns arbitrary dict)
- [ ] Missing request validation (Pydantic models not used)
- [ ] No dependency injection for auth/db
- [ ] Background tasks used for long-running work instead of a queue

---

#### GO

- [ ] Errors not wrapped with context (`fmt.Errorf("doing X: %w", err)`)
- [ ] `_` used to discard errors
- [ ] Goroutines launched without `WaitGroup` or done channel (goroutine leak risk)
- [ ] `context.Background()` used in request handlers (should use request context)
- [ ] Global variables used for state (not testable)
- [ ] No `golangci-lint` config
- [ ] Packages named with generic names (`util`, `common`, `helper`, `misc`)
- [ ] Missing `defer` for resource cleanup (file handles, mutexes)
- [ ] Struct fields not documented

---

#### DATABASE / ORM

- [ ] No database migrations — schema changes applied manually
- [ ] Migrations not versioned or stored in the repo
- [ ] Missing indexes on foreign keys
- [ ] Missing indexes on columns used in `WHERE`, `ORDER BY`, `GROUP BY`
- [ ] `SELECT *` queries (over-fetching)
- [ ] No soft-delete pattern for business-critical records
- [ ] Transactions not used for multi-step operations that must be atomic
- [ ] No connection pooling configuration
- [ ] Passwords or PII stored without hashing/encryption

---

#### DOCKER / INFRASTRUCTURE

- [ ] Base image uses `latest` tag instead of pinned version
- [ ] Running as root user in container
- [ ] No `.dockerignore` (copies node_modules, .git, .env into image)
- [ ] Secrets passed as `ENV` or `ARG` in Dockerfile
- [ ] Large image size (unnecessary build tools in final image — use multi-stage builds)
- [ ] No health check defined
- [ ] No resource limits defined (memory, CPU)

---

#### CI/CD

- [ ] No automated tests in CI pipeline
- [ ] No linting step in CI
- [ ] No dependency vulnerability scanning in CI
- [ ] No branch protection / required status checks on `main`
- [ ] Secrets hardcoded in workflow files instead of CI secrets store
- [ ] No deployment rollback mechanism
- [ ] No staging environment before production

---

### Step 4 — Prioritize and Score Findings

For each finding, assign:

**Priority** (what to fix first):
- **P1 — Critical**: Actively harmful, blocking team velocity, or causing bugs in production
- **P2 — High**: Significant technical debt; will compound if not addressed soon
- **P3 — Medium**: Meaningful improvement; plan for next quarter
- **P4 — Low**: Nice to have; address opportunistically

**Priority is determined by:**
1. Impact on correctness / reliability (bugs, crashes, data loss) → highest
2. Impact on security (already covered by `/security-review` but flag anything missed)
3. Impact on maintainability and team velocity
4. Impact on performance (user-facing)
5. Impact on developer experience

**Level of Effort:**
- **XS** (< 1 hour): Simple find-and-replace, add a config line, rename a variable
- **S** (1–4 hours): Refactor a function, add tests for a module, fix error handling across a file
- **M** (1–2 days): Extract a service layer, add integration tests, set up linting across the project
- **L** (3–5 days): Restructure a major module, add comprehensive test coverage, migrate to a new pattern
- **XL** (1+ week): Architectural change, migration to new framework feature, adding a new infrastructure layer

Sort ALL findings by: P1 first, then P2, P3, P4. Within each priority, sort by lowest effort first (quick wins at top).

---

### Step 5 — Output the Report

```markdown
## Best Practices Report — <Project Name> — <Date>

### Stack Detected
| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5.x |
| Framework | Next.js 14 (App Router) |
| ORM | Prisma |
| Testing | Jest + React Testing Library |
| CI/CD | GitHub Actions |

### Summary
**Total findings:** X
| Priority | Count |
|----------|-------|
| P1 Critical | X |
| P2 High | X |
| P3 Medium | X |
| P4 Low | X |

**Estimated total effort to address all findings:** X–Y days

---

### Improvement Roadmap

#### P1 — Critical (fix immediately)

---

**[P1] No error handling middleware — unhandled errors crash the server**
- **Location:** `src/app.ts` — no global error handler registered
- **Why it matters:** Any unhandled exception in a route kills the Node process. Users see a 502 with no useful error message. This is a reliability blocker.
- **Effort:** XS (< 1 hour)
- **Fix:**
  ```typescript
  // Add as the last middleware in app.ts
  app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
    logger.error({ err, path: req.path }, 'Unhandled error');
    res.status(500).json({ error: 'Internal server error' });
  });
  ```

---

**[P1] 14 source files have zero test coverage**
- **Location:** `src/services/`, `src/lib/`
- **Why it matters:** Business logic with no tests means any change can silently break behaviour. Identified files: [list them]
- **Effort:** L (3–5 days to add meaningful coverage)
- **Fix:** Run `/test-writer` on each untested file. Start with `src/services/billing.ts` — highest business risk.

---

#### P2 — High (address this sprint or next)

---

**[P2] TypeScript `strict` mode disabled — 47 implicit `any` types found**
- **Location:** `tsconfig.json:8`
- **Why it matters:** Without strict mode, TypeScript's safety guarantees are significantly weakened. Runtime errors that TypeScript would catch are silently allowed through.
- **Effort:** M (1–2 days to enable strict and fix resulting errors)
- **Fix:**
  ```diff
  // tsconfig.json
  - "strict": false
  + "strict": true
  ```

---

#### P3 — Medium (plan for next quarter)

#### P4 — Low (address opportunistically)

---

### Quick Wins (P1–P2, Effort XS or S)
A condensed list of the highest-impact, lowest-effort items — tackle these first:

| # | Finding | Priority | Effort |
|---|---------|----------|--------|
| 1 | Add global error handler | P1 | XS |
| 2 | Add `.env.example` | P2 | XS |
| 3 | Enable ESLint | P2 | S |

---

### Suggested Next Steps
1. Run `/security-review` for a dedicated security audit (complements this report).
2. Run `/test-writer` on the untested service files.
3. Run `/dependency-audit` to check for CVEs and outdated packages.
4. Schedule a 1-hour "quick wins" session to knock out all XS items.
```

---

### Step 6 — ABD Integration

If `handoffs/` exists, offer to write the findings as a Planning artifact to `handoffs/plans/` so the agent-based-development workflow can pick them up as tasks.
