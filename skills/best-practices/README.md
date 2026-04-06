# best-practices

A holistic codebase audit skill for Claude Code. Auto-detects your technology stack and checks it against best practices for that specific language, framework, and architecture. Produces a prioritized improvement roadmap with a level-of-effort estimate for every finding.

---

## How it differs from related skills

| Skill | What it does |
|-------|-------------|
| `/code-review` | Reviews a PR diff — focused on what changed in this pull request |
| `/security-review` | Security vulnerabilities only — injection, auth, secrets, cryptography |
| `/mvp-readiness` | Binary pass/fail launch checklist — is this ready to ship? |
| `/best-practices` | **Holistic audit of the entire codebase** — stack-aware, produces a prioritized improvement roadmap |

Use `/best-practices` when you want a strategic picture of where the codebase stands and what to improve next. Use the other skills for targeted reviews.

---

## Supported stacks

### Languages

| Language | Detection |
|----------|-----------|
| TypeScript | `tsconfig.json`, `**/*.ts` |
| JavaScript | `package.json`, `**/*.js` |
| Python | `pyproject.toml`, `setup.py`, `requirements.txt` |
| Go | `go.mod`, `**/*.go` |
| Ruby | `Gemfile`, `**/*.rb` |
| PHP | `composer.json`, `**/*.php` |
| Java | `pom.xml`, `build.gradle` |
| C# | `*.csproj`, `*.sln` |
| Rust | `Cargo.toml` |

### Frameworks

| Layer | Supported |
|-------|-----------|
| Frontend | React, Vue, Angular, Svelte, Next.js, Nuxt, Remix, Astro |
| Backend | Express, Fastify, NestJS, FastAPI, Django, Flask, Rails, Laravel, Spring Boot, ASP.NET, Gin, Echo |
| ORM/DB | Prisma, TypeORM, Sequelize, SQLAlchemy, Django ORM, GORM, ActiveRecord, Eloquent |
| Testing | Jest, Vitest, pytest, Go test, RSpec, PHPUnit, JUnit, xUnit |
| State | Redux, Zustand, Pinia, MobX |

### Infrastructure

| Layer | Supported |
|-------|-----------|
| Containers | Docker, docker-compose |
| CI/CD | GitHub Actions, GitLab CI, Bitbucket Pipelines |
| Cloud IaC | Terraform, CDK, Pulumi, Serverless Framework |
| Reverse proxy | nginx, Apache |

---

## How to invoke

```
/best-practices
```

Run this from the root of any project. No arguments required — stack detection is automatic.

Claude will:
1. Detect your full technology stack and confirm it with you
2. Map the codebase structure (file counts, largest files, test coverage ratio)
3. Run all applicable best-practice checks for your detected stack
4. Score every finding by priority and level of effort
5. Output a structured improvement roadmap

---

## Priority levels

| Priority | Meaning |
|----------|---------|
| P1 Critical | Actively harmful, blocking velocity, or causing production bugs — fix immediately |
| P2 High | Significant technical debt that will compound — address this sprint or next |
| P3 Medium | Meaningful improvement — plan for next quarter |
| P4 Low | Nice to have — address opportunistically |

Priority is determined by: correctness/reliability impact first, then security, maintainability, performance, and developer experience.

---

## Level-of-effort estimates

| Size | Range | Examples |
|------|-------|---------|
| XS | < 1 hour | Add a config line, rename a variable, add `.env.example` |
| S | 1–4 hours | Refactor a function, add tests for a module, fix error handling in a file |
| M | 1–2 days | Extract a service layer, set up linting, add integration tests |
| L | 3–5 days | Restructure a major module, add broad test coverage, migrate to a new pattern |
| XL | 1+ week | Architectural change, framework migration, new infrastructure layer |

Within each priority tier, findings are sorted by effort ascending — so quick wins surface first.

---

## Using findings with the agent-based-development workflow

If your project uses the `agent-based-development` skill and has a `handoffs/` directory, `/best-practices` will offer to write the findings as a Planning artifact to `handoffs/plans/`. The ABD workflow can then pick these up as actionable tasks.

Recommended workflow:

```
/best-practices          → get the full roadmap
/security-review         → dedicated security deep-dive (complements this report)
/test-writer             → generate tests for untested files identified in the report
/dependency-audit        → CVE scan and outdated package check
```

Start with the Quick Wins table at the end of the report — these are P1/P2 items that take under 4 hours each and deliver the highest return on time invested.

---

## Example output structure

```
## Best Practices Report — my-app — 2026-04-06

### Stack Detected
| Layer | Technology |
|-------|-----------|
| Language | TypeScript 5.x |
| Framework | Next.js 14 (App Router) |
| ORM | Prisma |
| Testing | Jest + React Testing Library |
| CI/CD | GitHub Actions |

### Summary
Total findings: 23
P1 Critical: 2 | P2 High: 7 | P3 Medium: 9 | P4 Low: 5
Estimated total effort: 8–14 days

### Improvement Roadmap
#### P1 — Critical (fix immediately)
...

### Quick Wins (P1–P2, Effort XS or S)
...

### Suggested Next Steps
...
```

---

## Author

Doug Eubanks — [github.com/RealDougEubanks](https://github.com/RealDougEubanks)

## License

MIT
