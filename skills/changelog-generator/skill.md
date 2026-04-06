# Changelog Generator

Generate a structured CHANGELOG.md following the Keep a Changelog format from git history and ABD handoff artifacts.

## Instructions

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
