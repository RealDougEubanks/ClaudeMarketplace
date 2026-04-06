# Agent-Based Development — Async Multi-Agent Workflow

Run a full async multi-agent software development workflow using file-based artifact handoffs. Each invocation adopts a specific agent role and operates according to that role's responsibilities.

---

## Part 1 — Framework Overview

This is an async, artifact-driven workflow. Agents do not communicate in real time — they communicate via JSON files in a `handoffs/` directory. The flow is:

```
Planning → Design → Dev (Senior / Junior)
       ↓                        ↓
  Documentation ← Security + Tech Review
       ↓                        ↓
  Planning (triage) ← findings with severity
```

All agents must follow the Golden Rules (see `CLAUDE.md` or run `/golden-rules`).

---

## Part 2 — Agent Roster

| Agent | Slash Command | When to Include |
|-------|--------------|-----------------|
| Planning | `/abd-plan` | Almost always — assigns tasks, triages reviews |
| Design | `/abd-design` | When the project has a design phase; omit for simple/script-only work |
| Dev Senior | `/abd-dev-senior` | When there is higher-complexity implementation work |
| Dev Junior | `/abd-dev-junior` | For routine tasks; omit for small teams |
| Security | `/abd-security` | Recommended for all projects |
| Tech Review | `/abd-review` | Recommended for all projects |
| Documentation | `/abd-docs` | Almost always — docs, ToDo, changelogs, assumptions |
| Testing | `/abd-test` | When the project has automated tests |
| DevOps | `/abd-devops` | When the project has CI/CD or a formal release process |
| Status | `/abd-status` | At any time — shows project-wide task and finding status |

Active agents are defined in `docs/agentRoster.md`. If that file does not exist, Claude creates it at project start.

---

## Part 3 — Handoff Directory Structure

```
handoffs/
├── plans/     Written by: Planning        Read by: all agents
├── designs/   Written by: Design          Read by: Dev, Docs, Tech Review
├── dev/       Written by: Dev             Read by: Docs, Security, Tech Review
├── reviews/   Written by: Security, Tech  Read by: Planning, Docs
└── docs/      Written by: Documentation   Read by: all (reference)
```

All artifacts use this JSON envelope schema:

```json
{
  "taskId": "task-001",
  "agent": "<agent-name>",
  "status": "assigned | in-progress | complete | blocked | needs-rework",
  "timestamp": "<ISO 8601>",
  "payload": { },
  "assumptions": [{ "assumption": "", "why": "", "date": "" }]
}
```

Review artifacts (from Security and Tech Review) must include severity for each finding:
`critical | severe | moderate | low | info`

Artifact file naming: `{taskId}_{agentRole}_{unixTimestamp}.json`

---

## Part 4 — Git Workflow (Release-Branch Model)

**Branches:**
- `main`: production-ready history. Never commit directly.
- `release/<version>` (e.g. `release/1.0`): integration branch. Never commit directly.
- `feature/task-XXX-description`: one per task, created from the release branch.
- `fix/task-XXX-description`: bug fixes, created from the release branch.

**Flow:** `feature/*` or `fix/*` → PR into `release/<version>` → when release is ready, `release/<version>` → PR into `main` → tag (e.g. `v1.0.0`).

**Who does what:**

| Action | Responsible Agent |
|--------|------------------|
| Create feature/fix branch | Planning or Dev |
| Open PR | Dev (the agent that did the work) |
| Code review | Tech Review + Security |
| Approve PR | Tech Review + Security; Planning after triage |
| Merge to release branch | Planning or designated agent |
| Cut release (release → main + tag) | Planning or DevOps |
| Create changelog | Documentation |

---

## Part 5 — Agent Instructions

### Instructions for Claude: How to Use This Skill

When invoked with any `/abd-*` command, follow these steps:

**Step 1 — Determine context.**
Use Glob to check if `handoffs/` exists in the current working directory.

**Step 2 — If no `handoffs/` directory exists (project start):**

a. Ask for the project-start prompt if not already provided.

b. Adopt the Planning role.

c. Use Bash to create the full directory structure:
   ```
   mkdir -p handoffs/plans handoffs/designs handoffs/dev handoffs/reviews handoffs/docs docs shared/schemas
   ```

d. Use Write to create `docs/agentRoster.md` listing active agents. Ask the user which agents to enable, or default to: planning, dev-senior, documentation, security, tech-review.

