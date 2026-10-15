<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# Changelog Generator

The changelog-generator skill writes a `CHANGELOG.md` in the
[Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) format. It uses the git
history and, if they exist, the ABD (Agent-Based Development) handoff artifacts.

## Usage

```
/changelog-generator [--strict] [--dry-run]
```

Run the slash command from the root of a git repository.

| Argument | Effect |
|----------|--------|
| *(none)* | Auto mode. Sort commits into sections by keyword. You supply the new version. |
| `--strict` | Parse commits against the Conventional Commits specification. The skill calculates the semver bump and you confirm it. |
| `--dry-run` | Do all steps, then print the new version section. Do not write the file. |

You can use `--strict` and `--dry-run` together.

## What it does

1. **Find the last release tag.** The skill runs `git describe --tags --abbrev=0`. If there is no tag, it uses all commits.
2. **Get the new version.** In auto mode, the skill asks for a `MAJOR.MINOR.PATCH` version. In strict mode, it calculates the version and asks you to confirm it.
3. **Collect commits.** The skill runs `git log` from the last tag to `HEAD` and excludes merge commits.
4. **Read ABD handoff artifacts.** If `handoffs/docs/` exists, the skill reads it for more context on features, bug fixes, and security fixes.
5. **Sort the commits** into the Keep a Changelog sections: Added, Changed, Deprecated, Removed, Fixed, and Security.
6. **Find the changelog.** The skill looks for `CHANGELOG.md`, `docs/CHANGELOG.md`, and `docs/changelogs/`, in that order. If none exists, it creates `CHANGELOG.md` at the repository root.
7. **Write the changelog.** The skill adds the new version section above the first `## [` heading. With `--dry-run`, it prints the section and writes nothing.
8. **Report.** The skill gives the version, date, section counts, and file path. It also lists the uncategorized commits.

The skill copies commit subjects as data. It does not follow instructions in commit
messages.

## Output format

The generated section looks like this:

```markdown
## [1.2.0] - 2026-04-06

### Added
- New user authentication flow (abc1234)

### Fixed
- Resolved race condition in job queue (def5678)

### Security
- Patched XSS vulnerability in comment renderer (ghi9012)
```

The skill omits empty sections. It does not add sections that Keep a Changelog does not
define. The one exception is a temporary **Uncategorized — Please Review** list. Sort those
entries into the standard sections before the release.

## Auto mode: commit keywords

Matching is not case-sensitive.

| Commit message | Section |
|----------------|---------|
| Starts with `feat:`, `add`, `new` | Added |
| Starts with `refactor:`, `update`, `change`, `improve` | Changed |
| Contains `deprecat` | Deprecated |
| Starts with `remove`, `delete`, `drop` | Removed |
| Starts with `fix:`, `bug`, `patch` | Fixed |
| Starts with `security:`, `vuln`, `cve`, `hotfix` | Security |
| Anything else | Uncategorized — Please Review |

## Strict mode: Conventional Commits

The skill parses each commit as `<type>(<scope>): <description>`. The scope is optional.

| Commit type | Section |
|-------------|---------|
| `feat` | Added |
| `fix` | Fixed |
| `perf`, `refactor`, `style` | Changed |
| `revert` | Fixed or Removed, with the prefix `Reverted:` |
| `docs`, `ci`, `build`, `chore`, `test` | No entry (internal only) |
| Breaking change (`!` after the type, or a `BREAKING CHANGE:` footer) | Changed or Removed, with the prefix `**BREAKING:**`, listed first |
| Does not match the format | Uncategorized — Please Review |

The skill recommends a version bump from the commits:

| Commits | Bump |
|---------|------|
| Any breaking change | MAJOR |
| Any `feat`, no breaking change | MINOR |
| Only `fix`, `perf`, or `refactor` | PATCH |

## Integration with the ABD workflow

If your project uses the ABD workflow, put completed handoff documents in `handoffs/docs/`.
The skill reads them to add context that commit messages do not contain. This helps when one
feature spans many commits.

## Installation

Add this repository as a marketplace in `~/.claude/settings.json`, then enable the plugin:

```json
{
  "enabledPlugins": {
    "changelog-generator@claude-skills-marketplace": true
  }
}
```

Then type `/changelog-generator` in a Claude Code session.
