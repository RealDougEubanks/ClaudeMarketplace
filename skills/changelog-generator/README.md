# Changelog Generator

A Claude Code skill that generates a structured `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format from git history and ABD (Agent-Based Development) handoff artifacts.

## Usage

```
/changelog-generator
```

Run this command from the root of a git repository. The skill will prompt you for the new version number, then automatically build or update your changelog.

## What It Does

1. **Finds the last release tag** — Uses `git describe --tags` to determine where the current release starts.
2. **Prompts for the new version** — Asks you to confirm the version being released (e.g., `1.2.0`).
3. **Collects commits** — Runs `git log` to gather all commits since the last tag, excluding merge commits.
4. **Reads ABD handoff artifacts** — If `handoffs/docs/` exists, reads those files to supplement commit data with richer feature and bug fix context.
5. **Categorizes commits** — Sorts commits into Keep a Changelog sections (Added, Changed, Deprecated, Removed, Fixed, Security) based on commit message conventions.
6. **Writes or updates CHANGELOG.md** — Prepends the new version section to an existing changelog, or creates a fresh one with the standard header.
7. **Confirms and reminds** — Reports what was written and flags any uncategorized commits for manual review.

## Keep a Changelog Format

This skill follows https://keepachangelog.com/en/1.1.0/ exactly. The generated output looks like:

```markdown
## [1.2.0] - 2026-04-06

### Added
- New user authentication flow (abc1234)

### Fixed
- Resolved race condition in job queue (def5678)

### Security
- Patched XSS vulnerability in comment renderer (ghi9012)
```

## Commit Message Conventions

For best results, use these prefixes in your commit messages:

| Prefix | Section |
|--------|---------|
| `feat:`, `add`, `new` | Added |
| `refactor:`, `update`, `change`, `improve` | Changed |
| `deprecat` (anywhere in message) | Deprecated |
| `remove`, `delete`, `drop` | Removed |
| `fix:`, `bug`, `patch` | Fixed |
| `security:`, `vuln`, `cve`, `hotfix` | Security |

Commits that do not match any pattern are placed in an **Uncategorized** section for manual review.

## Integration with ABD Workflow

If your project uses the Agent-Based Development (ABD) workflow, place completed handoff documents in `handoffs/docs/`. The skill reads these artifacts to enrich changelog entries with context beyond what is captured in commit messages — particularly useful for features that span multiple commits or work items resolved across agents.

## Installation

Copy `skill.md` into your Claude Code skills directory, or install via the marketplace:

```bash
./scripts/install.sh skills/changelog-generator /path/to/your/project
```
