# Documentation standards catalog

Load this file when you select a documentation standard. It lists the standards that
doc-refresh supports and the default for each document type.

## How standards layer

Each document gets three layers:

1. **Structure.** The page type and the order of its sections (Diátaxis, a template, or a
   format specification).
2. **Sentence rules.** STE-lite, plain language, or a house style guide.
3. **Overlay.** Always applied: the universal rules below, security notices before the step,
   file and line references, the metadata comment, and freshness checks against the code.

## Supported values for `--standard`

| Value | Layer | Use it for | Reference |
|---|---|---|---|
| `auto` (default) | — | Pick per document from the matrix below | — |
| `ste-lite` | Sentence rules | Procedures, runbooks, reference descriptions, AI-agent context files (Tier 1 + Tier 2) | [ste-lite.md](ste-lite.md) |
| `ste` | Sentence rules + vocabulary | Regulated or contractual docs that require ASD-STE100 | [ste-lite.md](ste-lite.md) |
| `plain` | Sentence rules | READMEs, policies, end-user guides, general audiences | ISO 24495-1:2023 Plain language — Governing principles and guidelines; <https://www.plainlanguage.gov/guidelines/> |
| `google` | Sentence rules | Developer docs in projects that follow Google conventions | <https://developers.google.com/style> |
| `microsoft` | Sentence rules | Developer and product docs in projects that follow Microsoft conventions | <https://learn.microsoft.com/style-guide/welcome/> |
| `diataxis` | Structure | Large `docs/` trees: split pages into tutorial, how-to, reference, or explanation | <https://diataxis.fr/> |

Structure and sentence rules combine. For example, `--standard diataxis,ste-lite` organizes
the tree by Diátaxis and writes procedures in STE-lite.

## Default matrix (`auto`)

| Document type | Structure | Sentence rules |
|---|---|---|
| Runbook, SOP, troubleshooting | Diátaxis how-to; [templates/runbook.md](../templates/runbook.md) | `ste-lite` |
| How-to guide | Diátaxis how-to | `ste-lite` for steps, `plain` elsewhere |
| Tutorial | Diátaxis tutorial | `plain` (STE is too stiff for teaching) |
| API reference | OpenAPI document as the source of truth; Diátaxis reference | `ste-lite`, terse |
| Event-driven API reference (queues, streams, webhooks) | AsyncAPI 3.1 document as the source of truth; Diátaxis reference | `ste-lite`, terse |
| Generated reference (Terraform/OpenTofu Registry, CLI help) | The generator's page format | `ste-lite` |
| README | Standard Readme section order; [templates/readme.md](../templates/readme.md) | `plain` |
| Architecture | arc42 sections and C4 diagrams | `plain` |
| ADR | MADR (see the adr skill) | `plain` |
| Changelog | Keep a Changelog 1.1.0 (see the changelog-generator skill) | `plain` |
| Security policy | [templates/security.md](../templates/security.md) | `plain`, with `ste-lite` for reporting steps |
| Contributing, onboarding | [templates/contributing.md](../templates/contributing.md); Diátaxis tutorial + how-to | `plain` |
| Environment variable reference | [templates/env-vars.md](../templates/env-vars.md) | `ste-lite` descriptions |
| End-user guide | Diátaxis; ISO/IEC/IEEE 26514 when a contract requires it | `plain` |
| Regulated or contractual manual | ISO/IEC/IEEE 26514 | `ste` when the industry requires it, else `plain` |
| AI-agent context (`CLAUDE.md`, `AGENTS.md`) | The file's own conventions | `ste-lite` (unambiguous imperatives) |

If the project already declares a style guide (in `CONTRIBUTING.md`, a `.vale.ini`, or a
`styles/` directory), use that guide for sentence rules unless the user named a standard.

## Universal rules (every document, every standard)

These rules apply on top of the selected standard.

**STE-lite Tier 1.** Sentence and paragraph limits, one instruction per step, notices before
the step, one term per concept. See [ste-lite.md](ste-lite.md).

**Accessible writing** (W3C WAI, "Writing for Web Accessibility";
<https://www.w3.org/WAI/tips/writing/>):

- Give every image alt text that states its information or function. Use empty alt text
  only for a decorative image (WCAG 1.1.1).
- Write link text that names the target. Do not use "click here", "here", "this", or "link"
  (WCAG 2.4.4).
- Use real headings in order. Do not skip a level, for example from H2 to H4 (WCAG 1.3.1,
  2.4.6).
- Give each page a title that tells it apart from other pages (WCAG 2.4.2).
- Expand each abbreviation on first use (WCAG 3.1.4).
- Give diagrams a text summary or a table with the same information.

**Inclusive language** (Google, "Write inclusive documentation",
<https://developers.google.com/style/inclusive-documentation>; Microsoft, "Bias-free
communication", <https://learn.microsoft.com/style-guide/bias-free-communication>):

- Use neutral terms: allowlist and denylist, primary and replica, person-hours.
- Use "you", a role ("the operator"), or "they" for a generic person. Do not use "he" or "she"
  for a generic person.
- Do not use ableist, violent, or figurative terms ("crazy", "kill", "hang"). Say what happens:
  "stop", "does not respond".
- Do not call a task "simple", "easy", or "just". The reader's experience can be different.
- In examples, use varied names and places. Do not use culture-specific references.
- If code requires a non-inclusive identifier, show it only in code font and use the neutral
  term in prose.

The checker enforces the term lists with
[inclusive-terms.txt](inclusive-terms.txt) (`--glossary`), and checks alt text, link text,
and heading order directly.

## README structure (Standard Readme)

When the doc is a README, use the section order of the Standard Readme spec
(<https://github.com/RichardLitt/standard-readme>): title (the repository or package name),
short description (one line, under 120 characters, the same as the repository description),
optional Security and Background, a table of contents when the README is 100 lines or longer,
Install, Usage, extra sections, Contributing, and License as the last section (SPDX
identifier and owner). The bundled README template follows this order.

## STE-lite tiers

[ste-lite.md](ste-lite.md) splits the STE writing rules into two tiers:

- **Tier 1 (always):** every document, whatever its sentence standard. Sentence and paragraph
  limits, one instruction per step, notices before the step, one term per concept.
- **Tier 2 (procedural):** imperative mood, active voice, no modal verbs, no "-ing" phrases.
  Applies in full to the document types whose sentence rules say `ste-lite` in the matrix
  above, and to the numbered steps of every other document.

## Reconcile with the persona

- Sentence length: 20 words for procedures and 25 for descriptive text, in every standard.
- Numbered steps: required for procedures. Tutorials and explanations can use narrative.
- The "2am reader" persona applies fully to runbooks and troubleshooting pages. For other
  page types, the selected standard sets the audience, and the overlay still applies.

## Notes on specific standards

- **Diátaxis.** Each page is one type only. Do not mix a tutorial and a reference on one page;
  link between them.
- **Plain language (ISO 24495-1:2023).** Four principles: the reader can find what they need,
  understand it, and use it, and the content is relevant to them. It is the safest default for
  mixed audiences.
- **Google and Microsoft guides.** Pick one for each repository. Do not mix them.
- **AGENTS.md.** A repository context file for AI coding agents, now stewarded by the Linux
  Foundation's Agentic AI Foundation. If the project has one, keep it current with the same
  freshness checks as `CLAUDE.md`. Do not create it unless the user asks.
