<!--
doc: contributing
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# Contributing to the Claude Code Skills Marketplace

This guide tells you how to add a skill, change a skill, and get a pull request merged.

## Add a new skill

1. Make a branch from `main`:

   ```bash
   git switch main && git pull --ff-only
   git switch -c feature/my-skill-name
   ```

2. Scaffold the skill:

   ```bash
   ./scripts/new-skill.sh my-skill-name
   ```

   The script makes `skills/my-skill-name/` with `SKILL.md`, `metadata.json`, `README.md`, and
   `.claude-plugin/plugin.json`. It also adds the skill to `skills/registry.json` and
   `.claude-plugin/marketplace.json`. The name must be kebab-case.

3. Write the instructions in `SKILL.md`. Keep the YAML frontmatter. `name` must be the
   directory name, and `description` is required.
4. Complete `metadata.json` and `README.md`.
5. Run the checks in [Before you commit](#before-you-commit).
6. Open a pull request. Put one skill in each pull request.

Do not change `skills/example-skill/`. It is the reference for contributors.

## Change an existing skill

1. Make your change.
2. Increase the version of the skill. CI fails if you change `SKILL.md`, a supporting file,
   or `metadata.json` and do not increase the version.
3. Write the new version in all four files:
   - `skills/<name>/metadata.json`
   - `skills/registry.json`
   - `.claude-plugin/marketplace.json`
   - `skills/<name>/.claude-plugin/plugin.json`
4. Use a patch increase (`1.2.3` to `1.2.4`) for a fix. Use a minor increase (`1.2.3` to
   `1.3.0`) for a new feature or a layout change.

CI does not require a version increase for a change to `README.md` only. The project rules
in [CLAUDE.md](CLAUDE.md) still ask for one, so users see that the skill changed.

## Skill layout

| File | Purpose |
|---|---|
| `SKILL.md` | The instructions that Claude follows. YAML frontmatter with `name` and `description`. |
| `metadata.json` | Machine-readable metadata. It must agree with `schema/metadata.schema.json`. |
| `README.md` | Documentation for people. |
| `.claude-plugin/plugin.json` | The Claude Code plugin manifest. |
| `templates/`, `rules/`, `standards/`, `scripts/` | Optional supporting files. `SKILL.md` links to them, so they load only when needed. |
| `.scan-exempt` | Optional. Reviewed exceptions for the prompt safety scanner. |

A plugin with more than one skill uses `skills/<sub-skill>/SKILL.md` and has no root
`SKILL.md`. Only `agent-based-development` uses this layout.

In `SKILL.md`, find bundled files through `${CLAUDE_PLUGIN_ROOT}`. Give a fallback to the
path in a local checkout (`skills/<name>/...`).

## Metadata requirements

`schema/metadata.schema.json` is the full schema. These fields are required:

| Field | Type | Rule |
|---|---|---|
| `name` | string | Kebab-case. The same as the directory name. |
| `version` | string | Semantic version, for example `1.0.0`. |
| `description` | string | 200 characters or fewer. |
| `author` | object | `{ "name": ..., "github": ... }` |
| `tags` | array of strings | One tag or more. |
| `commands` | array of strings | One command or more, for example `"/my-skill"`. |

`category` is optional. Its value must be one of `base`, `workflow`, `agents`, `standards`,
`security`, or `productivity`.

## Before you commit

Do all of these checks. CI runs the same checks and fails if one fails.

1. Validate each skill that you changed:

   ```bash
   ./scripts/validate.sh skills/<name>
   ```

2. Make sure that the registry and the versions agree:

   ```bash
   ./scripts/check-registry.sh
   ./scripts/sync-versions.sh --check
   ```

3. Lint the shell scripts:

   ```bash
   shellcheck scripts/*.sh tests/*.sh
   ```

4. Lint the Markdown:

   ```bash
   npx markdownlint-cli2 "skills/**/*.md" "*.md"
   ```

   Do not put bare URLs in Markdown. Put a URL or an email address in angle brackets
   (`<https://example.com>`) or in backticks.

5. Run the test suite:

   ```bash
   bash tests/run-all.sh
   ```

`./scripts/validate-all.sh` runs the structure and registry checks for all skills in one
command.

## Skill guidelines

- Give each skill one job.
- Write explicit, numbered steps. Claude follows specific instructions better than general
  advice.
- Put large reference material (templates, checklists, rules) in supporting files, and link
  to them from `SKILL.md`.
- List the tools that the skill uses in `metadata.json` and in `allowed-tools`. Users then
  know which permissions the skill needs.
- Do not pin a model version in the frontmatter. Use an alias (`haiku`, `sonnet`, or `opus`),
  or leave `model` out so the skill uses the session model.
- Test the skill in Claude Code before you open a pull request.

## Prompt safety scanner

CI runs `scripts/scan-prompts.sh` on each skill. The scanner looks for dangerous patterns:
data exfiltration, credential access, destructive commands, and prompt injection.

Sometimes a skill must use a flagged pattern. For example, a security audit skill talks
about passwords. In that case, add the pattern to a `.scan-exempt` file in the skill
directory, next to `SKILL.md`:

```text
# One exact pattern on each line. Lines that start with # are comments.
password
api[_-]?key
```

> **SECURITY:** Reviewers examine each `.scan-exempt` change. Add only the patterns that the
> skill needs for its purpose. Write a comment that tells why each pattern is necessary.

## Pull requests

- Do not push to `main`. Each change goes through a branch and a pull request.
- Use branch names that start with `feature/`, `fix/`, `hotfix/`, or `claude/`.
- Complete the checklist in the pull request template.
- CI must pass before a merge.

## Code of conduct

Be respectful. Do not submit a skill that is malicious or deceptive, or that tries to get
around safety controls.
