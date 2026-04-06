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
├── skills/                     # Published skills
│   ├── registry.json           # Index of all available skills
│   └── example-skill/          # One directory per skill
│       ├── skill.md            # The skill prompt (what Claude executes)
│       ├── metadata.json       # Name, version, author, tags, etc.
│       └── README.md           # Human-readable documentation
├── templates/                  # Starter templates for new skills
│   ├── skill.md
│   └── metadata.json
├── schema/
│   └── metadata.schema.json    # JSON Schema for metadata validation
├── scripts/
│   ├── validate.sh             # Validate a skill's structure
│   └── install.sh              # Install a skill locally
├── CONTRIBUTING.md             # How to submit a skill
└── LICENSE                     # MIT
```

## Available Skills

### Base (always-on context)

| Skill | Command | Description |
|-------|---------|-------------|
| [golden-rules](skills/golden-rules/) | `/golden-rules` | Installs mandatory security, coding, and design standards into `CLAUDE.md` |

### Workflow

| Skill | Command | Description |
|-------|---------|-------------|
| [agent-based-development](skills/agent-based-development/) | `/abd`, `/abd-plan`, `/abd-security`, … | Full async multi-agent dev workflow with file-based handoffs |
| [git-workflow](skills/git-workflow/) | `/git-workflow` | Release-branch Git model: branch creation, PR gate, release tagging |

### Standards

| Skill | Command | Description |
|-------|---------|-------------|
| [mvp-readiness](skills/mvp-readiness/) | `/mvp-readiness` | 18-point MVP quality-gate audit with pass/fail report |

### Security

| Skill | Command | Description |
|-------|---------|-------------|
| [security-review](skills/security-review/) | `/security-review` | OWASP-aligned security audit with severity-graded findings |

> The `example-skill` is a contributor reference — it demonstrates the expected file structure but is not a functional skill.

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

| File              | Purpose                                                    |
|-------------------|------------------------------------------------------------|
| `skill.md`        | The prompt — step-by-step instructions Claude will follow  |
| `metadata.json`   | Machine-readable metadata (name, version, tags, tools)     |
| `README.md`       | Human-readable docs (usage, examples, installation notes)  |

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
