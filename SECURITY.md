<!--
doc: security
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# Security Policy

## Scope

This policy covers the Claude Code Skills Marketplace repository:

| Area | Path | Risk |
|---|---|---|
| Skill content | `skills/*/SKILL.md`, `skills/*/skills/*/SKILL.md`, and supporting files (`templates/`, `rules/`, `standards/`, `scripts/`) | The instructions run with the Claude Code permissions that the user gives. |
| Tool scripts | `scripts/`, `tests/` | The scripts run on contributor machines and in CI. |
| CI/CD workflows | `.github/workflows/` | The workflows run with repository tokens. |

## Report a vulnerability

> **SECURITY:** Do not open a public GitHub issue for a vulnerability.

1. Go to the
   [Security tab](https://github.com/RealDougEubanks/ClaudeMarketplace/security) of this
   repository.
2. Select **Report a vulnerability**.
3. Give the steps to reproduce the problem, the affected files, and the possible impact.

If you cannot use GitHub reporting, send an email to `security@realdougeubanks.dev`.

> **SECURITY:** Do not put real tokens, passwords, or personal data in a report. Use
> placeholders. If a token was exposed, revoke it first.

## What to report

Report each problem that lets a skill do one of these things:

- Run commands on a user's machine that the skill does not declare.
- Send files, credentials, or environment variables out of the machine without the user's
  knowledge.
- Get around the Claude Code permission system.
- Inject instructions that override Claude's safety guidelines (prompt injection).

Also report vulnerabilities in the CI/CD pipeline or the scripts, and any credential in the
repository.

## Response targets

| Stage | Target |
|---|---|
| Acknowledgement | 48 hours or less |
| First assessment | 5 business days or less |
| Fix or mitigation | Set by severity. A critical problem gets a fix in 7 days or less. |

## Skill safety model

Skills run inside Claude Code with the permissions that the user gives. Each skill declares
its tools in `metadata.json` and in the `allowed-tools` field of `SKILL.md`. Read these
declarations before you enable a skill.

CI runs `scripts/scan-prompts.sh` on each skill before a merge. The scanner flags dangerous
patterns. It is a best-effort control, not a guarantee.

A skill can have a `.scan-exempt` file. The file lists patterns that the skill needs and that
a reviewer accepted, with one pattern on each line. Lines that start with `#` are comments.
Security audit skills use exemptions because they must name sensitive terms. Reviewers
examine each change to a `.scan-exempt` file with extra care.

## Out of scope

- Vulnerabilities in Claude Code itself. Report them to Anthropic.
- Attacks that need physical access to the user's machine.
- Social engineering.
