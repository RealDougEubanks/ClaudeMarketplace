# architecture-review

## Purpose

Evaluate the architecture of an existing system. Identify structural anti-patterns, scalability and reliability risks, coupling problems, and gaps in observability. Produce graded findings (Critical/High/Medium/Low) with concrete migration paths — not just "this is bad" but "here is how to fix it."

---

## Instructions

### Step 1 — Discover and map the existing architecture

Use Glob and Read to build a structural picture:
- Entry points: `index.*`, `main.*`, `server.*`, `app.*`
- Directory structure: what are the top-level modules and what do they contain?
- Config files: Dockerfile, docker-compose, CI/CD workflows, IaC
- Package manifests: what external dependencies exist (reveals technology choices)
- Database access: ORM config, migration files, raw query files
- API layer: routes, controllers, handlers
- Background jobs: workers, queues, cron configs
- External integrations: HTTP clients, SDK usage, message consumers/producers

Read the 10 largest source files — they are usually the most problematic.

---

### Step 2 — Reconstruct the architecture diagram

Produce a C4-style Level 2 Container diagram of what EXISTS today (not what should exist). Use Mermaid. This is the "as-is" baseline.

---

### Step 3 — Evaluate against architecture quality attributes

For each attribute, rate: OK Good / Concern / Problem

**Maintainability:**
- [ ] Clear separation of concerns (controllers vs services vs repositories vs domain)
- [ ] No circular dependencies between modules
- [ ] No "God files" (> 500 lines, doing everything)
- [ ] Consistent patterns across similar modules
- [ ] Domain logic not scattered across layers

**Scalability:**
- [ ] Stateless application tier (no in-process session/cache that prevents horizontal scaling)
- [ ] Database not a single bottleneck (read replicas, caching, connection pooling)
- [ ] Background work decoupled via queue (not blocking request/response)
- [ ] No polling loops that could be replaced with event-driven patterns
- [ ] Pagination on all list operations

**Reliability:**
- [ ] External dependency calls have timeout, retry, and circuit breaker
- [ ] No single points of failure in critical paths
- [ ] Graceful degradation when non-critical dependencies fail
- [ ] Health check endpoints exist and are meaningful
- [ ] Database migrations are safe (backwards compatible, no long locks)

**Testability:**
- [ ] Business logic is isolated from I/O (can be unit tested without DB/HTTP)
- [ ] Dependencies are injected (not hardcoded imports of singletons)
- [ ] No global mutable state
- [ ] Integration boundaries are clearly defined and mockable

**Observability:**
- [ ] Structured logs with trace/request IDs across service calls
- [ ] Metrics exposed (request rate, error rate, latency, queue depth)
- [ ] Distributed tracing instrumented (if microservices)
- [ ] Alerting defined for SLO breaches

**Security posture:**
- [ ] Auth enforced at a consistent layer (not per-endpoint ad hoc)
- [ ] Secrets not baked into configuration files or container images
- [ ] Principle of least privilege applied to service-to-service communication
- [ ] Sensitive data identified and encrypted at rest

**Common Anti-Pattern Detection:**

Explicitly check for and flag these named anti-patterns:
- **Big Ball of Mud**: no discernible structure, everything depends on everything
- **Distributed Monolith**: multiple services but tightly coupled via synchronous calls and shared DB
- **Anemic Domain Model**: domain objects are just data bags; all logic in service/manager classes
- **Lasagna Architecture**: too many unnecessary layers adding indirection without value
- **God Service**: one service that knows about and orchestrates everything else
- **Chatty I/O**: many small DB/HTTP calls where one batched call would suffice
- **Shared Database Anti-pattern**: multiple services reading/writing the same tables
- **Hardcoded Configuration**: environment-specific values baked into code or container

---

### Step 4 — Migration Recommendations

For each Problem and Concern finding, provide:
- **Current state**: what exists today
- **Target state**: what it should look like
- **Migration path**: step-by-step how to get there (with intermediate safe states)
- **Effort**: XS/S/M/L/XL
- **Risk**: Low/Medium/High (risk of the migration itself)

---

### Step 5 — Produce "To-Be" Architecture Diagram

Based on the recommendations, produce an updated Mermaid C4 Container diagram showing the recommended target architecture.

---

### Step 6 — Save report

Use Write to save to `docs/architecture/architecture-review-<date>.md`. Offer to write an ABD review artifact if `handoffs/reviews/` exists.

---

## Output Format

```markdown
## Architecture Review — <Project> — <Date>

### As-Is Architecture
[Mermaid C4 Container diagram]

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

### To-Be Architecture
[Mermaid C4 Container diagram]

### Migration Roadmap
| Priority | Finding | Effort | Risk |
|----------|---------|--------|------|
| P1 | Extract session to Redis | S | Low |
```
