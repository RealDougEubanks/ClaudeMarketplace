# Claude Code Skills Marketplace

A community-driven collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's CLI tool for software engineering with Claude.

## What are Skills?

Skills are reusable prompt templates that extend Claude Code's capabilities. They package expert instructions into shareable, versioned modules that anyone can install and invoke with a slash command.

Examples of what skills can do:

- Enforce project-specific code review checklists
- Generate boilerplate tailored to your stack
- Run multi-step workflows (plan, develop, review, release)
- Automate documentation and changelog generation
- Perform security, accessibility, and architecture audits

## Quick Start

### Install via Claude Plugin System

```bash
claude plugin add github:RealDougEubanks/ClaudeMarketplace
```

This installs all 22 skills at once. Each skill becomes available as a slash command in any Claude Code session.

### Install a Single Skill Manually

```bash
git clone git@github.com:RealDougEubanks/ClaudeMarketplace.git
cd ClaudeMarketplace

# Install into your project
./scripts/install.sh skills/golden-rules /path/to/your/project

# Or install into the current directory
./scripts/install.sh skills/security-review
```

The script copies `skill.md` → `.claude/commands/<skill-name>.md`. For `base` skills it also appends to `CLAUDE.md`, making them always-on context.

---

## Available Skills

### Base — always-on context

| Skill | Command | Description |
|-------|---------|-------------|
| [golden-rules](skills/golden-rules/) | `/golden-rules` | Installs mandatory security, coding, naming, and design standards into `CLAUDE.md` |

### Workflow

| Skill | Command | Description |
|-------|---------|-------------|
| [agent-based-development](skills/agent-based-development/) | `/abd`, `/abd-plan`, `/abd-dev`, `/abd-security`, `/abd-test`, `/abd-devops`, `/abd-status` | Full async multi-agent dev workflow: Planning → Design → Dev → Security/Tech Review with file-based handoffs |
| [git-workflow](skills/git-workflow/) | `/git-workflow` | Release-branch Git model: branch creation, PR gate, release tagging, conflict resolution, stash management |
| [changelog-generator](skills/changelog-generator/) | `/changelog-generator` | Generates CHANGELOG.md from git history following Keep a Changelog format |
| [requirements-generator](skills/requirements-generator/) | `/requirements-generator` | Generates structured requirements with functional/non-functional reqs, Gherkin AC, and edge cases |
| [log-correlation](skills/log-correlation/) | `/log-correlation` | Correlates and troubleshoots logs across OS, AWS, application, and web server sources |
| [incident-report](skills/incident-report/) | `/incident-report` | Generates professional incident reports with SEV classification; extensible via templates and rules |
| [architecture-design](skills/architecture-design/) | `/architecture-design` | Designs new systems: C4 diagrams, service boundaries, API contracts, data design, and failure modes |
| [adr](skills/adr/) | `/adr` | Creates and maintains Architecture Decision Records in MADR format |
| [api-design](skills/api-design/) | `/api-design` | Designs REST/GraphQL/gRPC APIs (OpenAPI/schema/proto) and reviews existing APIs for breaking changes |
| [database-design](skills/database-design/) | `/database-design` | Designs schemas (ERD, indexes, migrations) and reviews existing schemas for normalization and safety |

### Standards

| Skill | Command | Description |
|-------|---------|-------------|
| [mvp-readiness](skills/mvp-readiness/) | `/mvp-readiness` | Structured MVP quality-gate audit covering stability, security, logging, docs, and implementation integrity |
| [code-review](skills/code-review/) | `/code-review` | Engineering code review: readability, complexity, test gaps, SOLID principles, and API consistency |
| [test-writer](skills/test-writer/) | `/test-writer` | Auto-detects test framework and generates comprehensive unit and integration tests |
| [pre-commit](skills/pre-commit/) | `/pre-commit` | Pre-commit quality gate: secrets, dead code, naming, conflict markers, branch protection; installs as git hook |
| [best-practices](skills/best-practices/) | `/best-practices` | Holistic codebase audit producing a P1–P4 prioritized improvement roadmap with effort estimates |
| [architecture-review](skills/architecture-review/) | `/architecture-review` | Audits existing architecture for anti-patterns, scalability risks, and testability gaps |
| [accessibility](skills/accessibility/) | `/accessibility` | WCAG 2.2 AA audit (review mode) and accessible component design guidance (design mode) |

