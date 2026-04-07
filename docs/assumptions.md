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
