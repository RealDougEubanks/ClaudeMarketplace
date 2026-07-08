<!--
doc: SECURITY
last-refreshed: YYYY-MM-DD
generated-by: doc-refresh skill
-->

# Security Policy

## Reporting a Vulnerability

> **SECURITY: Do NOT open a public GitHub issue for security vulnerabilities.**

Report privately via: <email or GitHub Security Advisory URL>

Expected acknowledgment: within 48 hours.

## Sensitive Data This Project Handles

<List detected from code: auth tokens, PII fields, payment data, API keys, etc.>

## Credential and Secret Rules

> **SECURITY:** All secrets must be in environment variables or a secrets manager.
> Never commit secrets. Rotate immediately if exposed.

- Local dev: use `.env` (never committed — already in `.gitignore`).
- Production: use the secrets manager listed in `docs/ENV_VARS.md`.

## Dependency Security

Run `<npm audit / pip-audit / govulncheck>` before every release.

## Known Security Controls

<Populate from detected auth middleware, rate limiting, input validation, HTTPS enforcement, etc.>
