<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# doc-refresh

> The doc-refresh skill audits stale documentation, creates missing documents, and rewrites
> them to a documentation standard. It writes for a reader with no context.

## What it does

The skill does a full documentation refresh on a project:

- **Audit.** It checks each `.md` file for file paths, commands, and environment variables
  that no longer exist.
- **Propose deletions.** It lists each document that no longer applies, with the reason. It
  deletes a document only after you confirm.
- **Create.** It writes standard documents that are missing: `README.md`, `docs/RUNBOOK.md`,
  `CONTRIBUTING.md`, `SECURITY.md`, and `docs/ENV_VARS.md`.
- **Rewrite.** It rewrites stale documents to the selected standard. It also adds an
  overlay: no assumed context, numbered steps, security notices, tables, and a metadata
  comment.

A full run audits 10 documents or fewer. If there are more, the skill does the core documents
first and lists the skipped files for a second run.

You start the skill with the slash command only. Claude does not start it automatically.

### Documentation standards

Use `--standard` to select one standard, or let the skill select one for each document
(`auto`):

| Value | Use |
|-------|-----|
| `auto` | Default. Runbooks and reference get `ste-lite`; READMEs, policies and guides get `plain`. |
| `ste-lite` | ASD-STE100 Issue 9 writing rules in two tiers, no controlled dictionary. |
| `ste` | Full ASD-STE100; needs your copy of the STE dictionary, otherwise falls back to `ste-lite`. |
| `plain` | ISO 24495-1 plain language. |
| `google` / `microsoft` | The Google or Microsoft developer style guide. |
| `diataxis` | Diátaxis page structure; combine with a sentence standard, e.g. `diataxis,ste-lite`. |

If a document already names a standard in its metadata comment, the skill keeps that
standard. The catalog of standards is in `standards/catalog.md`. The STE-lite rules are in
`standards/ste-lite.md`.

STE-lite has two tiers. Tier 1 applies to every document: sentence limits, one instruction
per step, notices before the step, and one term for each concept. Tier 2 adds imperative
mood, active voice, and no modal verbs or "-ing" phrases. It applies to runbooks, reference
pages, and agent context files, and to numbered steps in all other documents.

The bundled `scripts/ste_check.py` scores each document for its tier. It also flags likely
passive voice and terms that the project glossary rejects. The target is 90%. The skill
gives each score in its summary.

Two more rules apply to every document, whatever the standard:

- **Accessible writing** (W3C WAI). Give each informative image alt text. Write link text that
  names the target. Do not skip a heading level.
- **Inclusive language** (the Google and Microsoft style guides). Use neutral terms such as
  "allowlist". The default term list is `standards/inclusive-terms.txt`.

The checker reports accessibility issues as `a11y-*` items next to the score. A README follows
the Standard Readme section order. An event-driven API reference uses AsyncAPI 3.1.

### Safety checks

Before the skill writes, it does these checks:

1. Confirm the target repository. If the arguments name a different path, it stops and asks.
2. List documents that have uncommitted changes, and ask whether to overwrite, skip, or stop.
3. Compare each file's content hash before the write. If the file changed on disk, it does
   not write that file.
4. Find tests that check the documents, and run them after the write.
5. Leave historical records unchanged: changelog entries, accepted ADRs, dated reports,
   `LICENSE`, and `NOTICE`.

### The 2am-engineer persona

The skill writes runbooks and troubleshooting pages for a reader who was just paged. That
reader is tired and has never seen the codebase. The pages use short sentences, numbered
procedures, and security notices before each sensitive step. Each acronym has a definition.
AI agents can also use these pages easily.

## Usage

| Slash command | What it does |
|---------------|-------------|
| `/doc-refresh` | Full refresh: audit, propose deletions, create missing documents, rewrite stale documents |
| `/doc-refresh --standard ste-lite` | Full refresh with one standard for every document |
| `/doc-refresh runbook` | Generate `docs/RUNBOOK.md` only |
| `/doc-refresh check` | Audit only, no writes. Gives STE-lite scores. Use it in CI. |
| `/doc-refresh install` | Install a pre-commit git hook (backs up and chains any existing hook, including the `/pre-commit` hook) |
| `/doc-refresh uninstall` | Remove the hook that it installed and restore the previous hook |

## Example output

```
doc-refresh Results
───────────────────────────────────
Stale docs purged:    1  (docs/OLD_SETUP.md)
Docs created:         2  (docs/RUNBOOK.md, SECURITY.md)
Docs rewritten:       1  (README.md — 3 dead command references fixed)
Docs unchanged:       2  (CONTRIBUTING.md, docs/assumptions.md)

Standard per doc:     README.md=plain, docs/RUNBOOK.md=ste-lite
STE-lite scores:      docs/RUNBOOK.md 94% (full), README.md 98% (always)
Doc tests run:        pytest tests/test_docs.py — pass
Notices added:        4 SECURITY, 1 WARNING, 1 CAUTION
Skipped (uncommitted or changed during the run): 0

Next: commit these changes, then run /pre-commit to verify.
```

## Pre-commit hook

The pre-commit hook follows the conventions of the pre-commit skill, so the two hooks can
stack. Each one backs up the hook that it replaces and runs that hook first.

> **CAUTION:** If `core.hooksPath` is set, a hook manager such as husky or lefthook probably
> controls your hooks. In that case, the skill stops and recommends that you call
> `claude -p "/doc-refresh check"` from the hook manager.

To install the hook, type `/doc-refresh install`.

The hook has two modes:

| Mode | How to select it | Behavior |
|------|------------------|----------|
| Check (default) | No setting | Runs `/doc-refresh check` and reports drift. Writes nothing. |
| Write | `DOC_REFRESH_HOOK_MODE=write` | Rewrites documents and stages them in the same commit. Never deletes files. Skips each document that you already changed. |

To skip one run, use `SKIP_DOC_REFRESH=1 git commit ...`. The hook never blocks a commit.

The hook runs only on your machine. Each team member must install it.

## Installation

Add this repository as a marketplace in `~/.claude/settings.json`, then enable the plugin:

```json
{
  "enabledPlugins": {
    "doc-refresh@claude-skills-marketplace": true
  }
}
```
