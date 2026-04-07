# Claude Code Skills Marketplace

A community-driven collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's CLI tool for software engineering with Claude.

## What are Skills?

Skills are reusable prompt templates that extend Claude Code's capabilities. They let you package expert instructions into shareable, versioned modules that anyone can install and invoke with a slash command.

Examples of what skills can do:

- Enforce project-specific code review checklists
- Generate boilerplate tailored to your stack
- Run multi-step workflows (test, lint, commit, deploy)
- Automate documentation generation
- Perform security audits with custom rulesets

## Repository Structure

```
ClaudeMarketplace/
├── skills/                         # Published skills
│   ├── registry.json               # Index of all available skills
│   └── example-skill/              # One directory per skill
│       ├── commands/
│       │   └── example-skill.md    # Skill prompt with YAML frontmatter
│       ├── .claude-plugin/
│       │   └── plugin.json         # Claude Code plugin manifest
│       ├── metadata.json           # Name, version, author, tags, etc.
│       └── README.md               # Human-readable documentation
├── templates/                      # Starter templates for new skills
│   ├── skill.md
│   └── metadata.json
├── schema/
│   └── metadata.schema.json        # JSON Schema for metadata validation
├── scripts/
│   ├── validate.sh                 # Validate a skill's structure
│   ├── install.sh                  # Install a skill locally
│   ├── new-skill.sh                # Scaffold a new skill from templates
│   ├── check-registry.sh           # Verify registry.json consistency
│   ├── validate-all.sh             # Run all validation checks
│   └── scan-prompts.sh             # Prompt safety scanner
├── CONTRIBUTING.md                 # How to submit a skill
└── LICENSE                         # MIT
```

## Available Skills

> The `example-skill` is a contributor reference — it demonstrates the expected file structure but is not a functional skill.

### Base (always-on context)

| Skill | Command | Description |
|-------|---------|-------------|
| [golden-rules](skills/golden-rules/) | `/golden-rules` | Installs mandatory security, coding, naming, and design standards into `CLAUDE.md` as always-on context for every Claude Code session |

### Workflow

| Skill | Command | Description |
|-------|---------|-------------|
| [agent-based-development](skills/agent-based-development/) | `/agent-based-development` | Full async multi-agent development workflow: Planning → Design → Dev → Security/Tech Review loop with file-based handoffs and release-branch Git model |
| [git-workflow](skills/git-workflow/) | `/git-workflow` | Enforces the release-branch Git model: scaffold feature branches, open PRs with review checks, cut releases with tags, and view workflow reference |
| [adr](skills/adr/) | `/adr` | Creates and maintains Architecture Decision Records (ADRs) in docs/decisions/ using the MADR format. Supports creating, listing, updating, superseding, and searching ADRs |
| [api-design](skills/api-design/) | `/api-design` | Designs REST, GraphQL, and gRPC APIs (OpenAPI/schema/proto output) and reviews existing APIs for consistency, best practices, and breaking change risks |
| [architecture-design](skills/architecture-design/) | `/architecture-design` | Designs new systems from requirements: C4 model diagrams, service boundaries, API contracts, data design, failure modes, and cross-cutting concerns |
| [changelog-generator](skills/changelog-generator/) | `/changelog-generator` | Generates a structured CHANGELOG.md following Keep a Changelog format from git history and ABD handoff artifacts |
| [database-design](skills/database-design/) | `/database-design` | Designs database schemas from domain requirements (ERD, indexes, migrations, security) or reviews existing schemas for normalization issues, missing indexes, unsafe migrations, and scalability risks |
| [incident-report](skills/incident-report/) | `/incident-report` | Generates professional incident reports using customizable templates. Supports outage, security, performance, and data-loss incident types |
| [requirements-generator](skills/requirements-generator/) | `/requirements-generator` | Generates structured requirements documents with functional and non-functional requirements, Gherkin acceptance criteria, edge cases, and out-of-scope items |

### Standards

