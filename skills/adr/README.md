# adr — Architecture Decision Records

**Command:** `/adr`
**Category:** workflow
**Version:** 1.0.0

---

## What Are ADRs and Why Do They Matter?

Architecture Decision Records (ADRs) are short documents that capture the context, rationale, and consequences of significant architectural choices. Without them, knowledge lives only in the heads of whoever was in the room — and walks out the door when people leave.

ADRs answer: *Why does this codebase look the way it does?* They are the institutional memory of your system's evolution.

This skill uses the **MADR** (Markdown Architectural Decision Records) format — a lightweight, structured Markdown template that is easy to write, easy to read, and version-control-friendly.

---

## MADR Format Overview

Each ADR is a Markdown file with these sections:

| Section | Purpose |
|---------|---------|
| **Context and Problem Statement** | The situation that forced a decision |
| **Decision Drivers** | The constraints and goals that mattered most |
| **Considered Options** | The alternatives that were evaluated |
| **Decision Outcome** | What was chosen and why |
| **Pros and Cons of the Options** | Structured comparison of all alternatives |
| **Links** | Related ADRs, RFCs, tickets, design docs |

Files are stored as `docs/decisions/ADR-NNN-kebab-case-title.md`.

---

## Five Actions

### (a) Create a new ADR

Invoke `/adr` and select **create**. The skill will:

1. Find the next available ADR number from existing files in `docs/decisions/`.
2. Ask for the decision title, context, deciders, options considered, and the chosen option.
3. Generate a complete MADR-formatted ADR.
4. Save it to `docs/decisions/ADR-<NNN>-<kebab-title>.md`.
5. Regenerate the ADR index at `docs/decisions/README.md`.

### (b) List existing ADRs

Displays a sorted table of all ADRs with number, title, status, date, and tags. Useful for getting oriented in an unfamiliar codebase.

### (c) Update an ADR's status

Valid status transitions:

```
Proposed → Accepted
Proposed → Deprecated
Accepted → Deprecated
Accepted → Superseded by ADR-NNN
```

Invoke `/adr`, select **update**, specify the ADR number and new status.

### (d) Supersede an ADR

When a previous decision is overturned:

1. A new ADR is created documenting the replacement decision.
2. The new ADR links back to the one it supersedes.
3. The old ADR's status is updated to `Superseded by ADR-NNN`.

### (e) Search ADRs

Search across `docs/decisions/` by keyword, tag, or status. Returns matching ADRs with relevant context lines.

---

## Example ADR

```markdown
# ADR-001: Use PostgreSQL as Primary Database

**Date:** 2026-01-15
**Status:** Accepted
**Deciders:** Engineering Lead, Backend Team
**Tags:** database, infrastructure

## Context and Problem Statement

We are building a SaaS platform that requires ACID-compliant transactions,
complex relational queries, and strong ecosystem support. We need to select
a primary database before writing any data-layer code.

## Decision Drivers

- Must support ACID transactions for financial operations
- Team has existing PostgreSQL expertise
- Must integrate with our ORM of choice (SQLAlchemy / Prisma)

## Considered Options

1. **PostgreSQL** — battle-tested open-source relational database
2. **MySQL** — widely-used relational database
3. **MongoDB** — document-oriented NoSQL database

## Decision Outcome

**Chosen option:** PostgreSQL, because it provides the strongest ACID guarantees,
has the richest feature set for complex queries (CTEs, window functions, JSONB),
and matches team expertise.

### Positive Consequences
- Full ACID transaction support
- Rich query capabilities reduce application complexity

### Negative Consequences / Trade-offs
- Horizontal write scaling requires more work than some NoSQL alternatives

## Pros and Cons of the Options

### Option 1 — PostgreSQL
- ✅ Full ACID compliance
- ✅ JSONB for flexible fields
- ✅ Strong team familiarity
- ❌ Vertical scaling limits at extreme write volumes

### Option 2 — MySQL
- ✅ Wide hosting support
- ❌ Less feature-rich than PostgreSQL

### Option 3 — MongoDB
- ✅ Horizontal scaling
- ❌ No multi-document transactions in earlier versions
- ❌ Schema flexibility can lead to data consistency issues
```

---

## Integration with /architecture-design

`/adr` works as a companion to `/architecture-design`. When the architecture skill produces design artifacts (C4 diagrams, service boundaries, API contracts), it can invoke `/adr` to document the key decisions made during the design session. The two skills share the `docs/` directory structure.

---

## File Layout

```
docs/
  decisions/
    README.md          ← Auto-generated index (maintained by /adr)
    ADR-001-use-postgresql.md
    ADR-002-hexagonal-architecture.md
    ADR-003-redis-session-storage.md
```

---

## Author

Doug Eubanks — [github.com/RealDougEubanks](https://github.com/RealDougEubanks)