e. Use Write to create the first plan artifact in `handoffs/plans/` using the envelope schema. Assign tasks to each active agent.

f. Use Write to create `docs/assumptions.md` with any assumptions made during planning.

**Step 3 — If `handoffs/` exists (ongoing project), determine your role:**

Read the latest artifact in `handoffs/plans/` using Read and Glob. Execute the role assigned:

- **Planning (`/abd-plan`):** Use Glob to read `handoffs/reviews/` for open findings. Triage critical/severe/moderate findings. Use Write to create or update plan artifacts in `handoffs/plans/`. Update `docs/ToDo.md`.

- **Design (`/abd-design`):** Use Read to read the current plan from `handoffs/plans/`. Produce architecture diagrams (as Mermaid or text), component breakdowns, data flow, and design decisions. Use Write to create a design artifact in `handoffs/designs/`.

- **Dev Senior (`/abd-dev-senior`) and Dev Junior (`/abd-dev-junior`):** Use Read to read plan and design artifacts. Implement the assigned work. Use Bash to create the feature branch: `git checkout -b feature/task-XXX-description`. Use Edit and Write for implementation. Use Write to create a dev artifact in `handoffs/dev/`. Use Bash to open the PR: `gh pr create` targeting the release branch.

- **Security (`/abd-security`):** Use Glob and Read to read code and `handoffs/dev/` artifacts. Audit for injection, insecure data storage, hardcoded secrets, missing input validation, least privilege violations, insecure defaults. Use Write to create a review artifact in `handoffs/reviews/` with severity-graded findings.

- **Tech Review (`/abd-review`):** Use Glob and Read to read code and `handoffs/dev/` artifacts. Review code quality, architecture, naming conventions, error handling, placeholder-free code, schema validation usage. Use Write to create a review artifact in `handoffs/reviews/` with severity-graded findings.

- **Documentation (`/abd-docs`):** Use Glob and Read to read all handoffs and the codebase. Use Edit and Write to update `README.md`, `docs/ToDo.md`, `docs/assumptions.md`. On release, use Write to create `docs/CHANGELOG.md` or `docs/changelogs/<version>.md`.

- **Testing (`/abd-test`):** Use Read to read the latest plan artifact from `handoffs/plans/` and dev artifacts from `handoffs/dev/`. Auto-detect the test framework: look for Jest or Vitest by checking `package.json`; pytest by checking `pyproject.toml` or `setup.py`; Go test by checking `go.mod`; PHPUnit by checking `composer.json`. Use Glob with patterns `**/*.test.*`, `**/*_test.*`, and `tests/**/*` to read existing tests and match their style and patterns. Write tests covering: happy path, edge cases, invalid input, error conditions, and all acceptance criteria listed in the plan artifact. Use Bash to run the test suite and fix any failures before writing the artifact. Use Write to create a test artifact at `handoffs/dev/{taskId}_testing_{unixTimestamp}.json` containing status and a test summary (framework detected, number of tests added, pass/fail counts, and any failures resolved).

- **DevOps (`/abd-devops`):** Use Read to read the latest plan artifact from `handoffs/plans/`. Use Glob to check for existing CI/CD config files: `.github/workflows/**`, `bitbucket-pipelines.yml`, `.gitlab-ci.yml`, `Dockerfile`, and `docker-compose.yml`. If no CI/CD configuration exists, use Write to scaffold a GitHub Actions workflow (`.github/workflows/ci.yml`) with jobs for lint, test, and build. Validate that all required environment variables documented in the plan have corresponding entries in `.env.example`; add any that are missing. Check Dockerfile hygiene: verify that a non-root user is set, the base image is pinned to a specific digest or version tag, and a `.dockerignore` file is present — report or fix each gap found. For release tasks, invoke the git-workflow release steps (Action d from Part 4: open a PR from the release branch into `main` and tag the release). Use Write to create a DevOps artifact at `handoffs/dev/{taskId}_devops_{unixTimestamp}.json` with status and a summary of all checks performed and changes made.

- **Planning Triage (`/abd-triage`):** Use Glob and Read to find all open findings in `handoffs/reviews/` with severity critical, severe, or moderate. Create rework assignments or mark resolved. Use Write to update `handoffs/plans/`.

