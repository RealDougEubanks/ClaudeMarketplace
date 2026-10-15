<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# golden-rules

This skill installs a block of mandatory project standards into the `CLAUDE.md` file of your project. The standards cover security, coding, design, testing, error handling, API contracts, performance, and operations. Claude Code loads `CLAUDE.md` at the start of each session, so the rules apply to every session. You do not run the slash command again for each session.

## What It Does

When you run `/golden-rules`, Claude does these steps:

1. Reads `./CLAUDE.md` and searches it for a `## Golden Rules` section.
2. If the file does not exist, Claude creates it with the Golden Rules block.
3. If the file exists but has no `## Golden Rules` section, Claude appends the block to the end of the file.
4. If the section exists, Claude reads the version marker `<!-- golden-rules vX.Y.Z -->` in the section.
5. If the marker version is the same as the skill version, Claude tells you the rules are current and stops.
6. If the marker is missing or older, Claude tells you to run `/golden-rules --update`. Claude does not change the file.
7. Claude tells you the result: fresh install, update from an older version, or already current.

The current skill version is 1.9.0. The installed block carries the marker `<!-- golden-rules v1.9.0 -->`.

This is a `base` skill. Claude does not start it automatically (`disable-model-invocation: true`). You must type the slash command.

> **Context cost:** The installed block is about 160 lines and 2,600 words of always-on context in every Claude Code session for the project. That cost is intentional, because the rules must apply everywhere. Think about it for very small projects or tight context budgets.

## Usage

| Slash command | Result |
|---------------|--------|
| `/golden-rules` | Installs the block if it is not present. Reports an older install, but does not change it. |
| `/golden-rules --update` | Replaces the `## Golden Rules` section if its marker is missing or older. Does nothing if the section is current. |
| `/golden-rules --force` | Replaces the `## Golden Rules` section unconditionally |

> **CAUTION:** `--update` and `--force` replace all text from the `## Golden Rules` heading to the next `##` heading. Local edits in that section are lost. Move project-specific rules to a different section before you run the slash command.

```
/golden-rules --update
```

## The Golden Rules

The installed block covers these areas.

### Security (Non-Negotiable)

- Security comes first in every decision.
- No insecure storage of secrets, passwords, API keys, or PII. Hash passwords with Argon2id, bcrypt, or scrypt.
- Password policy per NIST SP 800-63B-4: breached-password screening, no composition or rotation rules, phishing-resistant MFA (passkeys).
- Design for untrusted input, least privilege, and secure defaults.
- Sanitize, length-check, type, and unit-test all inputs. Trap and handle all exceptions.
- Record accepted risks in `docs/assumptions.md`.

### AI-Generated Copy

- No AI-isms in user-facing text, docs, READMEs, commit messages, or comments.
- The rule lists forbidden phrases and patterns. Edit AI output before it ships.

### Coding & Naming Guidelines

- Per-language naming table: camelCase for JavaScript/TypeScript, snake_case for Python and SQL, kebab-case for CSS classes.
- Strict typing and schema validation at all input boundaries.
- No hardcoded credentials. No placeholder code in production paths.
- Task notes go in `docs/ToDo.md`, not in `// TODO` comments. Remove dead code.

### Design & UX Guidelines

- Support light and dark mode, and persist the user preference.
- Minimalist, clean visual design with clear hierarchy.
- Responsive layouts for mobile, tablet, and desktop.
- WCAG 2.2 AA contrast minimum. Do not use color as the only signal of meaning.

### Testing Standards

- Each module with logic must have tests. Give tests descriptive names.
- Test behavior, not implementation. Write the failing test first for a bug fix.
- No flaky tests. Integration tests for critical paths.

### Error Handling

- Never swallow exceptions. Use structured error objects with codes.
- Log with severity, timestamp, and correlation ID. Fail fast on invalid state.

### API & Data Contracts

- Schema-validate all inputs at boundaries. Sanitize user input.
- Version APIs explicitly. Keep backward compatibility.
- Document every public endpoint.

### Performance Basics

- No N+1 queries. All list endpoints must paginate.
- Async I/O for network and file operations. Cache with defined TTLs.
- Timeouts on every external call. No unbounded algorithms on unbounded inputs.

### Git Hygiene

- Never commit directly to `main`. Use a branch and a PR, with no exceptions.
- Branch names: `feature/`, `fix/`, `hotfix/`, or `claude/`.
- A solo maintainer can self-merge after CI passes and a self-review.

### Logging & Observability

- Structured logs (JSON or logfmt) with correlation IDs. No `console.log` in production.
- Log security events (failed logins, permission changes) and outbound integrations.
- Never log secrets or raw PII. Emit rate, latency, and queue metrics with owned alerts.

### Health Checks & Uptime Monitoring

- Each service exposes `/healthz`, `/readyz`, and a deep `/health` dependency check.
- Return 200 when healthy and 503 when not. Configure an external uptime monitor.

### Caching & CDN

- Explicit `Cache-Control`, `ETag`, and `Vary` per route. Never use framework defaults.
- Cache immutable versioned assets for a year. Send `private, no-store` for authenticated pages.
- Provide a cache-purge path. The block includes CloudFlare-specific rules.

### Code Efficiency & Dependency Hygiene

- Each line has a purpose. Justify each new dependency against its size and security surface.
- Prefer the standard library. Prefer clarity over cleverness.

### Resource Stewardship

- Subscribe instead of polling. Cache results instead of computing them again.
- Never block the UI thread on I/O. Support a degraded "lean" mode. Report truthful telemetry.

### Platform-Specific Guidelines

- Apple HIG on Apple platforms, Material Design on Android, Red Hat and POSIX conventions on Linux, Fluent/WinUI on Windows.
- Cross-platform code follows the conventions of each host.

### Assumptions Tracking

- Record each non-obvious decision in `docs/assumptions.md` with the assumption, the reason, the author, and the date.

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "golden-rules@claude-skills-marketplace": true
  }
}
```

Then run `/golden-rules` in any Claude Code session.

## Example CLAUDE.md Output

After installation, the `CLAUDE.md` file of your project contains:

```markdown
## Golden Rules

<!-- golden-rules v1.9.0 — do not remove; used by /golden-rules --update -->

GOLDEN RULES (MANDATORY — ALL WORK IN THIS PROJECT MUST FOLLOW THESE)

1. Security is paramount. Every design, implementation, and review decision must prioritize security. When in doubt, choose the more secure option and document the assumption in docs/assumptions.md.
...
```

## When to Use

- At the start of a new project.
- When you add an existing codebase to Claude Code.
- When you want the same security and quality standards in all Claude Code sessions for a project.
