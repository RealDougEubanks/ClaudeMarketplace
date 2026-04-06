---
name: golden-rules
description: Installs mandatory security, coding, naming, and design standards into CLAUDE.md as always-on context for every Claude Code session.
---

# Golden Rules — Always-On Project Standards

Install mandatory security, coding, and design standards into this project's CLAUDE.md so they are active for every Claude Code session automatically.

## Instructions

1. Use Read to check if `./CLAUDE.md` exists in the current working directory.

2. Use Grep to search `./CLAUDE.md` for the string `## Golden Rules` (if the file exists).
   - If the section header is found: inform the user the Golden Rules are already installed and stop.
   - If not found: proceed to step 3.

3. If `CLAUDE.md` does not exist, use Write to create it with the Golden Rules Block below as the full content.
   If `CLAUDE.md` exists but lacks the section, use Edit to append the Golden Rules Block to the end of the file.

4. Confirm to the user what was written and that the Golden Rules are now active for every Claude Code session in this project.

## Golden Rules Block

Write or append the following content verbatim:

---

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

- camelCase for variables, functions, and filenames (see language-specific table below).
- Language-specific naming conventions:

  | Language | Variables/Functions | Files | Classes |
  |----------|-------------------|-------|---------|
  | JavaScript/TypeScript | camelCase | camelCase | PascalCase |
  | Python | snake_case | snake_case | PascalCase |
  | Go | camelCase (unexported) / PascalCase (exported) | snake_case | PascalCase |
  | SQL | snake_case | snake_case | N/A |
  | CSS classes | kebab-case | kebab-case | N/A |

- Strict typing and schema validation (e.g. Zod, Pydantic, or language-equivalent) for all inputs and boundaries.
- No hardcoded API keys, credentials, or secrets — use configuration or secrets management.
- No placeholder or stub code in production paths — write complete, functional code.
- Move task notes to docs/ToDo.md or docs/ — do not leave // TODO in the codebase for project tracking.
- Remove dead code before committing — commented-out code blocks, unused imports, unreachable functions, and orphaned files are not acceptable in production paths.

DESIGN & UX GUIDELINES (apply unless project explicitly overrides)

- Caching: Prefer designs that support caching where appropriate (HTTP cache headers, CDN, app-level) to improve performance.
- Light and dark mode: Support both themes with easy switching (toggle, system preference, or both). Persist user preference.
- Visual design: Prefer minimalist, clean designs. Avoid clutter; use clear hierarchy and whitespace.
- Responsive design: Layouts must be responsive — usable across mobile, tablet, and desktop. Use fluid layouts and touch-friendly targets.
- Accessibility: Choose accessible and pleasant color palettes. WCAG AA contrast minimum. Do not rely on color alone for meaning.

GIT HYGIENE (MANDATORY)

- Never commit or push directly to `main`. All changes must go through a branch and PR, no exceptions.
- Branch from the current release branch (or `main` if no release branch exists). Name branches `feature/`, `fix/`, `hotfix/`, or `claude/` as appropriate.
- If you find yourself on `main` with uncommitted changes, stash or move them to a new branch before committing.
- No PR may be merged without at least one approval from a reviewer other than the author. Self-merge is not permitted.

PYTHON ENVIRONMENT (MANDATORY)

- Never install Python packages into the OS Python install. Always use a virtual environment.
- Create a venv at the project root: `python3 -m venv .venv`
- Activate before running or installing: `source .venv/bin/activate`
- Add `.venv/` to `.gitignore` — never commit it.
- Pin all dependencies in `requirements.txt` (or `pyproject.toml`). Use `pip freeze > requirements.txt` after installing.

CLAUDE CODE PLUGIN & SKILL LAYOUT (MANDATORY)

Skills and plugins installed via the Claude Code plugin system must follow this layout so they are discovered automatically as slash commands:

```
skills/<skill-name>/
  commands/
    <skill-name>.md     ← skill content with YAML frontmatter (name, description)
  metadata.json
  README.md
```

- The command file must be at `commands/<skill-name>.md` — NOT at `skill.md` in the plugin root.
- The YAML frontmatter in `commands/<skill-name>.md` must include `name` and `description` fields.
- Run `./scripts/validate.sh skills/<skill-name>` after creating or editing a skill.
- Use `./scripts/new-skill.sh <name>` to scaffold; it generates the correct structure automatically.

ASSUMPTIONS TRACKING

Any time a non-obvious decision is made, record it in docs/assumptions.md:
- Assumption: one clear sentence
- Why: rationale
- Recorded by: <agent or developer name>
- Date: YYYY-MM-DD

---

## Output Format

Report to the user:
- Whether `CLAUDE.md` was created new or updated (appended).
- That the `## Golden Rules` section is now active.
- That every future Claude Code session in this project directory will load these rules automatically as context.
