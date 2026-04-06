# Claude Code Skills Marketplace — Project Context

This is the **Claude Code Skills Marketplace** repository. It is a collection of reusable prompt skills for Claude Code — each skill is a directory under `skills/` containing `skill.md` (Claude's instructions), `metadata.json` (machine-readable metadata), and `README.md` (human docs).

When working in this repo, your job is to help build, validate, and publish skills. Always follow the contribution conventions below.

## Contribution Conventions

- Skill directory names must be **kebab-case** (e.g. `git-workflow`, `golden-rules`).
- Each skill directory contains exactly **three files**: `commands/<skill-name>.md`, `metadata.json`, `README.md`.
- The skill content lives at `commands/<skill-name>.md` with YAML frontmatter (`name`, `description`). This is what the Claude Code plugin system uses to register the slash command automatically on install.
- `metadata.json` must validate against `schema/metadata.schema.json`.
- After creating or editing a skill, run `./scripts/validate.sh skills/<skill-name>`.
- After adding a skill directory, update `skills/registry.json` and run `./scripts/check-registry.sh`.
- Use `./scripts/new-skill.sh <name>` to scaffold a new skill from templates.
- Use `./scripts/install.sh skills/<name> [project-dir]` to install a skill into a project.
- Do not modify `skills/example-skill/` — it is the canonical reference for contributors.

## Versioning Rules (MANDATORY)

Every change to a skill's content or structure **requires** both of the following before merging:

1. **Bump the version** in `skills/<skill-name>/metadata.json` (semver patch for fixes/tweaks, minor for new behavior).
2. **Sync `skills/registry.json`** — the `version` field for that skill must match `metadata.json` exactly.

Run `./scripts/check-registry.sh` to catch mismatches. The CI pipeline enforces both via `scripts/check-version-bump.py` and the registry cross-validation check.

## Golden Rules

GOLDEN RULES (MANDATORY — ALL WORK IN THIS PROJECT MUST FOLLOW THESE)

1. Security is paramount. Every design, implementation, and review decision must prioritize security. When in doubt, choose the more secure option and document the assumption in docs/assumptions.md.

2. Do not store secrets, passwords, keys, PII, or other sensitive data insecurely.
   - Passwords: Hash with a strong adaptive function (Argon2, bcrypt, scrypt). Never store plaintext or reversibly encrypted passwords.
   - API keys, tokens, secrets: Use environment variables or a secrets manager. Never commit to the repo or log.
   - PII: Encrypt at rest and in transit. Minimize collection and retention. Follow applicable privacy rules.
   - Other sensitive data: Use encryption or hashing as appropriate. Document non-obvious choices in docs/assumptions.md.

3. Always assume the application could be the target of exploitation. Design for untrusted input, defense in depth, least privilege, and secure defaults. Document any accepted risks in docs/assumptions.md.

CODING & NAMING GUIDELINES (apply unless project explicitly overrides in docs/assumptions.md)

- camelCase for variables, functions, and filenames.
- Exceptions: snake_case or PascalCase only when the language or framework strictly requires it.
- kebab-case for CSS class names.
- Strict typing and schema validation (e.g. Zod, Pydantic, or language-equivalent) for all inputs and boundaries.
- No hardcoded API keys, credentials, or secrets — use configuration or secrets management.
- No placeholder or stub code in production paths — write complete, functional code.
- Move task notes to docs/ToDo.md or docs/ — do not leave // TODO in the codebase for project tracking.

DESIGN & UX GUIDELINES (apply unless project explicitly overrides)

- Caching: Prefer designs that support caching where appropriate (HTTP cache headers, CDN, app-level) to improve performance.
- Light and dark mode: Support both themes with easy switching (toggle, system preference, or both). Persist user preference.
- Visual design: Prefer minimalist, clean designs. Avoid clutter; use clear hierarchy and whitespace.
- Responsive design: Layouts must be responsive — usable across mobile, tablet, and desktop. Use fluid layouts and touch-friendly targets.
- Accessibility: Choose accessible and pleasant color palettes. WCAG AA contrast minimum. Do not rely on color alone for meaning.

ASSUMPTIONS TRACKING

Any time a non-obvious decision is made, record it in docs/assumptions.md:
- Assumption: one clear sentence
- Why: rationale
- Recorded by: <agent or developer name>
- Date: YYYY-MM-DD
