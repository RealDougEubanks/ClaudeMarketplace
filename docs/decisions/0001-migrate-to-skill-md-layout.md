# Migrate skill plugins from commands/ layout to SKILL.md layout

- Status: accepted
- Date: 2026-07-08
- Deciders: Doug Eubanks, Claude (skills audit follow-up)

## Context and Problem Statement

Every skill in this marketplace is a single-skill plugin using the legacy layout
`<plugin-root>/commands/<name>.md`. Claude Code's modern layout is `SKILL.md`, which makes
progressive disclosure first-class: supporting files (templates, rules, reference docs) are
loaded on demand via markdown links instead of being embedded in the prompt or resolved
through `${CLAUDE_PLUGIN_ROOT}` workarounds. Three skills (doc-refresh, incident-report,
log-correlation) already carry supporting-file directories and two more (best-practices,
agent-based-development) would benefit from them.

Official docs (verified 2026-07-08) state: the `commands/` layout is supported indefinitely
with no deprecation timeline, but `skills/` + `SKILL.md` is recommended for new work. Both
layouts produce identical namespaced slash commands (`/<plugin>:<skill>`), support identical
frontmatter fields, and resolve `${CLAUDE_PLUGIN_ROOT}` the same way. Invocation is therefore
unchanged by migration — since every plugin here is named after its single skill, commands
remain `/<name>:<name>` before and after.

## Decision

1. **Single-skill plugins** (22 of 23) place `SKILL.md` directly at the plugin root
   (`skills/<name>/SKILL.md` in repo terms), which the docs permit for plugins shipping
   exactly one skill. This avoids the redundant `skills/<name>/skills/<name>/SKILL.md`
   nesting and keeps supporting directories (`templates/`, `rules/`, `log-types/`,
   `checklists/`) as siblings of `SKILL.md`, reachable by relative markdown links.
2. **agent-based-development** becomes a multi-skill plugin using the full
   `skills/<role>/SKILL.md` layout, splitting its ten roles into separate skills that share
   common reference files — resolving the audit finding that a single 287-line all-roles
   prompt risks instruction bleed on smaller models.
3. **No dual layout.** `commands/` directories are removed in the same change. Shipping both
   creates the same drift risk as the retired root `skill.md` convention.
4. `.scan-exempt` files move from `commands/` to the plugin root (the scanner honors both).
5. Repo tooling (`validate.sh`, `new-skill.sh`, `scan-prompts.sh`, tests, schema, CLAUDE.md,
   README) is updated in the same change; `metadata.json` `commands` entries keep the bare
   `/<name>` form as skill documentation.

## Considered Alternatives

- **Stay on `commands/` indefinitely** — viable (no deprecation), but leaves progressive
  disclosure second-class and diverges from the documented recommendation.
- **Canonical nested layout for all** (`skills/<name>/skills/<name>/SKILL.md`) — rejected:
  redundant nesting with no benefit for single-skill plugins.
- **Dual-ship both layouts during a transition** — rejected: known drift failure mode in
  this repo; skills silently shadow same-name commands, hiding staleness.

## Consequences

- Slash command names are unchanged (`/<name>:<name>`); no user-facing migration needed.
- Marketplace consumers receive the new layout via `autoUpdate` transparently.
- Skills gain documented on-demand loading of supporting files.
- All 23 skills take a minor version bump for the layout change.
- Local testing uses `claude --plugin-dir ./skills/<name>` and `claude plugin validate`.
