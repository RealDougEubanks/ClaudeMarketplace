# doc-refresh

> Complete documentation refresh. Audits stale docs, creates missing docs, and rewrites
> them to a documentation standard chosen per document, for a reader with zero context.

## What It Does

This skill performs a full documentation overhaul on any project:

- **Audits** every `.md` file for dead file references, removed commands, and missing env vars.
- **Deletes** docs that are no longer valid (wrong is worse than missing).
- **Creates** standard docs that are absent: `README.md`, `docs/RUNBOOK.md`, `CONTRIBUTING.md`,
  `SECURITY.md`, `docs/ENV_VARS.md`.
- **Rewrites** stale docs to the selected standard, plus an overlay: no assumed context, numbered steps,
  mandatory security callouts, tables over prose, AI-friendly heading structure.

### Documentation standards

Pass `--standard` to choose one, or let the skill pick per document (`auto`):

| Value | Use |
|-------|-----|
| `auto` | Default. Runbooks and reference get `ste-lite`; READMEs, policies and guides get `plain`. |
| `ste-lite` | ASD-STE100 Issue 9 writing rules in two tiers, without the controlled dictionary. |
| `ste` | Full ASD-STE100; needs your copy of the STE dictionary, otherwise falls back to `ste-lite`. |
| `plain` | ISO 24495-1 plain language. |
| `google` / `microsoft` | The Google or Microsoft developer style guide. |
| `diataxis` | Diátaxis page structure; combine with a sentence standard, e.g. `diataxis,ste-lite`. |

STE-lite has two tiers. Tier 1 (sentence limits, one instruction per step, notices before
the step, one term per concept) applies to every doc. Tier 2 (imperative, active voice, no
modal verbs or "-ing" phrases) applies to runbooks, reference pages, and agent context files,
and to numbered steps everywhere. The bundled `scripts/ste_check.py` scores each doc for its
tier, flags likely passive voice and glossary terms to avoid, and the skill aims for 90%.

Every doc also gets two universal rules, whatever the standard: accessible writing (alt text,
descriptive link text, heading order, per W3C WAI) and inclusive language (per the Google and
Microsoft style guides; a default term list ships in `standards/inclusive-terms.txt`). The
checker reports `a11y-*` issues alongside the score. READMEs follow the Standard Readme section
order, and event-driven API references use AsyncAPI 3.1.

### Safety checks

Before writing, the skill confirms the target repository, asks before overwriting docs that
have uncommitted changes, stops if a file changes on disk while it works, runs any tests that
check the docs, and leaves historical records (changelog entries, accepted ADRs, dated
reports, LICENSE, NOTICE) unchanged.

### The 2am-Engineer Persona

Runbooks and troubleshooting pages are written as if the reader was just paged, is not fully
awake, and has never seen the codebase. Short sentences. Numbered procedures. Security warnings before any sensitive step.
No jargon without a definition. This also makes docs highly consumable by AI agents.

## Installation

Add this repo as a marketplace in `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "doc-refresh@claude-skills-marketplace": true
  }
}
```

## Usage

| Command | What it does |
|---------|-------------|
| `/doc-refresh` | Full refresh: audit, purge stale, fill gaps |
| `/doc-refresh --standard ste-lite` | Full refresh with one standard for every doc |
| `/doc-refresh runbook` | Generate `docs/RUNBOOK.md` only |
| `/doc-refresh check` | Audit only — no writes. Reports STE-lite scores. Good for CI. |
| `/doc-refresh install` | Install as a pre-commit git hook (backs up and chains any existing hook, including the `/pre-commit` hook) |
| `/doc-refresh uninstall` | Remove the hook it installed and restore the previous hook |

## Example Output

```
doc-refresh Results
───────────────────────────────────
Stale docs purged:    1  (docs/OLD_SETUP.md)
Docs created:         2  (docs/RUNBOOK.md, SECURITY.md)
Docs rewritten:       1  (README.md — 3 dead command references fixed)
Docs unchanged:       2  (CONTRIBUTING.md, docs/assumptions.md)

Standard per doc:     README.md=plain, docs/RUNBOOK.md=ste-lite
STE-lite scores:      docs/RUNBOOK.md 94% (full), README.md 98% (always)
Notices added:        4 SECURITY, 1 WARNING, 1 CAUTION

Next: commit these changes, then run /pre-commit to verify.
```

## Pre-Commit Hook

Run `/doc-refresh install` to attach this skill as a pre-commit git hook. It shares the
pre-commit skill's conventions, so the two hooks stack: each backs up the hook it replaces and
runs it first.

By default the hook runs `/doc-refresh check` and reports drift without writing. Set
`DOC_REFRESH_HOOK_MODE=write` to let it rewrite docs and stage them in the same commit; in
that mode it never deletes files and skips any doc you have already edited. Skip one run with
`SKIP_DOC_REFRESH=1 git commit ...`. The hook never blocks a commit.