- **Status (`/abd-status`):**
  1. Use Glob to find all JSON files in `handoffs/plans/`, `handoffs/dev/`, `handoffs/reviews/`, `handoffs/designs/`, `handoffs/docs/`.
  2. Use Read on each artifact. Parse the `taskId`, `agent`, `status`, and `timestamp` fields.
  3. Build a status summary:
     - All tasks grouped by status: `assigned | in-progress | complete | blocked | needs-rework`
     - Which agent owns each task
     - For `handoffs/reviews/`: count findings by severity (critical/severe/moderate/low/info) across all open reviews
     - Identify blockers: any task with status `blocked` or any finding with `critical` or `severe` severity in an open review
  4. Read `docs/agentRoster.md` if it exists to know which agents are active.
  5. Read `docs/ToDo.md` if it exists to include pending items.
  6. Output the Status Dashboard:

  ```
  ## ABD Project Status — <project> — <timestamp>

  ### Task Summary
  | Status | Count | Tasks |
  |--------|-------|-------|
  | complete | 4 | task-001 (dev-senior), task-002 (design), ... |
  | in-progress | 2 | task-003 (security), task-004 (dev-junior) |
  | blocked | 1 | task-005 (tech-review) |
  | assigned | 0 | — |

  ### Open Findings
  | Severity | Count | Source |
  |----------|-------|--------|
  | critical | 0 | — |
  | severe | 1 | task-003_security_*.json |
  | moderate | 3 | task-003_security_*.json, task-004_review_*.json |

  ### 🚨 Blockers
  - task-005: blocked — waiting on UX approval for modal design
  - task-003 finding: SQL injection in auth handler (severe) — must resolve before merge

  ### Next Actions
  - Security (task-003): 1 severe finding needs rework assignment from Planning
  - Tech Review (task-004): 3 moderate findings need triage
  - Dev Junior (task-005): unblock after UX approval

  ### Agent Roster
  [list from docs/agentRoster.md]
  ```

**Step 4 — Every artifact you write must:**
- Be valid JSON following the envelope schema.
- Include `taskId`, `agent`, `status`, `timestamp`.
- For reviews: include `severity` (critical | severe | moderate | low | info) per finding.
- Be placed in the correct `handoffs/` subdirectory.
- Use naming: `{taskId}_{agentRole}_{unixTimestamp}.json`.

**Step 5 — Record assumptions.**
Every non-obvious decision must be appended to `docs/assumptions.md`:

```
**Assumption:** <one clear sentence>
**Why:** <rationale>
**Recorded by:** <agent-name>
**Date:** <YYYY-MM-DD>
```

**Step 6 — Never commit directly to `main` or the release branch.** Always use feature/fix branches and PRs.

---

## Part 6 — MVP Readiness Gate

Before marking any task complete, the active agent verifies:

1. **Stability:** All external calls (DB, API, file system) have error handling. No crashes on invalid input. Idempotent where applicable.
2. **Configuration:** App validates required env vars on startup. No hardcoded magic strings, URLs, or ports. No secrets in repo.
3. **Logging:** Logs include timestamps and severity (INFO, WARN, ERROR). No silent failures.
4. **Security (Golden Rules):** All user input validated/sanitized. Least privilege. Secure defaults.
5. **Documentation:** README explains clone-to-run in fewer than 3 steps. Usage examples exist.
6. **Implementation Integrity:** No placeholder code. camelCase naming. Complete README with stack, license, troubleshooting.

---

## Part 7 — Project-Start Prompt Examples

**Simple:**
> "Create a BASH backup script. Copy source → destination, optional compression, retention copies. Cron-friendly."

**Detailed:**
> "Create a minimal static blog. Home = post list (title, date, excerpt); post detail = full content. Content as Markdown or JSON. Responsive, light/dark toggle, accessible colors. Static HTML/JS. No backend for v1. Document stack and assumptions in docs/assumptions.md."

When given a project-start prompt, Planning must:
- Identify the stack and document it in `docs/assumptions.md`.
- Determine which agents are needed and write `docs/agentRoster.md`.
- Create the first plan artifact in `handoffs/plans/` with assignments for each active agent.
- Adapt granularity to complexity: a single plan for simple projects; per-agent/per-task plans for complex ones.

---

## Output Format

After executing your role, report:

1. Which agent role was adopted.
2. What artifacts were read (list files).
3. What artifacts were written (list files with paths).
4. A concise summary of work done or findings.
5. What the next agent(s) should do (next handoff).
