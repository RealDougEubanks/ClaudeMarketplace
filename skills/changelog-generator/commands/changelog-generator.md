---
name: changelog-generator
description: Generates a structured CHANGELOG.md following Keep a Changelog format from git history and ABD handoff artifacts. Prepends new version sections to existing changelogs.
---

# Changelog Generator

Generate a structured CHANGELOG.md following the Keep a Changelog format from git history and ABD handoff artifacts.

## Instructions

**Two modes:**
- **Auto mode** (default): categorizes commits by keyword matching (existing behavior).
- **Strict mode** (`/changelog-generator --strict`): follows the Conventional Commits spec exactly. Enables automatic semver bumping.

If `--strict` is passed, run the [Strict Mode](#strict-mode) flow after Step 3 (commit collection) instead of Step 5's keyword categorization. Steps 1–4 and 6–8 still apply.

---

## Strict Mode

### Step 5S — Parse Commits Against Conventional Commits Spec

For each commit message collected in Step 3, parse it against the Conventional Commits specification:

- **Format**: `<type>(<scope>): <description>`
  - The `(<scope>)` part is optional.
  - A `!` after the type (e.g. `feat!: ...`) indicates a breaking change.
- **Valid types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- **Breaking changes**: indicated by `!` after the type/scope OR by a `BREAKING CHANGE:` footer in the commit body.

Map each parsed commit to changelog sections:

| Conventional Commits type | Changelog section |
|---------------------------|-------------------|
| `feat` | **Added** |
| `fix` | **Fixed** |
| `perf` | **Changed** (note: performance improvement) |
| `refactor`, `style` | **Changed** |
| `revert` | **Reverted** (special section) |
| `docs`, `ci`, `build`, `chore`, `test` | *(no entry — internal only)* |
| Breaking change (any type with `!` or `BREAKING CHANGE:` footer) | **Breaking Changes** (always at the top of the version block) |
| Does not match spec format | **Uncategorized** — with note: "These commits don't follow Conventional Commits format and were not auto-categorized." |

### Step 5S-2 — Auto-Determine Semver Bump

Inspect all parsed commits and determine the recommended version bump:

| Condition | Bump |
|-----------|------|
| Any commit with `!` or `BREAKING CHANGE:` footer | **MAJOR** (x.0.0) |
| Any `feat` commit (no breaking change) | **MINOR** (0.x.0) |
| Only `fix`, `perf`, or `refactor` commits | **PATCH** (0.0.x) |

Show the user the recommended version number based on the last tag (from Step 1) and the determined bump level:

> "Based on the commits, the recommended version bump is **MINOR**. Suggested version: `<computed-version>`. Confirm this version, or enter a different one:"

Wait for the user to confirm or override before proceeding to Step 6.

---

When invoked via `/changelog-generator`:

### Step 1 — Determine the Last Release Tag

Use Bash to find the most recent git tag:

```bash
git describe --tags --abbrev=0 2>/dev/null || echo "none"
```

Store the result as `<last-tag>`. If the output is `none`, all commits will be included.

### Step 2 — Ask the User for the New Version

Prompt the user:

> What is the new version being released? (e.g., `1.2.0`)

Wait for their response before proceeding. Validate that the input matches semantic versioning format (`MAJOR.MINOR.PATCH`).

### Step 3 — Collect Commits Since Last Tag

Use Bash to retrieve commits since the last tag (or all commits if no tag exists):

```bash
# If last-tag exists:
git log <last-tag>..HEAD --oneline --no-merges

# If no tag:
git log --oneline --no-merges
```

Capture each commit as `<short-hash> <message>`.

### Step 4 — Check for ABD Handoff Artifacts

Use Glob to check if `handoffs/docs/` exists. If it does, use Read on all files found there. Extract:
- Features completed (to supplement the Added section)
- Bugs fixed (to supplement the Fixed section)
- Security fixes (to supplement the Security section)

Merge this context with the commit log to produce richer changelog entries.

### Step 5 — Categorize Commits

Categorize each commit into the appropriate Keep a Changelog section using these rules:

| Section | Commit message patterns |
|---------|------------------------|
| **Added** | starts with `feat:`, `add`, `new` |
| **Changed** | starts with `refactor:`, `update`, `change`, `improve` |
| **Deprecated** | contains `deprecat` |
| **Removed** | starts with `remove`, `delete`, `drop` |
| **Fixed** | starts with `fix:`, `bug`, `patch` |
| **Security** | starts with `security:`, `vuln`, `cve`, `hotfix` |
| **Uncategorized** | everything else |

Matching is case-insensitive. Include the short commit hash in parentheses after each entry.

List Uncategorized commits in a separate section at the end of the new version block with a note asking the user to manually sort them.

### Step 6 — Read or Initialize CHANGELOG.md

Use Read to check if `CHANGELOG.md` already exists.

- **If it exists**: Read the current contents. Prepend the new version section above the first existing `## [` heading.
- **If it does not exist**: Create it from scratch with the standard Keep a Changelog header.

Standard header (use if creating from scratch):
```
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
```

### Step 7 — Write CHANGELOG.md

Use Edit (if prepending to an existing file) or Write (if creating from scratch) to save the updated `CHANGELOG.md`.

The new version section format:

```markdown
## [<version>] - <YYYY-MM-DD>

### Added
- <description> (<short-hash>)

### Changed
- <description> (<short-hash>)

### Deprecated
- <description> (<short-hash>)

### Removed
- <description> (<short-hash>)

### Fixed
- <description> (<short-hash>)

### Security
- <description> (<short-hash>)

### Uncategorized — Please Review
- <description> (<short-hash>)
```

Omit any section that has no entries.

### Step 8 — Confirm and Remind

After writing the file, output:
- Confirmation of what was written (version, date, section counts)
- A reminder to review the **Uncategorized** section if any commits ended up there
- The path to the written `CHANGELOG.md`
- A suggestion to run `git add CHANGELOG.md` and commit before tagging the release
