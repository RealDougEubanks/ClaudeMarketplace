---
name: doc-refresh
description: Complete documentation refresh — audits for stale docs, creates missing docs, and rewrites everything for a 2am on-call engineer with zero assumed context. Security items are prominently callout-boxed.
---

# doc-refresh

Invoked via `/doc-refresh`. Performs a complete documentation refresh on the current project.
Treats all existing documentation as potentially stale. Writes for a reader who woke up at 2am
to an alert — no assumed knowledge, step-by-step, scannable, and security-forward.

---

## Persona (apply to ALL generated documentation)

Write every document as if the reader:

- Was paged at 2am and is not fully awake
- Has never seen this codebase before
- Needs to take action in under 5 minutes
- Will use an AI agent to navigate the docs

Rules for every document written or rewritten:

- **No assumed knowledge.** Define every acronym on first use.
- **Numbered steps for procedures.** Never use prose for a sequence of actions.
- **Short sentences.** Max ~20 words per sentence. Break long thoughts into bullets.
- **Security callouts are mandatory.** Any step involving credentials, secrets, auth tokens,
  network exposure, or permissions must be preceded by a `> **SECURITY:**` blockquote.
- **Tables over prose** for comparisons, env vars, commands, and structured data.
- **File + line references** when pointing to code: `src/auth/middleware.ts:42`.
- **Stale content is harmful.** A wrong doc is worse than no doc. Delete or correct it.
- **AI-friendly structure:** Use consistent heading hierarchy (H1 = project title,
  H2 = major sections, H3 = subsections). Each doc must start with an HTML metadata comment:

  ```html
  <!--
  doc: <DOC_TYPE>
  last-refreshed: YYYY-MM-DD
  generated-by: doc-refresh skill
  -->
  ```

---

## Mode A — Full refresh (default)

Run when invoked as `/doc-refresh` with no arguments.

### Step 1: Inventory

1. Use Glob `**/*.md` (exclude `node_modules/`, `vendor/`, `.git/`) to list all Markdown files.
2. Use Glob to map the project structure: `*`, `src/**`, `docs/**`, `scripts/**`.
3. Use Read on each of the following if they exist:
   - `README.md`, `CONTRIBUTING.md`, `SECURITY.md`
   - `docs/RUNBOOK.md`, `docs/ONBOARDING.md`, `docs/ENV_VARS.md`, `docs/assumptions.md`

### Step 2: Stale doc audit

For each `.md` file found:

1. Extract all code references: file paths, function names, command names, env var names.
2. For each **file path reference**: use Glob to confirm it still exists. If not, mark stale.
3. For each **env var reference**: use Grep to confirm it appears in at least one of:
   `.env.example`, `docker-compose.yml`, `*.tf`, source files. If not, mark stale.
4. For each **command reference** (e.g. `npm run foo`): use Read on `package.json`, `Makefile`,
   or `pyproject.toml` to confirm it exists. If not, mark stale.
5. Print a stale audit table before making any changes:

   ```
   Stale Doc Audit
   ───────────────────────────────────────────────────
   File                   | Stale Reference
   docs/OLD_SETUP.md      | path: scripts/setup-old.sh (not found)
   README.md              | command: npm run legacy (not in package.json)
   ```

6. For each stale doc, decide:
   - Topic still relevant but content is wrong → **rewrite**.
   - Topic no longer applies → **delete** with Bash (`rm <file>`).

### Step 3: Detect missing docs

Check for the following. Mark any absent for creation in Step 4.

| Doc | Path | Create if... |
|-----|------|--------------|
| README | `README.md` | Always |
| Runbook | `docs/RUNBOOK.md` | Any service or app |
| Contributing | `CONTRIBUTING.md` | Project with contributors |
| Env vars | `docs/ENV_VARS.md` | `.env.example` exists |
| Security policy | `SECURITY.md` | Auth, secrets, or external access |

### Step 4: Write / rewrite docs

Generate each missing or stale doc using the persona above. Use the templates below as the
baseline. Fill in all `<placeholder>` values from what you actually read in the codebase.
Do not leave any placeholder unfilled — if the information is not found, write `Unknown — verify`.

#### README.md

````markdown
<!--
doc: README
last-refreshed: YYYY-MM-DD
generated-by: doc-refresh skill
-->

# <Project Name>

**One sentence: what does this do and why does it exist.**

