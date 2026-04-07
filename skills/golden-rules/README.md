# golden-rules

Installs mandatory security, coding, design, testing, error handling, API contract, and performance standards into your project's `CLAUDE.md` so they are always-on context for every Claude Code session — no need to invoke a command on each session.

## What It Does

When you run `/golden-rules`, Claude:

1. Checks whether `./CLAUDE.md` exists and whether a `## Golden Rules` section is already present.
2. If not present, writes (or appends) the full Golden Rules block to `CLAUDE.md`.
3. Confirms what was written.

Because Claude Code automatically loads `CLAUDE.md` at the start of every session, the rules become permanent project context — not just a one-time prompt.

**This is a `base` skill.** When invoked via `/golden-rules` also appends the skill content to `CLAUDE.md` automatically.

## The Golden Rules

The installed block covers these areas:

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

### Testing Standards
- Every module with logic must have tests. Name tests descriptively.
- Test behavior, not implementation. Write the failing test first when fixing bugs.
- No flaky tests. Integration tests for critical paths.

### Error Handling
- Never swallow exceptions. Use structured error objects with codes.
- Log with severity, timestamp, and correlation ID. Fail fast on invalid state.

### API & Data Contracts
- Schema-validate all inputs at boundaries. Sanitize user input.
- Version APIs explicitly. Maintain backward compatibility.
- Document every public endpoint.

### Performance Basics
- No N+1 queries. All list endpoints must paginate.
- Async I/O for network and file operations. Cache with defined TTLs.
- Timeouts on every external call. No unbounded algorithms on unbounded inputs.

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "golden-rules@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/golden-rules` in any Claude Code session.
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
