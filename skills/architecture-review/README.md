# architecture-review

Audit the architecture of an existing codebase for structural problems, scalability risks, and fitness for purpose. Produces graded findings with migration recommendations.

## Purpose

`/architecture-review` performs a systematic architectural audit of a real codebase. It reads the code, reconstructs an "as-is" architecture diagram, grades six quality attributes, detects named anti-patterns, and produces a prioritised migration roadmap — with a "to-be" architecture diagram showing the target state.

This skill focuses on **architectural structure**: how the system is decomposed, how components communicate, and whether those choices support reliability and growth. For code-level quality (naming, complexity, SOLID), use `/best-practices` or `/code-review`.

## Invocation

```
/architecture-review
```

Run this from the root of the project you want to review. Claude will explore the codebase automatically.

## Quality Attributes Assessed

| Attribute | What is checked |
|-----------|-----------------|
| Maintainability | Separation of concerns, God files, circular deps, consistent patterns |
| Scalability | Stateless tier, connection pooling, queue-based background work, pagination |
| Reliability | Timeouts/retries/circuit breakers, health checks, safe migrations |
| Testability | Logic isolated from I/O, dependency injection, no global mutable state |
| Observability | Structured logs with trace IDs, metrics, distributed tracing, alerting |
| Security | Consistent auth layer, secrets management, least privilege, encryption at rest |

Each attribute is rated: Good / Concern / Problem.

## Anti-Patterns Detected

The skill explicitly checks for these named anti-patterns:

| Anti-Pattern | Description |
|--------------|-------------|
| Big Ball of Mud | No discernible structure; everything depends on everything |
| Distributed Monolith | Multiple services but tightly coupled via sync calls and a shared DB |
| Anemic Domain Model | Domain objects are data bags; all logic in service/manager classes |
| Lasagna Architecture | Too many unnecessary layers adding indirection without value |
| God Service | One service that knows about and orchestrates everything else |
| Chatty I/O | Many small DB/HTTP calls where one batched call would suffice |
| Shared Database | Multiple services reading/writing the same tables |
| Hardcoded Configuration | Environment-specific values baked into code or container images |

## Output Format

```
docs/architecture/architecture-review-<date>.md
```

The report contains:
1. **As-Is Architecture** — Mermaid C4 Container diagram of what exists today
2. **Quality Attribute Summary** — table with ratings and key issues per attribute
3. **Anti-Patterns Detected** — graded findings (Critical/High/Medium/Low) with migration paths, effort, and risk
4. **To-Be Architecture** — Mermaid C4 Container diagram of the recommended target state
5. **Migration Roadmap** — prioritised table linking findings to effort and risk

## How it Differs from `/best-practices`

| Skill | Focus |
|-------|-------|
| `/architecture-review` | System decomposition, service boundaries, scalability, reliability, deployment topology |
| `/best-practices` | Code-level quality: naming, complexity, SOLID, error handling, test coverage |

Use both for a complete quality picture.

## Integration with Other Skills

- **`/architecture-design`** — Use this skill to understand an existing system before designing a replacement or major new feature with `/architecture-design`.
- **`/adr`** — After completing the review, record the agreed migration decisions as Architecture Decision Records.
- **`/security-review`** — For a deeper security-specific audit complementing the security posture section of this review.

## Requirements

Tools used: `Read`, `Glob`, `Grep`, `Write`, `Bash`