> **SECURITY:** <State here if project handles auth, payments, PII, or secrets. Link to SECURITY.md.>

## Quick Start

> **Prerequisites:** <List only non-standard requirements. E.g. "Node 20+, Docker 24+">

```bash
# 1. Clone and install
git clone <repo-url>
cd <project>
<install command>      # npm install / pip install -r requirements.txt / go mod download

# 2. Configure environment
cp .env.example .env
# Edit .env — fill in values marked REQUIRED

# 3. Run
<start command>
```

## What This Does

<2–4 sentences. Plain English. No jargon. Assume the reader has never heard of this.>

## Architecture in 30 Seconds

```mermaid
<Insert sequenceDiagram for request flows, graph LR for service dependencies>
```

## Key Files

| Path | Purpose |
|------|---------|

## Commands

| Command | What it does |
|---------|-------------|

## Environment Variables

> **SECURITY:** Never log or commit these values. See [`docs/ENV_VARS.md`](docs/ENV_VARS.md).

| Variable | Required | Description |
|----------|----------|-------------|

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).
````

#### docs/RUNBOOK.md

Before writing, gather data:

1. Use Read on the primary entry point to understand app startup.
2. Use Glob to find `docker-compose.yml`, `Makefile`, `Procfile`, `.github/workflows/**` — read them.
3. Use Grep across source files for: `process.exit`, `os.Exit`, `sys.exit`, `panic(` — crash conditions.
4. Use Grep for health endpoints: `/health`, `/healthz`, `/ping`, `/status`.
5. Use Grep for logged error messages to populate the Known Failure Modes table.

````markdown
<!--
doc: RUNBOOK
last-refreshed: YYYY-MM-DD
generated-by: doc-refresh skill
-->

# Runbook — <Service Name>

> **You were just paged. Start here.**

## Is the service alive?

```bash
# Quick health check
curl -f http://localhost:<port>/health || echo "HEALTH CHECK FAILED"

# Tail logs (last 50 lines)
<log command — docker logs / journalctl / kubectl logs / tail -n 50 /var/log/...>
```

Expected healthy response: `{ "status": "ok" }` (or equivalent — fill in the actual shape).

## Service Overview

| Property | Value |
|----------|-------|
| Port | |
| Health endpoint | `/health` |
| Log location | |
| Restart command | |
| Deployed via | |

## Start / Stop / Restart

```bash
# Start
<command>

# Stop (graceful)
<command>

# Restart
<command>
```

> **SECURITY:** If restarting due to a suspected security incident, do NOT restart in place.
> Isolate the instance first. Contact the security team before bringing it back online.

## Known Failure Modes

| Symptom | Root cause | Immediate fix |
|---------|-----------|---------------|

## Environment Variables

> **SECURITY:** Never log, print, or commit these values. Rotate immediately if exposed.

| Variable | Required | Description | Where to find it |
|----------|----------|-------------|-----------------|

## Rollback

```bash
# See recent commits
git log --oneline -10

# Revert the last commit (safe — creates a new commit)
git revert HEAD

# Or roll back a container image
docker pull <image>:<previous-tag>
```

## Escalation Path

If not resolved in 15 minutes: <CODEOWNERS contact, team Slack, or on-call rotation>
````

#### CONTRIBUTING.md

````markdown
<!--
doc: CONTRIBUTING
last-refreshed: YYYY-MM-DD
generated-by: doc-refresh skill
-->

# Contributing to <Project Name>

## Before You Start

1. Read `README.md` to understand what the project does.
2. Check open issues — avoid duplicate work.
3. For large changes, open an issue first to discuss the approach.

> **SECURITY:** Never commit secrets, API keys, tokens, or credentials.
> They are hard to revoke once pushed. See `SECURITY.md`.

## Workflow

1. Branch from `main`:
   ```bash
   git checkout main && git pull
   git checkout -b feature/short-description
   ```
2. Make your changes.
3. Run tests: `<test command>`
4. Ensure no linting errors: `<lint command>`
5. Open a PR with a clear title and description.

## PR Checklist

- [ ] Tests pass
- [ ] No new secrets or hardcoded credentials
- [ ] Docs updated if behavior changed
- [ ] At least 1 reviewer approved before merge

## Code Style

<Populate from .eslintrc / .prettierrc / pyproject.toml / golangci.yml — or state: "Run the linter">
````

