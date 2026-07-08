<!--
doc: ASSUMPTIONS
last-refreshed: 2026-04-07
generated-by: doc-refresh skill
-->

# Assumptions

Non-obvious decisions made during development. Each entry records the assumption, rationale, author, and date.

---

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