### Security

| Skill | Command | Description |
|-------|---------|-------------|
| [security-review](skills/security-review/) | `/security-review` | Comprehensive security audit: injection, auth, secrets, cryptography, CI/CD, and OWASP Top 10 mapping |
| [dependency-audit](skills/dependency-audit/) | `/dependency-audit` | Audits dependencies for unpinned versions, deprecated packages, missing lockfiles, and known CVEs |

### Productivity

| Skill | Command | Description |
|-------|---------|-------------|
| [onboarding](skills/onboarding/) | `/onboarding` | Generates a developer onboarding guide with directory map, entry points, env vars, and architecture diagram |

> `example-skill` is a contributor reference — it demonstrates the expected file structure but is not a functional skill.

---

## Repository Structure

```
ClaudeMarketplace/
├── .claude-plugin/
│   └── marketplace.json        # Plugin manifest for claude plugin add
├── skills/                     # All published skills
│   ├── registry.json           # Index of all available skills
│   └── <skill-name>/           # One directory per skill
│       ├── skill.md            # The prompt Claude executes
│       ├── metadata.json       # Name, version, author, tags, etc.
│       ├── README.md           # Human-readable documentation
│       ├── .claude-plugin/
│       │   └── plugin.json     # Per-skill plugin manifest
│       └── .scan-exempt        # (optional) prompt safety scan exemptions
├── templates/                  # Starter templates for new skills
├── schema/
│   └── metadata.schema.json    # JSON Schema for metadata validation
├── scripts/
│   ├── new-skill.sh            # Scaffold a new skill from templates
│   ├── validate.sh             # Validate a skill's structure and schema
│   ├── install.sh              # Install a skill into a project
│   ├── check-registry.sh       # Verify registry.json matches metadata.json
│   └── scan-prompts.sh         # Safety scan skill prompts for sensitive patterns
├── CONTRIBUTING.md
└── LICENSE
```

---

## How Base Skills Work

Skills with `"category": "base"` (like `golden-rules`) do two things when installed:

1. Copy `skill.md` to `.claude/commands/<skill-name>.md` — invokable as a slash command.
2. **Append the skill content to `CLAUDE.md`** in your project root.

Because Claude Code loads `CLAUDE.md` automatically at the start of every session, base skills become **always-on context** — no invocation required.

---

## Create Your Own Skill

```bash
# Scaffold from templates
./scripts/new-skill.sh my-new-skill

# Edit the three required files
# - skills/my-new-skill/skill.md       → instructions Claude follows literally
# - skills/my-new-skill/metadata.json  → name, version, category, tags, tools
# - skills/my-new-skill/README.md      → human-readable docs

# Validate structure and schema
./scripts/validate.sh skills/my-new-skill

# Check registry consistency
./scripts/check-registry.sh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full submission guide.

---

## Skill Anatomy

Every skill has three required files:

| File | Purpose |
|------|---------|
| `skill.md` | The prompt — step-by-step instructions Claude will follow |
| `metadata.json` | Machine-readable metadata (name, version, tags, tools) |
| `README.md` | Human-readable docs (usage, examples, installation notes) |

### metadata.json example

```json
{
  "name": "my-skill",
  "version": "1.0.0",
  "description": "What the skill does in one sentence (max 200 chars)",
  "author": {
    "name": "Your Name",
    "github": "your-username"
  },
  "license": "MIT",
  "category": "workflow",
  "tags": ["example"],
  "commands": ["/my-skill"],
  "tools": ["Bash", "Read", "Write"]
}
```

See [`schema/metadata.schema.json`](schema/metadata.schema.json) for the full validation schema.

---

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a pull request.

**TL;DR:**

1. Run `./scripts/new-skill.sh your-skill-name` to scaffold
2. Write `skill.md`, `metadata.json`, and `README.md`
3. Validate with `./scripts/validate.sh skills/your-skill-name`
4. Add to `skills/registry.json` and run `./scripts/check-registry.sh`
5. Open a PR

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