#### SECURITY.md (only if project has auth, secrets, PII, or external access)

````markdown
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
````

#### docs/ENV_VARS.md (only if `.env.example` exists)

1. Use Read on `.env.example` to get every variable name.
2. Use Grep across source files to find where each variable is consumed.

````markdown
<!--
doc: ENV_VARS
last-refreshed: YYYY-MM-DD
generated-by: doc-refresh skill
-->

# Environment Variables

> **SECURITY:** Never log, share, or commit values from `.env`.
> Rotate secrets immediately if exposed.

Copy `.env.example` to `.env` and fill in all `REQUIRED` values before running.

## Variable Reference

| Variable | Required | Default | Description | Used in |
|----------|----------|---------|-------------|---------|

## Getting Secret Values

<Describe how to obtain credentials: team vault, AWS Secrets Manager, Azure Key Vault, etc.
If unknown: "Contact the team lead for access to credentials.">
````

### Step 5: Summary report

After all writes and deletes are complete, print:

```
doc-refresh Results
───────────────────────────────────
Stale docs purged:    X  (filenames)
Docs created:         X  (filenames)
Docs rewritten:       X  (filenames)
Docs unchanged:       X  (filenames)

Security callouts added: X
2am-engineer persona applied: all docs ✓

Next: commit these changes, then run /pre-commit to verify.
```

---

## Mode B — Runbook only

When invoked as `/doc-refresh runbook`:

Run Step 1 and the stale check for `docs/RUNBOOK.md` only, then generate `docs/RUNBOOK.md`
using the template above. Skip all other docs.

---

## Mode C — Install as pre-commit hook

When invoked as `/doc-refresh install`:

The hook runs **before** the commit is finalised so that updated docs are included in the
same commit rather than trailing behind in a separate one.

Pattern: run doc-refresh, auto-stage any modified doc files, then let the commit proceed.

1. Use Bash to confirm `.git/` exists in the current working directory.
2. Use Write to create `.git/hooks/pre-commit` with this content:

   ```bash
   #!/usr/bin/env bash
   # doc-refresh pre-commit hook
   # Refreshes docs before each commit so docs land in the same commit as the code.
   # Skip with: SKIP_DOC_REFRESH=1 git commit ...
   set -euo pipefail

   if [ -n "${SKIP_DOC_REFRESH:-}" ]; then
     exit 0
   fi

   # Only run if staged files include source or existing doc files
   STAGED=$(git diff --cached --name-only \
     | grep -E '\.(ts|js|tsx|jsx|py|go|sh|rb|java|rs|md)$' || true)

   if [ -z "$STAGED" ]; then
     exit 0
   fi

   echo "doc-refresh: staged source files detected — refreshing documentation..."

   if ! claude -p "/doc-refresh" 2>/dev/null; then
     echo "doc-refresh: warning — claude CLI unavailable or returned an error, skipping"
     exit 0
   fi

   # Auto-stage any doc files that were written or modified by the refresh
   DOC_FILES=$(git diff --name-only -- \
     'README.md' 'CONTRIBUTING.md' 'SECURITY.md' \
     'docs/RUNBOOK.md' 'docs/ONBOARDING.md' 'docs/ENV_VARS.md' \
     'docs/assumptions.md' || true)

   if [ -n "$DOC_FILES" ]; then
     echo "doc-refresh: auto-staging updated docs:"
     echo "$DOC_FILES" | sed 's/^/  /'
     # shellcheck disable=SC2086
     git add $DOC_FILES
   fi

   exit 0
   ```

3. Use Bash: `chmod +x .git/hooks/pre-commit`
4. Confirm and remind the user:
   - The hook runs locally only — every team member must run `/doc-refresh install`.
   - To skip a single commit: `SKIP_DOC_REFRESH=1 git commit ...`
   - The hook never blocks a commit — if Claude is unavailable it warns and continues.
   - To uninstall: `/doc-refresh uninstall`

---

## Mode D — Audit only (no writes)

When invoked as `/doc-refresh check`:

Run Steps 1–3 only. Print the stale audit table and the missing-docs list.
Do NOT write or delete any files. Useful for CI to detect documentation drift.

---

## Mode E — Uninstall hook

When invoked as `/doc-refresh uninstall`:

1. Use Bash to check if `.git/hooks/pre-commit` exists.
2. Remove it with Bash.
3. Confirm removal.
