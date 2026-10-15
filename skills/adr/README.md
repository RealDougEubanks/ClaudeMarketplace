<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# adr

The adr skill creates and maintains Architecture Decision Records (ADRs). It uses the
MADR 4.0 format (Markdown Architectural Decision Records). Template reference:
<https://adr.github.io/madr/>.

An ADR is a short document. It records the context, the options, the chosen option, and
the consequences of one architectural decision. ADRs tell new team members why the code
has its current shape.

## Usage

| Slash command | What it does |
|---|---|
| `/adr` | Asks which action you want |
| `/adr create <title>` | Creates a new ADR with the given title |
| `/adr list` | Shows all ADRs in a table: number, title, status, date, tags |
| `/adr update <n> <status>` | Sets the status of ADR `<n>` and sets its date to today |
| `/adr supersede <n>` | Creates a new ADR that replaces ADR `<n>` |
| `/adr search <keyword>` | Finds ADRs that contain the keyword, tag, or status |

If you give the action as an argument, the skill does not ask for it.

## ADR directory

The skill finds the ADR directory before it writes. It checks these patterns in this
order and uses the first directory that already contains ADRs:

1. `docs/decisions/ADR-*.md`
2. `docs/decisions/[0-9][0-9][0-9][0-9]-*.md`
3. `docs/adr/*.md`
4. `adr/*.md`
5. `docs/architecture/decisions/*.md`

If no ADRs exist, the skill uses `docs/decisions/`. The default file name is
`ADR-NNN-kebab-case-title.md`. If the existing ADRs use another pattern, such as MADR
`NNNN-title.md`, the skill uses that pattern.

## Actions

### Create

1. The skill finds the next free ADR number.
2. The skill reads related ADRs that you mention.
3. The skill asks for the title, the context, the decision-makers, and who was consulted
   and informed. It also asks for the options, the chosen option, and the confirmation
   method.
4. The skill writes the ADR in MADR format.
5. The skill updates the ADR index.

### List

The skill reads each ADR and shows a sorted table. It reads metadata from the YAML front
matter. For older ADRs, it reads bold fields such as `**Status:**`.

### Update status

Valid status changes:

```text
Proposed → Accepted
Proposed → Rejected
Proposed → Deprecated
Accepted → Deprecated
Accepted → Superseded by ADR-NNN
```

### Supersede

1. The skill creates a new ADR for the new decision.
2. The skill adds "Supersedes ADR-NNN: [title]" to the More Information section of the
   new ADR.
3. The skill sets the status of the old ADR to `superseded by ADR-NNN`.

### Search

The skill searches the ADR directory with `Grep`. It returns each matching ADR with
context lines.

## ADR index

After each create or update, the skill writes `README.md` again in the ADR directory. The
index lists all ADRs by number. Each status shows as a text badge: `[ACCEPTED]`,
`[PROPOSED]`, `[REJECTED]`, `[DEPRECATED]`, or `[SUPERSEDED]`.

## MADR format

Each ADR starts with YAML front matter: `status`, `date`, `decision-makers`, `consulted`,
and `informed`. MADR does not define `tags`. The skill adds `tags` as an optional key for
`list` and `search`.

| Section | Purpose |
|---|---|
| Context and Problem Statement | The situation that caused the decision |
| Decision Drivers (optional) | The most important constraints and goals |
| Considered Options | The options that the team evaluated |
| Decision Outcome | The chosen option and the reason |
| Consequences (optional) | Good, bad, and neutral effects |
| Confirmation (optional) | How the team checks compliance with the decision |
| Pros and Cons of the Options (optional) | Arguments for and against each option |
| More Information (optional) | Evidence, when to revisit, links to related ADRs and tickets |

The skill removes optional sections that add nothing.

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
```

## File layout

```text
docs/
  decisions/
    README.md          ← Auto-generated index (maintained by /adr)
    ADR-001-use-postgresql.md
    ADR-002-hexagonal-architecture.md
    ADR-003-redis-session-storage.md
```

## Related skills

The `/architecture-design` skill produces C4 diagrams, service boundaries, and API
contracts. At the end of a design session, it offers to run `/adr` for the key decisions.

## Installation

Add this repository as a marketplace in `~/.claude/settings.json` (see the root
[README](../../README.md)). Then enable the plugin:

```json
{
  "enabledPlugins": {
    "adr@claude-skills-marketplace": true
  }
}
```

## Author

Doug Eubanks: <https://github.com/RealDougEubanks>
