<!--
doc: ASSUMPTIONS
last-refreshed: 2026-04-07
generated-by: doc-refresh skill
-->

# Assumptions

Non-obvious decisions made during development. Each entry records the assumption, rationale, author, and date.

---

- **Status:** Superseded on 2026-07-08 by the root `SKILL.md` layout entry below.
- **Assumption:** `commands/<skill-name>.md` is the single authoritative skill content file; legacy `skill.md` files are kept only for backward compatibility during the transition period.
- **Why:** The Claude Code plugin system discovers skills via the `commands/` directory with YAML frontmatter. Maintaining `skill.md` as a parallel copy creates drift risk and was flagged as a P1 issue in the best-practices audit.
- **Recorded by:** Claude (best-practices audit)
- **Date:** 2026-04-06

---

- **Assumption:** Merge commit (`--no-ff`) is the default merge style for all PRs.
- **Why:** Preserves branch history and makes it easier to identify which commits belong to which feature or fix.
- **Recorded by:** Claude (best-practices audit)
- **Date:** 2026-04-06

---

- **Assumption:** `templates/skill.md` and `templates/metadata.json` are deleted; the heredocs inside `scripts/new-skill.sh` are the single source of truth for scaffolding.
- **Why:** The template files had drifted from current conventions (root `skill.md` layout, missing `category`) and were never read by `new-skill.sh`, creating two-source drift risk.
- **Recorded by:** Claude (skills audit fixes)
- **Date:** 2026-06-04

---

- **Assumption:** `scan-prompts.sh` scans fenced code blocks with a narrower destructive/exfiltration pattern set (`FENCE_HIGH_PATTERNS`) rather than the full prose pattern list.
- **Why:** Skills legitimately document git/install commands inside fences; applying the full pattern set there drowns the scan in false positives, while skipping fences entirely (the old behavior) hid the highest-risk content. The narrow set catches pipe-to-shell, filesystem destruction, and reverse shells.
- **Recorded by:** Claude (skills audit fixes)
- **Date:** 2026-06-04

---

- **Assumption:** Single-skill plugins place `SKILL.md` at the plugin root rather than nesting `skills/<name>/SKILL.md`; only multi-skill plugins (agent-based-development) use the nested layout. The legacy `commands/` layout is removed, not dual-shipped.
- **Why:** Docs permit root `SKILL.md` for plugins shipping exactly one skill; it avoids a redundant `skills/<name>/skills/<name>/` nesting and keeps supporting directories reachable by relative links. Dual layouts are a known drift failure mode in this repo. See `docs/decisions/0001-migrate-to-skill-md-layout.md`.
- **Recorded by:** Claude (SKILL.md migration)
- **Date:** 2026-07-08

---

- **Assumption:** doc-refresh describes its STE option as "ASD-STE100 Issue 9 writing rules, tiered, no controlled dictionary", not as a percentage of STE.
- **Why:** The STE rules do not carry equal weight, and no published source defines "80% STE". Tier 1 (sentence limits, one instruction per step, notices before the step, one term per concept) applies to every doc. Tier 2 (imperative, active voice, no modal verbs or "-ing" phrases) applies to procedural and reference docs, where it helps most and costs least readability.
- **Recorded by:** Claude (skills update 2026-10)
- **Date:** 2026-10-15

---

- **Assumption:** The doc-refresh pre-commit hook runs `check` mode by default; write mode is opt-in with `DOC_REFRESH_HOOK_MODE=write`.
- **Why:** A hook runs non-interactively, so it cannot ask the preflight questions (overwrite uncommitted docs, delete stale docs). A run on 2026-10-14 showed that two concurrent doc writers overwrite each other's uncommitted work.
- **Recorded by:** Claude (skills update 2026-10)
- **Date:** 2026-10-15

---

- **Assumption:** Skills that install a git `pre-commit` hook mark it with `# claude-skill-hook: <skill>` on line 2, back up a foreign hook to `pre-commit.backup.<skill>`, chain that backup first, and uninstall only a hook that carries their own marker.
- **Why:** pre-commit and doc-refresh both own `pre-commit`. A shared backup name let the second install destroy the first backup, and uninstall deleted hooks it did not install.
- **Recorded by:** Claude (skills update 2026-10)
- **Date:** 2026-10-15

---

- **Assumption:** full-security-review keeps OWASP Top 10 for LLM Applications 2025 codes, written with the year (for example `LLM07:2025`).
- **Why:** OWASP published a 2026 edition in August 2026 with new numbering, but its category names could not be confirmed from a primary source. The year suffix prevents confusion with 2026 codes. Revisit when the 2026 list is confirmed.
- **Recorded by:** Claude (skills update 2026-10)
- **Date:** 2026-10-15

---

- **Assumption:** dependency-audit rates a CVE with CVSS below 7.0 as HIGH when its EPSS score is in the top 5%.
- **Why:** EPSS predicts exploitation better than CVSS alone. The 5% cutoff is a local rule, not a published standard; change it if it produces too many HIGH findings.
- **Recorded by:** Claude (skills update 2026-10)
- **Date:** 2026-10-15

---

- **Assumption:** Skill frontmatter uses model aliases (`haiku`, `sonnet`, `opus`) or no `model` line, never a pinned model ID.
- **Why:** Aliases follow the newest model in each family, so skills never point at a retired model. incident-report uses `sonnet` for customer-facing prose; adr inherits the session model for its interview and architecture prose.
- **Recorded by:** Claude (skills update 2026-10)
- **Date:** 2026-10-15
