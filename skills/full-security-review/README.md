# security-review

Adopt the Security Agent persona and run a structured security audit of any codebase. Produces severity-graded findings in both markdown and (when the ABD workflow is active) JSON artifact format.

## What It Does

When you run `/security-review`, Claude:

1. Asks for audit scope (or defaults to the whole project).
2. Uses Glob and Read to examine all source files.
3. Uses Grep to detect common vulnerability patterns.
4. Checks each vulnerability category in a structured checklist.
5. Assigns severity to every finding: `critical | severe | moderate | low | info`.
6. Produces a markdown Security Review Report.
7. If `handoffs/reviews/` exists (ABD workflow active), also writes a JSON artifact.

## Vulnerability Categories Covered

| Category | Examples |
|----------|---------|
| Injection | SQL, command, XSS, template injection |
| Auth & Authorization | Hardcoded credentials, missing auth, broken access control, insecure sessions |
| Secrets & Sensitive Data | Secrets in code/logs, weak password hashing, data in transit without TLS |
| Input Validation | Missing sanitization, path traversal, insecure deserialization |
| Dependencies & Config | Outdated packages, debug mode in production, permissive CORS/CSP |
| Cryptography | MD5/SHA1, hardcoded IVs, short keys |

## Severity Scale

| Severity | When to Use |
|----------|-------------|
| critical | Immediate exploitation likely; data breach risk. Fix before any merge. |
| severe | High impact; fix before release. |
| moderate | Real risk; fix in next sprint. |
| low | Minor; fix when convenient. |
| info | Observation; no immediate risk. |

## Usage

```
/security-review
```

Invoke in the project root. Claude will audit the current working directory.

To scope to a specific directory or file:

```
/security-review — audit src/auth/ only
```

## Example Output

```markdown
## Security Review — my-app — 2026-01-15

### Summary
| Severity | Count |
|----------|-------|
| critical | 1 |
| severe | 0 |
| moderate | 2 |
| low | 1 |
| info | 3 |

### Findings

**[CRITICAL] Hardcoded API key in source**
- **File:** `src/config.ts:14`
- **Description:** STRIPE_SECRET_KEY hardcoded as a string literal.
- **Recommendation:** Move to environment variable; rotate the key immediately.
```

## Integration with Agent-Based Development

When used as part of the `/agent-based-development` workflow (`/abd-security`), this skill also writes a JSON artifact to `handoffs/reviews/`. Findings with `critical`, `severe`, or `moderate` severity block the PR and return to Planning for triage.

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "security-review@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/security-review` in any Claude Code session.
## Related Skills

- `/golden-rules` — install always-on security standards
- `/mvp-readiness` — broad MVP quality gate including security checks
- `/agent-based-development` — full workflow with Security Agent role built in
