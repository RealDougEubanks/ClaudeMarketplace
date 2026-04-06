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

## Quick Start

### Browse Skills

Look through the [`skills/`](skills/) directory or check [`skills/registry.json`](skills/registry.json) for a list of all available skills.

### Install a Skill

```bash
# Clone the marketplace
git clone https://github.com/realdougeubanks/claudemarketplace.git
cd claudemarketplace

# Install a skill to your local Claude Code config
./scripts/install.sh skills/example-skill
```

### Create Your Own Skill

```bash
# Start from the template
cp -r templates/ skills/my-new-skill

# Edit the files
# - skill.md       → instructions for Claude
# - metadata.json  → metadata and tags
# - README.md      → documentation for users (create this)

# Validate your skill
./scripts/validate.sh skills/my-new-skill
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
