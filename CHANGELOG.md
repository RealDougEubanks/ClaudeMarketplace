# Changelog

All notable changes to the Claude Code Skills Marketplace are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions follow [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

*No unreleased changes.*

---

## [1.1.1] — 2026-04-05

### Changed

- `scripts/validate.sh` — replaced brittle grep-based field detection with Python JSON parsing for reliable required-field validation
- `scripts/install.sh` — added existence guard for project directory; fails fast with a clear error if `project-dir` does not exist
- `scripts/new-skill.sh` — author name and GitHub handle now read from git config instead of being hardcoded, enabling community contributors to scaffold skills correctly
- `CONTRIBUTING.md` — Step 1 now leads with `./scripts/new-skill.sh` as the primary scaffold method
- `.claude-plugin/marketplace.json` — synced versions for `golden-rules`, `agent-based-development`, `mvp-readiness`, `security-review`, and `git-workflow` from `1.0.0` to `1.1.0` to match their `metadata.json` files

---

## [1.1.0] — 2026-04-05

### Added
- `accessibility` — WCAG 2.2 AA audit (review mode) and accessible component design guidance (design mode)
- `adr` — Architecture Decision Records management using MADR format
- `api-design` — REST, GraphQL, and gRPC API design and review
- `architecture-design` — System/feature architecture from requirements to C4 diagrams and API contracts
- `architecture-review` — Existing architecture audit for anti-patterns, scalability, and testability gaps
- `best-practices` — Holistic stack-aware codebase audit with prioritized improvement roadmap
- `database-design` — Database schema design (ERD, indexes, migrations) and review
- Golden Rules section added to `CLAUDE.md` with language-specific naming conventions, Git hygiene, Python environment, and Claude Code plugin layout rules

### Changed
- `golden-rules` skill updated to v1.1.0 — replaces existing section in `CLAUDE.md` rather than aborting when section is already present
- `agent-based-development`, `mvp-readiness`, `security-review`, `git-workflow` bumped to v1.1.0
- All skills restructured to `commands/<skill-name>.md` layout with YAML frontmatter for Claude Code plugin discovery
- `skills/registry.json` versions synced with `metadata.json` across all skills

---

## [1.0.0] — 2026-03-01

### Added
- Initial marketplace with 15 skills across workflow, standards, security, and productivity categories:
  - `golden-rules` — mandatory security, coding, and design standards for CLAUDE.md
  - `agent-based-development` — async multi-agent dev workflow (Plan → Design → Dev → Review)
  - `mvp-readiness` — structured MVP quality-gate audit
  - `security-review` — OWASP-aligned security audit with severity-graded findings
  - `git-workflow` — release-branch Git model with PR and tagging automation
  - `code-review` — structured engineering code review (readability, complexity, SOLID)
  - `test-writer` — comprehensive unit and integration test generation
  - `dependency-audit` — unpinned versions, deprecated packages, and CVE scanning
  - `changelog-generator` — CHANGELOG.md generation from git history
  - `onboarding` — developer onboarding guide from codebase analysis
  - `requirements-generator` — structured requirements with Gherkin acceptance criteria
  - `log-correlation` — multi-source log correlation and troubleshooting
  - `incident-report` — professional incident report generation with templates
  - `pre-commit` — fast pre-commit quality gate (secrets, dead code, conflict markers)
  - `example-skill` — canonical reference skill for contributors
- `scripts/new-skill.sh` — scaffold a new skill from templates
- `scripts/validate.sh` — validate skill directory structure and metadata
- `scripts/install.sh` — install a skill into a Claude Code project
- `scripts/check-registry.sh` — verify registry.json is consistent with skill directories
- `schema/metadata.schema.json` — JSON Schema for skill metadata validation
- `.claude-plugin/marketplace.json` — plugin registry for Claude Code marketplace discovery
- `templates/` — canonical skill template files
- GitHub Actions CI for skill validation on PRs
