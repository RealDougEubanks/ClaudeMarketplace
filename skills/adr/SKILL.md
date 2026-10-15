---
name: adr
description: Creates and maintains Architecture Decision Records (ADRs) in docs/decisions/ using the MADR 4.0 format. Supports creating, listing, updating, superseding, and searching ADRs.
argument-hint: "[create <title> | list | update <n> <status> | supersede <n> | search <keyword>]"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# adr

## Purpose

Create, list, update, and supersede Architecture Decision Records (ADRs) following the Markdown Architectural Decision Records (MADR) 4.0 format. Maintains an ADR directory (see Directory Convention below). Works standalone or as a companion to `/architecture-design`.

---

## Directory Convention

Before creating anything, detect where this project keeps ADRs. Use Glob to check, in order: `docs/decisions/ADR-*.md`, `docs/decisions/[0-9][0-9][0-9][0-9]-*.md`, `docs/adr/*.md`, `adr/*.md`, `docs/architecture/decisions/*.md`. Use the first directory that already contains ADRs. Only if none exists, default to `docs/decisions/`. All paths below refer to this detected directory. If existing ADRs use a different file-name pattern (e.g. MADR's `NNNN-title.md`), follow that pattern instead of `ADR-NNN-title.md`.

---

## ADR Format (MADR 4.0)

Every ADR follows the MADR 4.0.0 template (<https://adr.github.io/madr/>). Metadata lives in YAML front matter. `tags` is not part of MADR; this skill adds it as an optional key so `list` and `search` can filter by area. Sections marked `<!-- optional -->` may be dropped when they add nothing; remove the marker comments from the saved file.

```markdown
---
status: proposed | accepted | rejected | deprecated | superseded by ADR-NNN
date: YYYY-MM-DD
decision-makers: <names or roles>
consulted: <people whose opinions were sought; two-way communication>
informed: <people kept up to date; one-way communication>
tags: <architecture | security | database | api | infrastructure | ...>
---

# ADR-NNN: <Title>

## Context and Problem Statement

[2-3 sentences: what situation led to this decision? What problem is being solved? Phrase it as a question if that helps.]

<!-- optional -->
## Decision Drivers

* [driver 1: most important constraint or goal]
* [driver 2]

## Considered Options

* [Option A]
* [Option B]
* [Option C]

## Decision Outcome

Chosen option: "[Option A]", because [justification tied to the decision drivers].

<!-- optional -->
### Consequences

* Good, because [what becomes easier, better, or possible]
* Bad, because [what becomes harder, more expensive, or is given up]
* Neutral, because [effect that is neither a gain nor a loss]

<!-- optional, but include it whenever possible -->
### Confirmation

[How compliance with this decision will be checked: design or code review, an architecture test (e.g. ArchUnit), a lint rule, a CI check.]

<!-- optional -->
## Pros and Cons of the Options

### [Option A]

* Good, because [argument]
* Neutral, because [argument]
* Bad, because [argument]

### [Option B]

* Good, because [argument]
* Bad, because [argument]

<!-- optional -->
## More Information

[Supporting evidence, team agreement, when to revisit the decision, links to related ADRs, design docs, RFCs, or tickets.]
```

---

## Instructions

### Step 1 — Determine the action

Parse `$ARGUMENTS` first and dispatch directly — do not ask if the action is given:

| Invocation | Action |
|------------|--------|
| `/adr create <title>` | Step 2a, using `<title>` as the decision title |
| `/adr list` | Step 2b |
| `/adr update <n> <status>` | Step 2c on ADR-`<n>`, setting `<status>` |
| `/adr supersede <n>` | Step 2d replacing ADR-`<n>` |
| `/adr search <keyword>` | Step 2e with `<keyword>` |

If no arguments were given, ask the user what they want to do:
- **(a) Create a new ADR** — document a new architectural decision
- **(b) List existing ADRs** — show all ADRs with status and one-line summary
- **(c) Update an ADR's status** — mark as Accepted, Rejected, Deprecated, or Superseded
- **(d) Supersede an ADR** — create a new ADR that replaces an existing one
- **(e) Search ADRs** — find ADRs by tag, status, or keyword

---

### Step 2a — Create a new ADR

1. Use Glob to find all existing ADRs in the detected ADR directory. Determine the next number.
2. Use Read on any related existing ADRs mentioned.
3. Ask the user (skip the title question if it was passed as an argument):
   - What is the decision being made? (one sentence title)
   - What is the context / problem? (what forced this decision)
   - Who made the decision? Who was consulted, and who needs to be informed?
   - What options were considered?
   - What was chosen and why?
   - How will compliance be confirmed (review, test, CI check)?
4. Generate the full ADR using the MADR format above.
5. Use Write to save to `<adr-dir>/ADR-<NNN>-<kebab-case-title>.md`. Create the directory if it doesn't exist.
6. Update the ADR index (see Step 3).

---

### Step 2b — List existing ADRs

Use Glob to find all ADRs in the detected ADR directory. Use Read on each to extract: number, title, status, date, tags. Read these from the YAML front matter; for older ADRs that use bold `**Status:**`-style fields instead, read those. Output a sorted table:

```
## Architecture Decision Records

| # | Title | Status | Date | Tags |
|---|-------|--------|------|------|
| ADR-001 | Use PostgreSQL as primary database | Accepted | 2026-01-15 | database |
| ADR-002 | Adopt hexagonal architecture | Accepted | 2026-01-20 | architecture |
| ADR-003 | Use Redis for session storage | Proposed | 2026-02-01 | infrastructure |
```

---

### Step 2c — Update status

Use Read to load the ADR. Use Edit to update the `status` front matter key (or the legacy `**Status:**` line in older ADRs) and set `date` to today. Valid transitions:
- Proposed → Accepted (decision confirmed)
- Proposed → Rejected (decision considered and turned down)
- Proposed → Deprecated (no longer relevant before being accepted)
- Accepted → Deprecated (no longer the right approach)
- Accepted → Superseded by ADR-NNN (replaced by a newer decision)

---

### Step 2d — Supersede

1. Create a new ADR (Step 2a) that documents the new decision.
2. In the new ADR's More Information section, add a link: "Supersedes ADR-NNN: [title]"
3. Use Edit to update the old ADR's `status` to `superseded by ADR-NNN`.

---

### Step 2e — Search

Use Grep across the detected ADR directory for the keyword or tag. Return matching ADRs with context.

---

### Step 3 — Maintain ADR Index

After any create/update operation, regenerate `<adr-dir>/README.md` — an index of all ADRs sorted by number, showing status as a text badge: `[ACCEPTED]`, `[PROPOSED]`, `[REJECTED]`, `[DEPRECATED]`, `[SUPERSEDED]`.
