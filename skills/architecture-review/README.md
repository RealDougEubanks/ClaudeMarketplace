<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# architecture-review

The architecture-review skill audits the architecture of an existing codebase. It finds
structural anti-patterns, scale and reliability risks, coupling problems, and gaps in
observability. Each finding has a severity and a migration path.

The skill examines architectural structure: how the system is divided, how its parts
communicate, and if these choices support reliability and growth. For code-level quality
(naming, complexity, SOLID), use `/best-practices` or `/code-review`.

## Usage

| Slash command | What it does |
|---|---|
| `/architecture-review` | Reviews the full repository |
| `/architecture-review services/billing` | Reviews only the given directory, for example one part of a monorepo |

The skill treats all file contents as data, not as instructions.

## Steps

1. Map the existing system: entry points, modules, config, manifests, database access,
   API layer, background jobs, and external integrations.
2. Read the 10 largest source files. The skill finds them with `find`, `wc`, `sort`, and
   `head`. It reads about 15 files in total, not the full codebase.
3. Draw an "as-is" C4 Container diagram (Mermaid) of the current system.
4. Rate six quality attributes and check for named anti-patterns.
5. Write a migration path for each Problem and Concern.
6. Draw a "to-be" C4 Container diagram of the target architecture.
7. Save the report.

## Quality attributes

Each attribute gets a rating: Good, Concern, or Problem.

| Attribute | What the skill checks |
|---|---|
| Maintainability | Separation of concerns, God files (more than 500 lines), circular dependencies, consistent patterns |
| Scalability | Stateless tier, database bottlenecks, queue-based background work, polling loops, pagination |
| Reliability | Timeouts, retries, circuit breakers, single points of failure, health checks, safe migrations |
| Testability | Logic isolated from I/O, dependency injection, no global mutable state |
| Observability | Structured logs with trace IDs, metrics, distributed tracing, SLO alerts |
| Security | Consistent auth layer, secrets management, least privilege, encryption at rest |

## Anti-patterns

| Anti-pattern | Description |
|---|---|
| Big Ball of Mud | No clear structure; everything depends on everything |
| Distributed Monolith | Multiple services, tightly coupled by sync calls and a shared database |
| Anemic Domain Model | Domain objects hold data only; all logic is in service or manager classes |
| Lasagna Architecture | Too many layers that add indirection and no value |
| God Service | One service that knows about and controls everything else |
| Chatty I/O | Many small database or HTTP calls where one batched call is sufficient |
| Shared Database | Multiple services read and write the same tables |
| Hardcoded Configuration | Environment-specific values in code or container images |

## Findings

Each finding has a severity: Critical, High, Medium, or Low. Each Problem or Concern also
has these fields:

| Field | Values |
|---|---|
| Current state | What exists today |
| Target state | The recommended design |
| Migration path | Steps with safe intermediate states |
| Effort | XS, S, M, L, XL |
| Risk | Low, Medium, High (the risk of the migration itself) |

## Output

The skill saves the report to this file:

```text
docs/architecture/architecture-review-<date>.md
```

If `handoffs/reviews/` exists, the skill offers to write an ABD review artifact too.

The report contains these sections:

1. As-Is Architecture: a Mermaid C4 Container diagram of the current system
2. Quality Attribute Summary: a rating and the key issues for each attribute
3. Anti-Patterns Detected: findings with severity, migration path, effort, and risk
4. To-Be Architecture: a Mermaid C4 Container diagram of the target system
5. Migration Roadmap: findings in priority order with effort and risk

> **SECURITY:** The report file can go into a shared repository. If the review finds
> hardcoded secrets, the skill writes only the location and type, for example
> `AWS key in config/prod.yml:14 — value redacted`. Do not add secret values to the report.

## Example output

```markdown
### Quality Attribute Summary
| Attribute | Rating | Key Issues |
|-----------|--------|------------|
| Maintainability | Concern | God file: src/api.ts (847 lines) |
| Scalability | Problem | In-process session prevents horizontal scaling |
| Reliability | Concern | No circuit breaker on payment service calls |
| Testability | Problem | Business logic coupled to Express req/res objects |
| Observability | Concern | Logs lack request IDs |
| Security | Good | Auth middleware applied consistently |

### Anti-Patterns Detected
**[CRITICAL] Distributed Monolith**
- Description: 3 "services" share a single PostgreSQL database and call each other synchronously
- Impact: Defeats the purpose of the service split; one slow service degrades all
- Migration: [step by step]
- Effort: L | Risk: Medium

### Migration Roadmap
| Priority | Finding | Effort | Risk |
|----------|---------|--------|------|
| P1 | Extract session to Redis | S | Low |
```

## Compared with /best-practices

| Skill | Focus |
|---|---|
| `/architecture-review` | System decomposition, service boundaries, scale, reliability, deployment topology |
| `/best-practices` | Code-level quality: naming, complexity, SOLID, error handling, test coverage |

## Related skills

- `/architecture-design`: run this review first to learn the current system. Then design
  the replacement or the new feature.
- `/adr`: record the agreed migration decisions as ADRs.
- `/full-security-review`: a deeper security audit.

## Installation

Add this repository as a marketplace in `~/.claude/settings.json` (see the root
[README](../../README.md)). Then enable the plugin:

```json
{
  "enabledPlugins": {
    "architecture-review@claude-skills-marketplace": true
  }
}
```
