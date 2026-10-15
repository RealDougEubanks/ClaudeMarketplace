<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# best-practices

The best-practices skill audits a full codebase. It detects the technology stack and checks
the code against best practices for that language, framework, and infrastructure. The result
is a prioritized improvement roadmap. Each finding has a priority and a level-of-effort
estimate.

---

## How it differs from related skills

| Skill | Scope |
|-------|-------|
| `/code-review` | Engineering quality of the changed files on a branch, or of a path that you name |
| `/full-security-review` | Security findings only: injection, auth, secrets, cryptography |
| `/mvp-readiness` | Pass/fail launch checklist |
| `/best-practices` | Full codebase audit, stack-aware, with a prioritized roadmap |

Use `/best-practices` to see where the codebase stands and what to improve next. Use the
other skills for targeted reviews.

---

## Supported stacks

### Languages

| Language | Detection |
|----------|-----------|
| TypeScript | `tsconfig.json`, `**/*.ts` |
| JavaScript | `package.json`, `**/*.js` |
| Python | `pyproject.toml`, `setup.py`, `requirements.txt`, `**/*.py` |
| Go | `go.mod`, `**/*.go` |
| Ruby | `Gemfile`, `**/*.rb` |
| PHP | `composer.json`, `**/*.php` |
| Java | `pom.xml`, `build.gradle`, `**/*.java` |
| C# | `*.csproj`, `*.sln`, `**/*.cs` |
| Rust | `Cargo.toml`, `**/*.rs` |

JavaScript, TypeScript, Python, and Go have dedicated checklists. Ruby, PHP, Java, C#, and
Rust get the universal checks only. The report states when language-specific checks were
out of scope.

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

## Usage

```
/best-practices [path] [--only=<categories>]
```

| Argument | Effect |
|----------|--------|
| *(none)* | Full audit of the whole repository |
| `path` | Limit the audit to this directory |
| `--only=<categories>` | Run only the named sections (comma-separated) |

Valid `--only` categories:

- Universal: `structure`, `naming`, `errors`, `testing`, `docs`, `dependencies`, `config`,
  `performance`, `memory`, `input-bounds`, `logging`, `health`, `caching`, `copy`,
  `architecture`
- Stack: `javascript`, `python`, `go`, `database`, `docker`, `cicd`

Examples:

```
/best-practices
/best-practices services/api
/best-practices --only=logging,health,caching
```

The skill does these steps:

1. Detect the technology stack and ask you to confirm it.
2. Map the codebase: file counts, the largest files, and the test-to-source ratio.
3. Run the checks one section at a time, in order.
4. Give each finding a priority and an effort size.
5. Write the roadmap in the report format.
6. If a `handoffs/` directory exists, offer to save the findings to `handoffs/plans/`.

The skill loads stack checklists from `checklists/` only for the stacks that it detects.

---

## Priority levels

| Priority | Meaning |
|----------|---------|
| P1 Critical | Causes production bugs, harms the code, or blocks team velocity. Fix immediately. |
| P2 High | Technical debt that grows over time. Fix this sprint or next. |
| P3 Medium | A useful improvement. Plan it for next quarter. |
| P4 Low | Nice to have. Fix it when you are in that code. |

The skill sets priority in this order: correctness and reliability, then security,
maintainability, performance, and developer experience.

---

## Level-of-effort estimates

| Size | Range | Examples |
|------|-------|---------|
| XS | < 1 hour | Add a config line, rename a variable, add `.env.example` |
| S | 1–4 hours | Refactor a function, add tests for a module, fix error handling in a file |
| M | 1–2 days | Extract a service layer, set up linting, add integration tests |
| L | 3–5 days | Restructure a major module, add broad test coverage, migrate to a new pattern |
| XL | 1+ week | Architectural change, framework migration, new infrastructure layer |

In each priority tier, the report sorts findings by effort, smallest first. Quick wins come
first.

---

## Use the findings with agent-based-development

If your project has a `handoffs/` directory, the skill offers to write the findings as a
Planning artifact to `handoffs/plans/`. The agent-based-development workflow can then use
them as tasks.

A typical sequence:

```
/best-practices          → get the full roadmap
/full-security-review    → dedicated security deep-dive (complements this report)
/test-writer             → generate tests for untested files identified in the report
/dependency-audit        → CVE scan and outdated package check
```

Start with the Quick Wins table at the end of the report. It lists P1 and P2 findings with
effort XS or S.

> **SECURITY:** The report redacts hardcoded secrets. It shows only the location and the
> type of each secret. Rotate any secret that the report finds, because it is already in
> the repository history.

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

The full report layout is in `templates/report-format.md`.

---

## Installation

Add this repository as a marketplace in `~/.claude/settings.json`, then enable the plugin:

```json
{
  "enabledPlugins": {
    "best-practices@claude-skills-marketplace": true
  }
}
```

---

## Author

Doug Eubanks — [github.com/RealDougEubanks](https://github.com/RealDougEubanks)

## License

MIT