| Skill | Command | Description |
|-------|---------|-------------|
| [accessibility](skills/accessibility/) | `/accessibility` | Audits code for WCAG 2.2 AA compliance and provides design guidance for accessible components. Covers semantic HTML, ARIA, keyboard nav, contrast, focus management, and motion |
| [architecture-review](skills/architecture-review/) | `/architecture-review` | Audits existing architecture for anti-patterns, scalability and reliability risks, and testability gaps. Graded findings with migration paths and a to-be diagram |
| [best-practices](skills/best-practices/) | `/best-practices` | Holistic codebase audit that auto-detects the stack and produces a prioritized improvement roadmap with level-of-effort estimates |
| [code-review](skills/code-review/) | `/code-review` | Structured engineering code review covering readability, complexity, test gaps, SOLID principles, and API consistency |
| [mvp-readiness](skills/mvp-readiness/) | `/mvp-readiness` | Runs a structured MVP quality-gate audit covering stability, security, logging, docs, and implementation integrity. Reports pass/fail with evidence |
| [pre-commit](skills/pre-commit/) | `/pre-commit` | Fast pre-commit quality gate: scans staged files for secrets, dead code, naming issues, merge conflict markers, and direct-to-main commits. Installs as a git hook via `/pre-commit install` |
| [test-writer](skills/test-writer/) | `/test-writer` | Generates comprehensive unit and integration tests for a given file or function, auto-detecting the project test framework and matching existing test style |

### Security

| Skill | Command | Description |
|-------|---------|-------------|
| [dependency-audit](skills/dependency-audit/) | `/dependency-audit` | Audits project dependencies across package.json, requirements.txt, go.mod, and Gemfile for unpinned versions, deprecated packages, missing lockfiles, and known CVEs |
| [security-review](skills/security-review/) | `/security-review` | Structured security audit covering injection, auth, secrets, input validation, dependencies, and cryptography. Produces severity-graded findings |

### Productivity

| Skill | Command | Description |
|-------|---------|-------------|
| [log-correlation](skills/log-correlation/) | `/log-correlation` | Correlates and troubleshoots logs across OS (Linux/macOS), AWS (CloudWatch, CloudTrail, ALB, Lambda), application (JSON, logfmt), and web servers (Nginx, Apache) |
| [onboarding](skills/onboarding/) | `/onboarding` | Generates a comprehensive developer onboarding guide (ONBOARDING.md) by reading the codebase: directory map, entry points, environment variables, key commands, and architecture overview |

---

## How Base Skills Work

Skills with `"category": "base"` (like `golden-rules`) do two things when installed:

1. Copy `skill.md` to `.claude/commands/<skill-name>.md` so you can invoke it with a slash command.
2. **Also append the skill content to `CLAUDE.md`** in your project root.

Because Claude Code loads `CLAUDE.md` automatically at the start of every session, base skills become **always-on context** — no invocation required.

---

## Quick Start

### Browse Skills

Look through the [`skills/`](skills/) directory or check [`skills/registry.json`](skills/registry.json) for a full index.

### Install a Skill

```bash
# Clone the marketplace
git clone https://github.com/realdougeubanks/claudemarketplace.git
cd claudemarketplace

# Install a skill into your project's .claude/commands/ directory
./scripts/install.sh skills/golden-rules /path/to/your/project

# Or install to the current directory
./scripts/install.sh skills/mvp-readiness
```

The script copies `skill.md` → `.claude/commands/<skill-name>.md` and `metadata.json` → `.claude/commands/<skill-name>.metadata.json`. For `base` skills, it also appends to `CLAUDE.md`.

### Create Your Own Skill

```bash
# Scaffold from templates
./scripts/new-skill.sh my-new-skill

# Edit the three files
# - skills/my-new-skill/skill.md       → instructions Claude follows literally
# - skills/my-new-skill/metadata.json  → name, version, category, tags, tools
# - skills/my-new-skill/README.md      → human-readable docs

# Validate structure
./scripts/validate.sh skills/my-new-skill

# Check registry consistency
./scripts/check-registry.sh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full submission guide.

## Skill Anatomy

Every skill has three files:

| File                          | Purpose                                                    |
|-------------------------------|------------------------------------------------------------|
| `commands/<name>.md`          | The prompt with YAML frontmatter — what Claude executes    |
| `metadata.json`               | Machine-readable metadata (name, version, tags, tools)     |
| `.claude-plugin/plugin.json`  | Claude Code plugin manifest for discovery                  |
| `README.md`                   | Human-readable docs (usage, examples, installation notes)  |

### metadata.json

```json
{
  "name": "my-skill",
  "version": "1.0.0",
  "description": "What the skill does in one sentence",
  "author": {
    "name": "Your Name",
    "github": "your-username"
  },
  "license": "MIT",
  "tags": ["category"],
  "commands": ["/my-skill"],
  "tools": ["Bash", "Read"]
}
```

See [`schema/metadata.schema.json`](schema/metadata.schema.json) for the full validation schema.

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a pull request.

**TL;DR:**
1. Copy the template into `skills/your-skill-name/`
2. Write your `skill.md`, `metadata.json`, and `README.md`
3. Validate with `./scripts/validate.sh`
4. Add to `skills/registry.json`
5. Open a PR

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
