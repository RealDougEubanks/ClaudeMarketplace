# adr — Architecture Decision Records

**Command:** `/adr`
**Category:** workflow
**Version:** 1.0.0

---

## What Are ADRs and Why Do They Matter?

Architecture Decision Records (ADRs) are short documents that capture the context, rationale, and consequences of significant architectural choices. Without them, knowledge lives only in the heads of whoever was in the room — and walks out the door when people leave.

ADRs answer: *Why does this codebase look the way it does?* They are the institutional memory of your system's evolution.

This skill uses the **MADR 4.0** (Markdown Architectural Decision Records) format, a lightweight Markdown template that is easy to write, easy to read, and diffs cleanly in version control. Template reference: <https://adr.github.io/madr/>.

---

## MADR Format Overview

Each ADR starts with YAML front matter (`status`, `date`, `decision-makers`, `consulted`, `informed`, plus an optional `tags` key that this skill adds for filtering), followed by these sections:

| Section | Purpose |
|---------|---------|
| **Context and Problem Statement** | The situation that forced a decision |
| **Decision Drivers** (optional) | The constraints and goals that mattered most |
| **Considered Options** | The alternatives that were evaluated |
| **Decision Outcome** | What was chosen and why |
| **Consequences** (optional) | Good, Bad, and Neutral effects of the choice |
| **Confirmation** (optional) | How compliance with the decision will be checked |
| **Pros and Cons of the Options** (optional) | Good / Neutral / Bad arguments per option |
| **More Information** (optional) | Evidence, revisit conditions, links to related ADRs, RFCs, tickets |

Files are stored as `docs/decisions/ADR-NNN-kebab-case-title.md`. If the project already has ADRs under another name pattern (such as MADR's `NNNN-title.md`), the skill follows that pattern.

---

## Five Actions

### (a) Create a new ADR

Invoke `/adr` and select **create**. The skill will:

1. Find the next available ADR number from existing files in `docs/decisions/`.
2. Ask for the decision title, context, decision-makers, who was consulted and informed, options considered, the chosen option, and how compliance will be confirmed.
3. Generate a complete MADR-formatted ADR.
4. Save it to `docs/decisions/ADR-<NNN>-<kebab-title>.md`.
5. Regenerate the ADR index at `docs/decisions/README.md`.

### (b) List existing ADRs

Displays a sorted table of all ADRs with number, title, status, date, and tags. Useful for getting oriented in an unfamiliar codebase.

### (c) Update an ADR's status

Valid status transitions:

```
Proposed → Accepted
Proposed → Rejected
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
---
status: accepted
date: 2026-01-15
decision-makers: Engineering Lead, Backend Team
consulted: DBA, Security
informed: Product, Support
tags: database, infrastructure
---

# ADR-001: Use PostgreSQL as Primary Database

## Context and Problem Statement

We are building a SaaS platform that requires ACID-compliant transactions,
complex relational queries, and strong ecosystem support. Which primary
database should we adopt before writing any data-layer code?

## Decision Drivers

* Must support ACID transactions for financial operations
* Team has existing PostgreSQL expertise
* Must integrate with our ORM of choice (SQLAlchemy / Prisma)

## Considered Options

* PostgreSQL
* MySQL
* MongoDB

## Decision Outcome

Chosen option: "PostgreSQL", because it provides the strongest ACID guarantees,
has the richest feature set for complex queries (CTEs, window functions, JSONB),
and matches team expertise.

### Consequences

* Good, because full ACID transaction support covers the financial flows
* Good, because rich query features reduce application complexity
* Bad, because horizontal write scaling needs more work than some NoSQL options

### Confirmation

Schema migrations are reviewed by the DBA, and a CI check rejects any new
datastore client library that has not been approved through an ADR.

## Pros and Cons of the Options

### PostgreSQL

* Good, because of full ACID compliance
* Good, because JSONB handles flexible fields
* Good, because the team knows it well
* Bad, because vertical scaling limits appear at extreme write volumes

### MySQL

* Good, because hosting support is wide
* Bad, because it has fewer query features than PostgreSQL

### MongoDB

* Good, because it scales horizontally
* Bad, because schema flexibility can lead to data consistency issues
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
