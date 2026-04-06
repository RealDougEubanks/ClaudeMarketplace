# Dependency Audit

A Claude Code skill that audits project dependencies for staleness, vulnerabilities, and hygiene issues across multiple package ecosystems.

## Usage

```
/dependency-audit
```

Run this command from the root of any project. The skill will auto-detect which package manifests are present and audit each one.

## What It Does

1. **Detects manifests** — Scans for `package.json`, `requirements.txt`, `Pipfile`, `pyproject.toml`, `go.mod`, `Gemfile`, and `composer.json`.
2. **Analyzes each manifest** — Flags unpinned versions, deprecated packages, devDependencies misplaced in production dependencies, and known problematic packages.
3. **Checks for lockfiles** — Warns if a manifest exists without a corresponding lockfile (`package-lock.json`, `yarn.lock`, `poetry.lock`, `go.sum`, `Gemfile.lock`, etc.).
4. **Runs audit tools** — Executes `npm audit`, `pip-audit`, or `go list` if available to surface known CVEs.
5. **Produces a structured report** — Summarizes findings by severity (CRITICAL, HIGH, MEDIUM, INFO) with actionable upgrade commands.

## Supported Ecosystems

| Ecosystem | Manifest | Audit Tool |
|-----------|----------|------------|
| Node.js | `package.json` | `npm audit` |
| Python | `requirements.txt`, `Pipfile`, `pyproject.toml` | `pip-audit` |
| Go | `go.mod` | `go list` |
| Ruby | `Gemfile` | Static analysis only |
| PHP | `composer.json` | Static analysis only |

## Audit Tools Wrapped

- **npm audit** — Built into npm; surfaces CVEs from the npm advisory database.
- **pip-audit** — Must be installed separately (`pip install pip-audit`). Surfaces CVEs from PyPI and OSV databases. The skill skips this step gracefully if `pip-audit` is not installed.
- **go list** — Built into the Go toolchain; lists all module dependencies for analysis.

## Example Output

```
## Dependency Audit — my-project — 2026-04-06

### Summary
| Category | Count |
|----------|-------|
| Unpinned versions | 3 |
| Missing lockfiles | 0 |
| Deprecated packages | 1 |
| Known CVEs (HIGH+) | 1 |

### Findings

**[HIGH] lodash@4.17.20 — Prototype Pollution (CVE-2021-23337)**
- Manifest: package.json
- Current: 4.17.20 | Fix: upgrade to 4.17.21+
- Recommendation: `npm install lodash@latest`

**[MEDIUM] moment@2.29.1 — Large bundle, unmaintained**
- Manifest: package.json
- Recommendation: migrate to `date-fns` or `dayjs`

### Upgrade Commands
\`\`\`bash
npm install lodash@latest
\`\`\`
```

## Installation

Copy `skill.md` into your Claude Code skills directory, or install via the marketplace:

```bash
./scripts/install.sh skills/dependency-audit /path/to/your/project
```
