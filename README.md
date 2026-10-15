<!--
doc: readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# Claude Code Skills Marketplace (_ClaudeMarketplace_)

Reusable Claude Code skills for code review, security, architecture, and documentation work.

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Repository structure](#repository-structure)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## Background

This repository is a marketplace of skills for [Claude Code](https://code.claude.com/docs),
the Anthropic agentic coding tool. Each skill is a slash command. It gives Claude a tested
set of instructions for one job, for example a security audit.

### What a skill is

A skill is a set of instructions in a `SKILL.md` file, with optional templates and rules.
You start a skill with its slash command, for example `/code-review`. A skill does nothing
until you start it.

Claude Code calls a package of skills a **plugin**. That is why `settings.json` has an
`enabledPlugins` key and each skill directory has a `.claude-plugin/` directory. The skills
in this marketplace are plugins that contain only instructions. They do not start a server
and do not call an external API.

## Install

### Requirements

- Claude Code, installed and signed in.
- Git. The marketplace URL uses SSH. If you do not use SSH, use the HTTPS URL in
  [Add the marketplace](#add-the-marketplace).

### Add the marketplace

1. Add the marketplace to `~/.claude/settings.json`:

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

   If you do not use SSH, set `"url"` to `"https://github.com/RealDougEubanks/ClaudeMarketplace.git"`.

2. Enable the skills that you want in the same file:

   ```json
   {
     "enabledPlugins": {
       "golden-rules@claude-skills-marketplace": true,
       "code-review@claude-skills-marketplace": true,
       "full-security-review@claude-skills-marketplace": true
     }
   }
   ```

3. Start a new Claude Code session. Type `/` to see the slash commands.

With `"autoUpdate": true`, Claude Code gets skill updates from this repository
automatically. You do not install a skill again after it changes.

#### Choose where skills are enabled

| Method | Where | Result |
|---|---|---|
| All skills, all projects | `~/.claude/settings.json` | All slash commands are available everywhere. |
| Some skills, all projects | `~/.claude/settings.json` | Only the skills that you list are available. |
| Some skills, one project | `.claude/settings.json` in the project | The project list adds to your global list. |

An enabled skill has no runtime cost. It adds one entry to the slash-command list, and it
does nothing until you start it.

## Usage

Start a skill with its slash command, for example `/full-security-review`.

### Available skills

`example-skill` is a reference for contributors. It is not a working skill.

#### Base (always-on context)

| Skill | Slash command | What it does |
|---|---|---|
| [golden-rules](skills/golden-rules/) | `/golden-rules` | Writes security, coding, testing, error-handling, and API standards into your project's `CLAUDE.md`. |

#### Workflow

| Skill | Slash command | What it does |
|---|---|---|
| [agent-based-development](skills/agent-based-development/) | `/agent-based-development` and 11 `/abd-*` commands | Runs a multi-agent workflow: plan, design, develop, then security and technical review, with file-based handoffs. |
| [git-workflow](skills/git-workflow/) | `/git-workflow` | Makes feature branches, opens pull requests, and tags releases in the release-branch model. |
| [adr](skills/adr/) | `/adr` | Creates and updates Architecture Decision Records in MADR 4.0 format. |
| [api-design](skills/api-design/) | `/api-design` | Designs REST, GraphQL, and gRPC APIs, and reviews existing APIs. Writes OpenAPI 3.2 by default. |
| [architecture-design](skills/architecture-design/) | `/architecture-design` | Designs a new system from requirements, with C4 diagrams and failure modes. |
| [changelog-generator](skills/changelog-generator/) | `/changelog-generator` | Writes `CHANGELOG.md` entries in Keep a Changelog 1.1.0 format from the git history. |
| [database-design](skills/database-design/) | `/database-design` | Designs a database schema, or reviews an existing schema and its migrations. |
| [incident-report](skills/incident-report/) | `/incident-report` | Writes an incident report from a template: outage, security, performance, or data loss. |
| [requirements-generator](skills/requirements-generator/) | `/requirements-generator` | Writes requirements with Gherkin acceptance criteria, edge cases, and items out of scope. |

#### Standards

| Skill | Slash command | What it does |
|---|---|---|
| [accessibility](skills/accessibility/) | `/accessibility` | Audits code against WCAG 2.2 AA, and gives design guidance for accessible components. |
| [architecture-review](skills/architecture-review/) | `/architecture-review` | Audits an existing architecture for anti-patterns and for scale and reliability risks. |
| [best-practices](skills/best-practices/) | `/best-practices` | Audits the whole codebase and gives a list of improvements in order of priority. |
| [code-review](skills/code-review/) | `/code-review:code-review` | Reviews code for readability, complexity, test gaps, and API consistency. |
| [mvp-readiness](skills/mvp-readiness/) | `/mvp-readiness` | Audits a project against an MVP quality gate and reports pass or fail with evidence. |
| [pre-commit](skills/pre-commit/) | `/pre-commit` | Scans staged files for secrets, dead code, and conflict markers. Can install a git hook. |
| [test-writer](skills/test-writer/) | `/test-writer` | Writes unit and integration tests in the style of the project's existing tests. |

Claude Code has a built-in `/code-review` command. Use `/code-review:code-review` to start
the marketplace skill.

#### Security

| Skill | Slash command | What it does |
|---|---|---|
| [dependency-audit](skills/dependency-audit/) | `/dependency-audit` | Audits dependencies for unpinned versions, deprecated packages, known CVEs, and supply-chain risks. |
| [full-security-review](skills/full-security-review/) | `/full-security-review` | Audits a codebase against OWASP Top 10 2025, the OWASP LLM and agentic lists, and CWE. Gives findings by severity. |

#### Productivity

| Skill | Slash command | What it does |
|---|---|---|
| [doc-refresh](skills/doc-refresh/) | `/doc-refresh` | Finds stale docs, writes missing docs, and rewrites docs to a standard that you select (for example STE-lite or plain language). |
| [log-correlation](skills/log-correlation/) | `/log-correlation` | Correlates logs from the OS, AWS, applications, and web servers to find the cause of a problem. |
| [onboarding](skills/onboarding/) | `/onboarding` | Writes an `ONBOARDING.md` guide for new developers from the codebase. |

### Base skills

A skill with `"category": "base"` writes its content into your project's `CLAUDE.md` when you
start it. Claude Code reads `CLAUDE.md` at the start of each session. Thus the content stays
in effect after the first run, and you do not start the skill again.

To get a new version of the content, run the skill again with `--update`, for example
`/golden-rules --update`.

### Git hooks

Two skills can install a git pre-commit hook. The hook then runs on each commit.

| Skill | What the hook does |
|---|---|
| [pre-commit](skills/pre-commit/) | Scans the staged files for secrets, dead code, naming problems, conflict markers, and commits to `main`. Stops the commit if it finds a BLOCKER. |
| [doc-refresh](skills/doc-refresh/) | Reports stale documentation. With `DOC_REFRESH_HOOK_MODE=write`, it rewrites stale docs and stages them in the same commit. It never stops a commit. |

To install or remove a hook, use these commands:

```text
/pre-commit install      /pre-commit uninstall
/doc-refresh install     /doc-refresh uninstall
```

The two hooks can be installed together. Each installer moves the current hook to
`pre-commit.backup.<skill>`, and the new hook runs that backup first. Each uninstaller
removes only its own hook and puts the backup back.

> **CAUTION:** If `core.hooksPath` is set (for example by husky or lefthook), a hook manager
> controls the hooks. The installers stop and tell you. Add the check to the hook manager's
> configuration.

To skip one hook for one commit, set its variable:

| Skill | Command |
|---|---|
| `pre-commit` | `SKIP_PRE_COMMIT=1 git commit ...` |
| `doc-refresh` | `SKIP_DOC_REFRESH=1 git commit ...` |

> **SECURITY:** `git commit --no-verify` skips all hooks, including the secret scan. Use the
> variables above.

Git does not commit the hooks directory. Each team member must install the hooks in their
own clone.

## Repository structure

```text
ClaudeMarketplace/
├── .claude-plugin/
│   └── marketplace.json        # Marketplace manifest: all plugins and versions
├── skills/
│   ├── registry.json           # Index of all skills
│   └── <skill-name>/           # One directory for each skill (one plugin)
│       ├── SKILL.md            # Instructions, with YAML frontmatter
│       ├── metadata.json       # Name, version, author, tags, tools
│       ├── README.md           # Documentation for people
│       ├── .claude-plugin/
│       │   └── plugin.json     # Plugin manifest
│       └── templates/ ...      # Optional supporting files
├── schema/
│   └── metadata.schema.json    # JSON Schema for metadata.json
├── scripts/                    # Validation, scaffolding, and release tools
├── tests/                      # Tests for the scripts
├── docs/                       # Decisions, assumptions, and reviews
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE                     # MIT
```

| Script | Purpose |
|---|---|
| `scripts/new-skill.sh` | Makes a new skill directory and registers the skill. |
| `scripts/validate.sh` | Checks the structure of one skill. |
| `scripts/validate-all.sh` | Checks all skills. |
| `scripts/check-registry.sh` | Checks that each skill directory is in `registry.json`. |
| `scripts/sync-versions.sh` | Copies each version from `metadata.json` to the other manifests. Use `--check` in CI. |
| `scripts/check-version-bump.py` | Checks that each changed skill has a higher version. |
| `scripts/check-commands.py` | Finds duplicate slash commands. |
| `scripts/scan-prompts.sh` | Scans skill instructions for dangerous patterns. |
| `scripts/generate-changelog-entry.sh` | Writes a changelog entry from the git log. |

## Security

Report a vulnerability privately. Do not open a public issue. [SECURITY.md](SECURITY.md)
gives the procedure.

## Contributing

Contributions are welcome. Make a new skill with these commands:

```bash
./scripts/new-skill.sh my-new-skill
./scripts/validate.sh skills/my-new-skill
./scripts/check-registry.sh
```

Then write the instructions in `skills/my-new-skill/SKILL.md`. [CONTRIBUTING.md](CONTRIBUTING.md)
gives the full procedure and the checks to do before a pull request.

## License

MIT © Doug Eubanks. See [LICENSE](LICENSE).
