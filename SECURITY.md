# Security Policy

## Scope

This security policy covers the **Claude Code Skills Marketplace** repository, including:

- Skill content (`skills/*/skill.md`) — prompt instructions that execute with user-granted Claude Code permissions
- Tooling scripts (`scripts/`) — shell and Python scripts run locally and in CI
- CI/CD workflows (`.github/workflows/`) — automated pipelines with repository write access

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Use GitHub's private vulnerability reporting feature:

1. Go to the [Security tab](../../security) of this repository
2. Click **"Report a vulnerability"**
3. Fill in the details — include steps to reproduce, affected files, and potential impact

You can also email **security@realdougeubanks.dev** if you prefer not to use GitHub's reporting tool.

## What to Report

Report anything that could allow a skill to:

- Execute unintended commands on a user's machine (beyond what the skill declares in `metadata.json`)
- Exfiltrate files, credentials, or environment variables without user awareness
- Bypass Claude Code's permission system
- Inject instructions that override Claude's safety guidelines (prompt injection)

Also report vulnerabilities in the CI/CD pipeline, scripts, or any hardcoded credentials.

## Response Timeline

| Stage | Target |
|-------|--------|
| Acknowledgement | Within 48 hours |
| Initial assessment | Within 5 business days |
| Fix or mitigation | Depends on severity — critical issues within 7 days |

## Skill Safety Model

Skills in this marketplace run inside Claude Code with permissions explicitly granted by the user. Each skill declares the tools it uses in `metadata.json`. Users should review tool declarations before installing a skill.

The CI pipeline runs `scripts/scan-prompts.sh` on all skill content to flag potentially dangerous patterns before merge. This is a best-effort control, not a guarantee.

## Out of Scope

- Vulnerabilities in Claude Code itself (report to Anthropic)
- Issues requiring physical access to the user's machine
- Social engineering attacks
