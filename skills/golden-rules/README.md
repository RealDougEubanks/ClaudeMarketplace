# golden-rules

Installs mandatory security, coding, design, testing, error handling, API contract, and performance standards into your project's `CLAUDE.md` so they are always-on context for every Claude Code session — no need to invoke a command on each session.

## What It Does

When you run `/golden-rules`, Claude:

1. Checks whether `./CLAUDE.md` exists and whether a `## Golden Rules` section is already present.
2. If not present, writes (or appends) the full Golden Rules block to `CLAUDE.md`, stamped with a version marker.
3. If an older version is present, tells you to run `/golden-rules --update` to replace it with the current block. `--force` replaces unconditionally.
4. Confirms what was written.

Because Claude Code automatically loads `CLAUDE.md` at the start of every session, the rules become permanent project context — not just a one-time prompt.

**This is a `base` skill.** When invoked via `/golden-rules` also appends the skill content to `CLAUDE.md` automatically.

> **Token cost note:** the installed block is roughly 155 lines (~2,500 tokens) of always-on context loaded into every Claude Code session in the project. That is the point — the rules apply everywhere — but factor it in for very small projects or tight context budgets.

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

### Git Hygiene
- Never commit directly to `main` — branch and PR, no exceptions.
- Branch naming: `feature/`, `fix/`, `hotfix/`, or `claude/`.
- Solo-maintainer repos may self-merge after CI passes and a self-review.

### Logging & Observability
- Structured logs (JSON or logfmt) with correlation IDs — no `console.log` in production.
- Log security events (failed logins, permission changes) and outbound integrations.
- Never log secrets or raw PII. Emit rate/latency/queue metrics with owned alerts.

### Health Checks & Uptime Monitoring
- Every service exposes `/healthz`, `/readyz`, and a deep `/health` dependency check.
- 200 when healthy, 503 when not. Configure an external uptime monitor.

### Caching & CDN
- Explicit `Cache-Control`/`ETag`/`Vary` per route — never framework defaults.
- Immutable versioned assets cached for a year; authenticated pages `private, no-store`.
- Provide a cache-purge path. CloudFlare-specific rules included.

### Code Efficiency & Dependency Hygiene
- Every line has a purpose. Justify each new dependency against size and security surface.
- Prefer the standard library. Clarity over cleverness.

### Resource Stewardship
- Don't poll when you can subscribe; don't recompute what you can cache.
- Never block the UI thread on I/O. Support a degraded "lean" mode. Truthful telemetry.

### Platform-Specific Guidelines
- Apple HIG on Apple platforms, Material Design on Android, Red Hat/POSIX conventions on Linux, Fluent/WinUI on Windows.
- Cross-platform code branches to honor each host's conventions.

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
