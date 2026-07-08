# agent-based-development

A full async multi-agent software development workflow for Claude Code. When invoked, Claude adopts a specific agent role and coordinates work with other agents via file-based JSON handoffs.

## What It Does

This skill implements a structured, role-based development process:

```
Planning → Design → Dev (Senior / Junior)
     ↓                        ↓
Documentation ← Security + Tech Review
     ↓                        ↓
Planning (triage) ← findings with severity
```

All coordination is file-based — agents write JSON artifacts to a `handoffs/` directory, and downstream agents read those artifacts. No separate queue or database required.

## Slash Commands

| Command | Agent Role | When to Use |
|---------|-----------|-------------|
| `/abd-plan` | Planning | Start a project; assign tasks; triage review findings |
| `/abd-design` | Design | Produce architecture and design artifacts |
| `/abd-dev-senior` | Dev Senior | Implement higher-complexity features |
| `/abd-dev-junior` | Dev Junior | Implement routine/lower-complexity tasks |
| `/abd-security` | Security | Audit code for vulnerabilities; write severity findings |
| `/abd-review` | Tech Review | Review code quality and architecture |
| `/abd-docs` | Documentation | Update README, ToDo, assumptions, changelogs |
| `/abd-triage` | Planning (Triage) | Process open critical/severe/moderate findings |
| `/abd-test` | Testing | Write and run tests for completed dev work |
| `/abd-devops` | DevOps | Scaffold/verify CI/CD, env vars, Docker hygiene, releases |
| `/abd-status` | Status | Show project-wide task and finding status dashboard |

You can also invoke `/agent-based-development` to be prompted for a role.

Each role is a separate skill in this plugin. Commands are namespaced by the plugin (e.g. `/agent-based-development:abd-plan`); where your Claude Code resolves unambiguous bare names, the short forms shown above also work.

## Plugin Structure

```
agent-based-development/
├── skills/
│   ├── agent-based-development/SKILL.md   Orchestrator — role dispatch and overview
│   ├── abd-plan/SKILL.md                  One skill per agent role
│   ├── abd-design/SKILL.md
│   ├── ... (dev-senior, dev-junior, security, review, docs, triage, test, devops, status)
└── shared/
    ├── envelope.md        Handoff schema, artifact rules, injection guard, output format
    ├── git-rules.md       Release-branch Git model
    ├── mvp-gate.md        Completion checks
    └── project-start.md   Bootstrap procedure and prompt examples
```

Role skills load the shared references on demand, so each invocation carries only its own role's instructions plus the shared rules it links.

## Directory Structure Created

When you run `/abd-plan` on a new project, Claude creates:

```
handoffs/
├── plans/     Task definitions and agent assignments
├── designs/   Architecture diagrams and design decisions
├── dev/       Implementation notes and branch references
├── reviews/   Security and tech-review findings with severity
└── docs/      Documentation outputs
docs/
├── agentRoster.md     Which agents are active on this project
├── assumptions.md     Non-obvious decisions with rationale
└── ToDo.md            Current task list
```

## Handoff Artifact Schema

Every artifact follows this envelope:

```json
{
  "taskId": "task-001",
  "agent": "planning",
  "status": "assigned",
  "timestamp": "2026-01-15T10:30:00Z",
  "payload": { },
  "assumptions": []
}
```

Review artifacts (from Security and Tech Review) include severity per finding:
`critical | severe | moderate | low | info`

Findings with `critical`, `severe`, or `moderate` severity block the PR and return to Planning for triage.

## Git Workflow

This skill enforces the **release-branch model**:

- `main`: production only. Never commit directly.
- `release/<version>`: integration branch. Never commit directly.
- `feature/task-XXX-description`: one branch per task, from the release branch.
- `fix/task-XXX-description`: bug fixes, from the release branch.

## Getting Started

### New project

```
/abd-plan
```

Claude will ask for your project-start prompt, then bootstrap the full `handoffs/` structure and first plan artifact.

### Project-start prompt examples

**Simple script:**
> "Create a BASH backup script. Source → destination, optional compression, N retention copies. Cron-friendly."

**Web app:**
> "Minimal static blog: post list (title, date, excerpt) and post detail page. Markdown content. Responsive, light/dark toggle, WCAG AA accessible. Static HTML/JS only — no backend for v1."

### Existing project

If `handoffs/` already exists, invoke the command for your assigned role:

```
/abd-security
```

Claude reads the latest plan and your assignment, then executes your role.

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "agent-based-development@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/agent-based-development` in any Claude Code session.
## Related Skills

- `/golden-rules` — install always-on coding and security standards
- `/mvp-readiness` — run the MVP quality-gate checklist before declaring done
- `/full-security-review` — standalone security audit (no ABD workflow required)
- `/git-workflow` — git release-branch reference and branch scaffolding
