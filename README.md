# Claude Code Skills Marketplace

A community-driven collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's CLI tool that lets you work with Claude directly in your terminal and editor.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Git with SSH configured (for the marketplace source URL), or use the HTTPS URL below
- No other dependencies required

## What are Skills?

Skills are reusable prompt templates that extend Claude Code's capabilities. They let you package expert instructions into shareable, versioned modules that anyone can invoke with a slash command.

> **Skills vs Plugins:** Internally, Claude Code calls these "plugins" — you'll see `enabledPlugins` in `settings.json` and `.claude-plugin/` directories in the repo. Skills are plugins implemented purely as prompt instructions, with no MCP server or external API required.

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
│   ├── skill.md                    # Used by new-skill.sh to scaffold commands/<name>.md
│   └── metadata.json
├── schema/
│   └── metadata.schema.json        # JSON Schema for metadata validation
├── scripts/
│   ├── validate.sh                 # Validate a skill's structure
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
| [doc-refresh](skills/doc-refresh/) | `/doc-refresh` | Complete documentation refresh — audits stale docs, creates missing docs, rewrites for a 2am on-call engineer with zero assumed context. Installs as a pre-commit hook via `/doc-refresh install` |
| [log-correlation](skills/log-correlation/) | `/log-correlation` | Correlates and troubleshoots logs across OS (Linux/macOS), AWS (CloudWatch, CloudTrail, ALB, Lambda), application (JSON, logfmt), and web servers (Nginx, Apache) |
| [onboarding](skills/onboarding/) | `/onboarding` | Generates a comprehensive developer onboarding guide (ONBOARDING.md) by reading the codebase: directory map, entry points, environment variables, key commands, and architecture overview |

---

## Git Hooks

Two skills can install themselves as git hooks so they run automatically on every commit
without you having to invoke them manually.

| Skill | Hook type | Hook file | What it does automatically |
|-------|-----------|-----------|----------------------------|
| [pre-commit](skills/pre-commit/) | pre-commit | `.git/hooks/pre-commit` | Scans staged files for secrets, dead code, naming issues, conflict markers, and direct-to-main commits. Blocks the commit if a BLOCKER is found. |
| [doc-refresh](skills/doc-refresh/) | pre-commit | `.git/hooks/pre-commit` | Refreshes all project documentation before the commit finalises and auto-stages any updated doc files so they land in the same commit as the code. |

> **Note:** Both hooks use `.git/hooks/pre-commit`. If you want both to run, install
> `pre-commit` first, then manually merge the two scripts, or run `/doc-refresh install`
> which will warn you if a hook already exists.

### Installing a hook

```
/pre-commit install
```

```
/doc-refresh install
```

Each command writes a shell script to `.git/hooks/` and makes it executable. The hook
runs automatically on every `git commit` from that point on. Both hooks fail gracefully —
if Claude Code is unavailable the commit proceeds with a warning rather than being blocked.

### Skipping a hook for one commit

Both hooks respect an environment variable escape hatch:

| Skill | Skip variable |
|-------|--------------|
| `pre-commit` | `git commit --no-verify` |
| `doc-refresh` | `SKIP_DOC_REFRESH=1 git commit ...` |

Use `--no-verify` sparingly — it bypasses all hooks including the secret scanner.
Prefer the skill-specific skip variable when you only need to skip one hook.

### Uninstalling a hook

```
/pre-commit uninstall
```

```
/doc-refresh uninstall
```

### Hook scope

Git hooks are stored in `.git/hooks/`, which is not committed to the repository.
Each team member must run the install command in their own local clone.
To automate this for the whole team, add the install command to your project's
setup or bootstrap script.

---

## How Base Skills Work

Skills with `"category": "base"` (like `golden-rules`) do two things when enabled via the marketplace:

1. Register as a slash command (e.g. `/golden-rules`) so you can invoke it on demand.
2. **When invoked, append the skill content to `CLAUDE.md`** in your project root.

Because Claude Code loads `CLAUDE.md` automatically at the start of every session, base skills become **always-on context** — no invocation required after the first run.

---

## Why Marketplace Format?

Skills in this repo are distributed as a Claude Code marketplace rather than as individually installed files. This was a deliberate design decision:

**Skills stay automatically up to date.** With `"autoUpdate": true`, Claude Code syncs with this repo whenever it pulls updates. Any improvement to a skill — better instructions, new capabilities, bug fixes — is available immediately without any action from the user. There is no "reinstall" step.

**Skills are passive — there is no overhead to having them enabled.** A skill is just a slash command. It does nothing until you invoke it. Having 22 skills enabled globally costs nothing at runtime: no background processes, no memory usage, no effect on Claude's behavior unless you type the command. The only practical consideration is 22 extra entries in the slash command autocomplete list.

**You control which skills are enabled.** You can enable all of them globally, a curated subset, or configure different skills per project. See [Selective Installation](#selective-installation) below.

---

## Quick Start

### Browse Skills

Look through the [`skills/`](skills/) directory or check [`skills/registry.json`](skills/registry.json) for a full index.

### Install via Claude Code Marketplace

Skills are distributed through the Claude Code marketplace system. Add this marketplace to your `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "claude-skills-marketplace": {
      "source": {
        "source": "git",
        "url": "git@github.com:RealDougEubanks/ClaudeMarketplace.git"
      },
      "autoUpdate": true
    }
  }
}
```

> **No SSH?** Use the HTTPS URL instead: `"url": "https://github.com/RealDougEubanks/ClaudeMarketplace.git"`

Then enable the skills you want under `enabledPlugins`. You can enable all of them, or just the ones relevant to your work:

```json
{
  "enabledPlugins": {
    "golden-rules@claude-skills-marketplace": true,
    "code-review@claude-skills-marketplace": true,
    "security-review@claude-skills-marketplace": true
  }
}
```

Once enabled, skills are available as slash commands in any Claude Code session:

```
/code-review          ← runs a structured code review on the current file or selection
/security-review      ← audits the codebase for security issues
/test-writer          ← generates tests for a given file or function
```

### Selective Installation

You don't have to enable everything. There are three common patterns:

**Enable all skills globally** — add every skill to `~/.claude/settings.json`. All slash commands are available in every project, always up to date.

**Enable a curated global set** — enable only the skills you use regularly (e.g. `golden-rules`, `code-review`, `security-review`) in `~/.claude/settings.json`, and skip the rest.

**Per-project overrides** — add an `enabledPlugins` block to a project's `.claude/settings.json` to enable skills only for that project. Project settings layer on top of your global config.

```json
// .claude/settings.json in a specific project
{
  "enabledPlugins": {
    "accessibility@claude-skills-marketplace": true,
    "database-design@claude-skills-marketplace": true
  }
}
```

### Create Your Own Skill

```bash
# Scaffold from templates
./scripts/new-skill.sh my-new-skill

# Edit the generated files:
# - skills/my-new-skill/commands/my-new-skill.md  → instructions Claude follows
# - skills/my-new-skill/metadata.json             → name, version, category, tags, tools
# - skills/my-new-skill/README.md                 → human-readable docs

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
1. Run `./scripts/new-skill.sh your-skill-name` to scaffold
2. Write your `commands/your-skill-name.md`, `metadata.json`, and `README.md`
3. Validate with `./scripts/validate.sh skills/your-skill-name`
4. Add to `skills/registry.json`
5. Open a PR

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
