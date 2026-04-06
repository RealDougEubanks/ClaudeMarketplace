# architecture-design

Design a new system or major feature from requirements to a fully documented architecture artifact.

## Purpose

`/architecture-design` guides you through a structured, ten-step process that produces:

- **C4 model diagrams** at all three levels (Context, Container, Component)
- **Service and component boundary definitions**
- **API contract sketches** (REST, GraphQL, gRPC, WebSocket, or event-based)
- **Data design** with entity relationships, database type recommendations, and PII/encryption flags
- **Failure mode analysis** for every external dependency and critical path
- **Cross-cutting concerns** (auth, observability, configuration, deployment, testing strategy)
- A saved design document at `docs/architecture/<name>-design.md`

## Invocation

```
/architecture-design
```

Claude will ask a short set of scoping questions (or read from `docs/requirements/` if it exists) before proceeding.

## Supported Architecture Patterns

| Pattern | Best For |
|---------|----------|
| Monolith (Modular) | Small teams, early stage, unclear domain boundaries |
| Microservices | Large teams, independent scaling, polyglot stacks |
| Event-Driven | Async workflows, audit trail, loose coupling |
| Hexagonal (Ports & Adapters) | Complex domain logic, high testability requirements |
| CQRS + Event Sourcing | Audit history, high write/read ratio difference |
| Serverless | Unpredictable traffic, low ops overhead |
| BFF (Backend for Frontend) | Multiple client types with different data needs |

Claude recommends a pattern and explains the tradeoffs before asking you to confirm.

## C4 Model

The skill uses the [C4 model](https://c4model.com/) — a hierarchical notation for software architecture:

| Level | What it shows |
|-------|---------------|
| L1 Context | The system in relation to its users and external dependencies |
| L2 Container | Deployable units: frontends, APIs, workers, databases, brokers |
| L3 Component | Internal structure of the most complex container |

Diagrams are rendered as Mermaid fenced code blocks inline in the output document.

## Output Files

| File | Description |
|------|-------------|
| `docs/architecture/<name>-design.md` | Full design artifact with all diagrams and decisions |
| `handoffs/designs/{taskId}_design_{ts}.json` | ABD envelope (written only if `handoffs/designs/` exists) |

## Integration with Other Skills

- **`/adr`** — After the design is complete, `/architecture-design` offers to run `/adr` to record the key decisions as Architecture Decision Records.
- **`/abd-design`** — In an Agent-Based Development (ABD) workflow, this skill operates as the design agent and writes a structured handoff artifact for downstream agents.
- **`/architecture-review`** — Use `/architecture-review` on an existing codebase before calling `/architecture-design` to understand what must change.

## Requirements

Tools used: `Read`, `Write`, `Glob`, `Grep`, `Bash`
