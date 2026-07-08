<!--
doc: CONTRIBUTING
last-refreshed: 2026-04-07
generated-by: doc-refresh skill
-->

# Contributing to Claude Code Skills Marketplace

Thanks for your interest in contributing a skill! Follow the steps below.

## Adding a New Skill

1. **Scaffold from the template**

   ```bash
   ./scripts/new-skill.sh my-skill-name
   ```

   This creates `skills/my-skill-name/` with pre-filled `SKILL.md`, `metadata.json`, `README.md`, and `.claude-plugin/plugin.json`, registers the skill, and validates the name is kebab-case.

2. **Edit the files**

   - `SKILL.md` — The prompt/instructions Claude will follow when the skill is invoked. Must have YAML frontmatter with `name` and `description`.
   - `metadata.json` — Name, version, description, author, tags, and other metadata.
   - `README.md` — Human-readable documentation for the skill.

3. **Validate your skill**

   ```bash
   ./scripts/validate.sh skills/my-skill
   ```

4. **Add to the registry**

   Add an entry to `skills/registry.json` with your skill's name, path, description, tags, and version.

5. **Submit a pull request**

   - Branch from `main`
   - One skill per PR
   - Include a clear description of what the skill does and how to use it

## Skill Guidelines

- **Keep skills focused** — each skill should do one thing well.
- **Be explicit** — write clear, step-by-step instructions in `SKILL.md`. Claude performs better with specific guidance.
- **Load big reference material on demand** — put templates, checklists, and rules in supporting directories next to `SKILL.md` and reference them with markdown links so they only load when needed.
- **Declare your tools** — list the tools the skill uses in `metadata.json` so users know what permissions are needed.
- **Tag appropriately** — use descriptive tags so users can discover your skill.
- **Test locally** — try your skill with Claude Code before submitting.

## Metadata Schema

See `schema/metadata.schema.json` for the full schema. Required fields:

| Field         | Type     | Description                        |
|---------------|----------|------------------------------------|
| `name`        | string   | Unique kebab-case identifier       |
| `version`     | string   | Semver (e.g., `1.0.0`)            |
| `description` | string   | What the skill does (max 200 chars)|
| `author`      | object   | `{ name, github?, url? }`         |
| `tags`        | string[] | At least one categorization tag    |

## Prompt Safety Scanner

All skill prompt files are scanned by `scripts/scan-prompts.sh` for potentially dangerous patterns (data exfiltration, credential access, destructive commands, prompt injection). The scanner runs in CI on every PR.

If your skill legitimately references a flagged pattern (e.g., a security-review skill that discusses credentials), you can exempt specific patterns by creating a `.scan-exempt` file at your skill's plugin root (next to `SKILL.md`):

```text
# Each line is an exact pattern string to exempt (comments start with #)
password
api[_-]?key
```

**Important:** `.scan-exempt` additions are reviewed carefully during PR review. Only exempt patterns that are genuinely necessary for the skill's purpose.

## Code of Conduct

Be respectful. Don't submit skills that are malicious, deceptive, or designed to circumvent safety measures.
