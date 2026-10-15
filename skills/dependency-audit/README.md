# Dependency Audit

A Claude Code skill that audits project dependencies for staleness, vulnerabilities, and hygiene issues across multiple package ecosystems.

## Usage

```
/dependency-audit          # report only
/dependency-audit --fix    # report, then apply safe minor/patch upgrades and run tests
```

Run this command from the root of any project. The skill will auto-detect which package manifests are present and audit each one.

`--fix` requires a clean working tree (commit or stash first). CVE-critical findings are never auto-fixed — they always require manual review.

## What It Does

1. **Detects manifests** — Scans for `package.json`, `requirements.txt`, `Pipfile`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, `composer.json`, and `.csproj` files.
2. **Analyzes each manifest** — Flags unpinned versions, deprecated packages, devDependencies misplaced in production dependencies, and known problematic packages.
3. **Checks for lockfiles** — Warns if a manifest exists without a corresponding lockfile (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lock`, `poetry.lock`, `uv.lock`, `pdm.lock`, `go.sum`, `Cargo.lock`, `Gemfile.lock`, etc.).
4. **Runs audit tools** — Executes `npm audit`/`pnpm audit`/`yarn npm audit`, `pip-audit -r requirements.txt`, `govulncheck`, `cargo audit`, `composer audit`, or `dotnet list package --vulnerable` if available to surface known CVEs, with `osv-scanner` as a cross-ecosystem fallback. HIGH and CRITICAL CVEs are cross-checked against the CISA KEV catalog and EPSS.
5. **Checks the supply chain** — Install scripts, `npm audit signatures`, likely typosquats, and an optional SBOM recommendation (CycloneDX or SPDX).
6. **Produces a structured report** — Summarizes findings by severity (CRITICAL, HIGH, MEDIUM, INFO) with actionable upgrade commands.

## Supported Ecosystems

| Ecosystem | Manifest | Audit Tool |
|-----------|----------|------------|
| Node.js | `package.json` | `npm audit` / `pnpm audit` / `yarn npm audit` |
| Python | `requirements.txt`, `Pipfile`, `pyproject.toml` | `pip-audit` (requirements files), `osv-scanner` (other lockfiles) |
| Go | `go.mod` | `govulncheck` |
| Rust | `Cargo.toml` | `cargo audit` |
| Ruby | `Gemfile` | `osv-scanner` (reads `Gemfile.lock`) |
| PHP | `composer.json` | `composer audit` |
| .NET | `*.csproj` | `dotnet list package --vulnerable` |

## Audit Tools Wrapped

- **npm/pnpm/yarn audit** — Built into the package manager; surfaces CVEs from the npm advisory database. The skill picks the tool matching your lockfile.
- **pip-audit** — Must be installed separately, inside the project `.venv` or with `pipx install pip-audit` (never into the OS Python). Run against the manifest with `-r requirements.txt`. Surfaces CVEs from PyPI and OSV databases. The skill skips this step gracefully if `pip-audit` is not installed.
- **osv-scanner** — Install with `go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest`. Reads lockfiles from every supported ecosystem (including `bun.lock`, `uv.lock`, `pdm.lock`, `Gemfile.lock`) against the OSV.dev database.
- **govulncheck** — Install with `go install golang.org/x/vuln/cmd/govulncheck@latest`. Surfaces CVEs from the Go vulnerability database with call-graph analysis.
- **cargo audit** — Install with `cargo install cargo-audit`. Surfaces CVEs from the RustSec advisory database.
- **composer audit** — Built into Composer 2.4+.
- **dotnet list package --vulnerable** — Built into the .NET SDK.

Any tool that is missing is skipped gracefully and noted in the report with install instructions.

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

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "dependency-audit@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/dependency-audit` in any Claude Code session.
