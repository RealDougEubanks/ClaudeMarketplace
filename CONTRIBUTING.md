# Contributing to Claude Code Skills Marketplace

Thanks for your interest in contributing a skill! Follow the steps below.

## Adding a New Skill

### 1. Scaffold from the template

```bash
./scripts/new-skill.sh my-skill-name
```

This creates `skills/my-skill-name/` with stub files for `skill.md`, `metadata.json`, `README.md`, and `.claude-plugin/plugin.json`.

### 2. Write the three required files

**`skill.md`** — The prompt Claude will follow when the skill is invoked. Write it as a numbered sequence of explicit instructions. Claude performs better with specific, unambiguous steps.

**`metadata.json`** — Machine-readable metadata. All fields must conform to `schema/metadata.schema.json`:

```json
{
  "name": "my-skill-name",
  "version": "1.0.0",
  "description": "What the skill does in one sentence (max 200 chars)",
  "author": {
    "name": "Your Name",
    "github": "your-github-username"
  },
  "license": "MIT",
  "category": "workflow",
  "tags": ["tag1", "tag2"],
  "commands": ["/my-skill-name"],
  "triggers": [],
  "tools": ["Read", "Write", "Bash"]
}
```

**`README.md`** — Human-readable documentation. Cover: what the skill does, how to install it, slash commands it provides, and example usage.

### 3. Validate your skill

```bash
./scripts/validate.sh skills/my-skill-name
```

This checks that all required files are present and that `metadata.json` conforms to the schema.

### 4. Add to the registry

Add an entry to `skills/registry.json`:

```json
{
  "name": "my-skill-name",
  "path": "skills/my-skill-name",
  "description": "<must exactly match metadata.json description>",
  "tags": ["tag1", "tag2"],
  "version": "1.0.0",
  "category": "workflow"
}
```

Then verify consistency:

```bash
./scripts/check-registry.sh
```

### 5. Handle prompt safety scan exemptions

The CI runs `./scripts/scan-prompts.sh` to flag sensitive patterns (e.g. `password`, `api_key`, `\.env`). If your skill legitimately references these as documentation or examples — not as actual secrets — add a `.scan-exempt` file:

```
# This skill IS the secret scanner; patterns below are regex examples
api[_-]?key
password
AWS_SECRET
```

Each line is a pattern to exempt. Add a comment explaining why each exemption is safe.

### 6. Run the full safety scan

```bash
./scripts/scan-prompts.sh
```

Resolve any HIGH findings that are not exempted.

### 7. Submit a pull request

- Branch from the current `release/<version>` branch (or `main` if no release branch exists)
- One skill per PR
- PR title format: `Add <skill-name> skill`
- Include a description of what the skill does, what commands it adds, and any setup requirements

---

## Versioning

Skills use [Semantic Versioning](https://semver.org/):

- **Patch** (`1.0.0` → `1.0.1`): bug fixes, wording improvements
- **Minor** (`1.0.0` → `1.1.0`): new commands, new phases, backwards-compatible additions
- **Major** (`1.0.0` → `2.0.0`): breaking changes to commands or output format

Bump the version in both `metadata.json` and the `skills/registry.json` entry whenever you make changes to an existing skill.

---

## Skill Guidelines

- **Keep skills focused** — each skill should do one thing well.
- **Be explicit** — write clear, step-by-step instructions in `skill.md`.
- **Declare your tools** — list the tools the skill uses in `metadata.json` so users know what permissions are needed.
- **Tag appropriately** — use descriptive tags so users can discover your skill.
- **Test locally** — invoke your skill with Claude Code before submitting.
- **No dead code** — don't leave placeholder or stub instructions in production-bound skills.

---

## Metadata Schema Reference

See `schema/metadata.schema.json` for the full schema. Required fields:

| Field | Type | Constraint |
|-------|------|------------|
| `name` | string | Unique, kebab-case |
| `version` | string | Semver (e.g. `1.0.0`) |
| `description` | string | Max 200 characters |
| `author` | object | `{ name, github?, url? }` |
| `tags` | string[] | At least one tag |

Optional fields: `license`, `category`, `commands`, `triggers`, `tools`, `compatibility`.

Valid `category` values: `base`, `workflow`, `agents`, `standards`, `security`, `productivity`.

---

## Code of Conduct

Be respectful. Don't submit skills that are malicious, deceptive, or designed to circumvent safety measures.
