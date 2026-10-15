<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# Dependency Audit

The dependency-audit skill audits project dependencies in many package ecosystems. It finds
outdated packages, known CVEs, and hygiene problems.

## Usage

```
/dependency-audit          # report only
/dependency-audit --fix    # report, then apply safe minor/patch upgrades and run tests
```

Run the slash command from the root of the project. The skill finds the package manifests and
audits each one.

| Argument | Effect |
|----------|--------|
| *(none)* | Write the report only. |
| `--fix` | Write the report, then offer to apply safe minor and patch upgrades and run the tests. |

## What it does

1. **Find manifests.** The skill looks for `package.json`, `requirements.txt`, `Pipfile`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, `composer.json`, `*.csproj`, and `packages.config`.
2. **Analyze each manifest.** The skill finds unpinned versions, deprecated packages, and dev dependencies in the production list.
3. **Check runtimes.** The skill flags an `engines.node` floor below 22 (Node.js 20 is end-of-life). It also flags Python imports of standard-library modules that Python 3.12 and 3.13 removed.
4. **Check for lockfiles.** The skill flags each manifest that has no lockfile.
5. **Run audit tools** to find known CVEs. It checks each HIGH and CRITICAL CVE against the CISA KEV catalog and the EPSS score.
6. **Check the supply chain:** install scripts, `npm audit signatures`, possible typosquats, and an SBOM recommendation.
7. **Write the report.** The report groups findings by severity and gives upgrade commands.

## Supported ecosystems

| Ecosystem | Manifest | Lockfile | Audit tool |
|-----------|----------|----------|------------|
| Node.js | `package.json` | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lock` | `npm audit` / `pnpm audit` / `yarn npm audit` |
| Python | `requirements.txt`, `Pipfile`, `pyproject.toml` | `Pipfile.lock`, `poetry.lock`, `uv.lock`, `pdm.lock` | `pip-audit` (requirements files), `osv-scanner` (other lockfiles) |
| Go | `go.mod` | `go.sum` | `govulncheck` |
| Rust | `Cargo.toml` | `Cargo.lock` | `cargo audit` |
| Ruby | `Gemfile` | `Gemfile.lock` | `osv-scanner` |
| PHP | `composer.json` | `composer.lock` | `composer audit` |
| .NET | `*.csproj`, `packages.config` | `packages.lock.json` | `dotnet list package --vulnerable` |

## Audit tools

| Tool | Install | Notes |
|------|---------|-------|
| `npm audit` / `pnpm audit` / `yarn npm audit` | Part of the package manager | The skill uses the tool that matches the lockfile. |
| `pip-audit` | In the project `.venv`, or `pipx install pip-audit` | Runs as `pip-audit -r requirements.txt`, so it audits the manifest, not the active environment. |
| `osv-scanner` | `go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest` | Reads lockfiles from all supported ecosystems. Fallback when a native tool is missing. |
| `govulncheck` | `go install golang.org/x/vuln/cmd/govulncheck@latest` | Uses call-graph analysis. |
| `cargo audit` | `cargo install cargo-audit` | Uses the RustSec advisory database. |
| `composer audit` | Part of Composer 2.4+ | — |
| `dotnet list package --vulnerable` | Part of the .NET SDK | Includes transitive packages. |

If a tool is not installed, the skill skips it. The report names the missing tool and how to
install it.

> **SECURITY:** Install `pip-audit` in the project virtual environment or with `pipx`. Do not
> install it into the OS Python.

## Severity

The skill uses the advisory's CVSS v4.0 base score. If there is no v4.0 score, it uses CVSS
v3.1.

| Severity | Criteria |
|----------|----------|
| CRITICAL | CVSS 9.0 or more, or a HIGH CVE in the CISA KEV catalog |
| HIGH | CVSS 7.0–8.9; a lower CVE with an EPSS score in the top 5%; a critical hygiene problem such as a missing lockfile in production; an invalid npm registry signature |
| MEDIUM | Unpinned versions, deprecated packages, local `replace` directives, removed Python modules, supply-chain leads |
| INFO | Bundle-size concerns, minor hygiene, SBOM recommendation |

The report marks CVEs from the KEV catalog with `[KEV]` and lists them first. If the skill
cannot do network lookups, the report says so.

## Fix mode (`--fix`)

After the report, the skill asks before it changes anything. The skill never auto-fixes
CVE-critical findings. Review and test those upgrades manually.

> **CAUTION:** `--fix` needs a clean working tree. Commit or stash your changes first. If the
> tests fail, the skill restores the manifest and lockfile paths with `git checkout`.

If you agree to the upgrades, the skill does these steps:

1. Make sure the working tree is clean.
2. Upgrade each flagged package within its minor and patch versions. For Python, the skill
   installs upgrades only inside `.venv/`. If there is no virtual environment, it stops.
3. Run the test suite.
4. If the tests pass, write a summary to `docs/dependency-upgrades-<date>.md`.
5. If the tests fail, restore the manifests and lockfiles and name the package that probably
   caused the failure.

## Example output

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

Add this repository as a marketplace in `~/.claude/settings.json`, then enable the plugin:

```json
{
  "enabledPlugins": {
    "dependency-audit@claude-skills-marketplace": true
  }
}
```

Then type `/dependency-audit` in a Claude Code session.
