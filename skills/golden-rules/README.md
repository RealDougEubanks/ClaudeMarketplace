# golden-rules

Installs mandatory security, coding, and design standards into your project's `CLAUDE.md` so they are always-on context for every Claude Code session — no need to invoke a command on each session.

## What It Does

When you run `/golden-rules`, Claude:

1. Checks whether `./CLAUDE.md` exists and whether a `## Golden Rules` section is already present.
2. If not present, writes (or appends) the full Golden Rules block to `CLAUDE.md`.
3. Confirms what was written.

Because Claude Code automatically loads `CLAUDE.md` at the start of every session, the rules become permanent project context — not just a one-time prompt.

**This is a `base` skill.** Installing it via `install.sh` also appends the skill content to `CLAUDE.md` automatically.

## The Golden Rules

The installed block covers three areas:

### Security (Non-Negotiable)
- Security is paramount in every decision.
- No insecure storage of secrets, passwords, API keys, or PII.
- Design for untrusted input, least privilege, and secure defaults.
- Document accepted risks in `docs/assumptions.md`.

### Coding & Naming Guidelines
- camelCase for variables, functions, and filenames.
- kebab-case for CSS class names.
- Strict typing and schema validation at all input boundaries.
- No hardcoded credentials. No placeholder code in production paths.
- Task notes go in `docs/ToDo.md`, not `// TODO` comments.

### Design & UX Guidelines
- Support light and dark mode; persist user preference.
- Minimalist, clean visual design with clear hierarchy.
- Responsive layouts for mobile, tablet, and desktop.
- WCAG AA contrast minimum; never rely on color alone for meaning.

## Installation

### Using the install script (recommended)

```bash
# From the ClaudeMarketplace repo root, targeting your project:
./scripts/install.sh skills/golden-rules /path/to/your/project
```

This installs to `.claude/commands/golden-rules.md` **and** appends the Golden Rules to your project's `CLAUDE.md` (because this is a `base` category skill). The append is idempotent — running it twice will not duplicate the section.

### Manual invocation

In any Claude Code session inside a project:

```
/golden-rules
```

Claude will create or update `CLAUDE.md` in the current working directory.

## Example CLAUDE.md Output

After installation, your project's `CLAUDE.md` will contain:

```markdown
## Golden Rules

GOLDEN RULES (MANDATORY — ALL WORK IN THIS PROJECT MUST FOLLOW THESE)

1. Security is paramount. Every design, implementation, and review decision must
   prioritize security. When in doubt, choose the more secure option and document
   the assumption in docs/assumptions.md.
...
```

## When to Use

- At the start of any new project.
- When onboarding a new codebase to Claude Code.
- Anytime you want to enforce consistent security and quality standards across all Claude sessions in a project.
