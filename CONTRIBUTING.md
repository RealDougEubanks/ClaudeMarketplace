# Contributing to Claude Code Skills Marketplace

Thanks for your interest in contributing a skill! Follow the steps below.

## Adding a New Skill

1. **Scaffold from the template**

   ```bash
   ./scripts/new-skill.sh my-skill-name
   ```

   This creates `skills/my-skill-name/` with pre-filled `skill.md`, `metadata.json`, and `README.md`, and validates the name is kebab-case. Alternatively, copy manually: `cp -r templates/ skills/my-skill-name`

2. **Edit the files**

   - `skill.md` — The prompt/instructions Claude will follow when the skill is invoked.
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
- **Be explicit** — write clear, step-by-step instructions in `skill.md`. Claude performs better with specific guidance.
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

## Code of Conduct

Be respectful. Don't submit skills that are malicious, deceptive, or designed to circumvent safety measures.
