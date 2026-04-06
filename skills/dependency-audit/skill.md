# Dependency Audit

Audit project dependencies for staleness, vulnerabilities, and hygiene issues across multiple package ecosystems.

## Instructions

Invoke as `/dependency-audit` for a report only, or `/dependency-audit --fix` to also apply safe upgrades.

When invoked via `/dependency-audit`:

### Step 1 — Detect Package Manifests

Use Glob to detect package manifests in the project root and subdirectories:
- `package.json`
- `requirements.txt`
- `Pipfile`
- `pyproject.toml`
- `go.mod`
- `Gemfile`
- `composer.json`

Process all manifests that exist. If none are found, report that no supported manifests were detected and exit.

### Step 2 — Analyze Each Manifest

For each manifest found, use Read to parse its contents and apply the following checks:

**package.json**
- Flag unpinned versions: `*`, `latest`, or ranges like `^x.x.x` or `~x.x.x` that allow major/minor drift.
- Flag devDependencies that appear in the `dependencies` block (production runtime contamination).
- Flag known deprecated or problematic packages:
  - `request` — deprecated; recommend `node-fetch` or `axios`
  - `moment` — large bundle size; recommend `date-fns` or `dayjs`
  - `lodash` — tree-shaking concerns; recommend per-method imports or native alternatives
  - `uuid` v3 or earlier — insecure random; recommend v4 or v7

**requirements.txt**
- Flag unpinned packages (no `==` version pin).
- Flag known deprecated packages:
  - `imp` — removed in Python 3.12; use `importlib`
  - `distutils` — deprecated in Python 3.10, removed in 3.12; use `setuptools`
  - `optparse` — deprecated; use `argparse`

**go.mod**
- Flag `replace` directives pointing to local filesystem paths (dangerous in production).
- Flag indirect dependencies that appear significantly behind their available versions.

**Gemfile**
- Flag unpinned gems (no version constraint specified).
- Flag gems with no `source` specified.

**pyproject.toml**
- Apply the same checks as requirements.txt for any listed dependencies.

**composer.json**
- Flag packages using `*` or `@dev` version constraints.

### Step 3 — Check for Lockfiles

Use Glob to check for the following lockfiles:
- `package-lock.json`
- `yarn.lock`
- `pnpm-lock.yaml`
- `poetry.lock`
- `Pipfile.lock`
- `go.sum`
- `Gemfile.lock`

For each manifest found without a corresponding lockfile, flag it as MISSING LOCKFILE.

### Step 4 — Run Audit Tools

Use Bash to run the appropriate audit command if the corresponding manifest exists. Capture output and parse for HIGH and CRITICAL severity findings.

- **Node.js** (if `package.json` exists):
  ```bash
  npm audit --json 2>/dev/null
  ```
- **Python** (if `requirements.txt` or `Pipfile` exists):
  ```bash
  pip-audit --format json 2>/dev/null
  ```
  Skip gracefully if `pip-audit` is not installed — note in the report that pip-audit was not available.
- **Go** (if `go.mod` exists):
  ```bash
  go list -m -json all 2>/dev/null
  ```

Include any HIGH or CRITICAL CVEs found in the report findings.

### Step 5 — Output the Report

Produce a Dependency Audit Report in this format:

```
## Dependency Audit — <project name> — <date>

### Summary
| Category | Count |
|----------|-------|
| Unpinned versions | X |
| Missing lockfiles | X |
| Deprecated packages | X |
| Known CVEs (HIGH+) | X |

### Findings

**[CRITICAL] <package>@<version> — <CVE or issue description>**
- Manifest: <filename>
- Current: <version> | Fix: <fix version or action>
- Recommendation: `<upgrade command>`

**[HIGH] ...**

**[MEDIUM] ...**

**[INFO] ...**

### Upgrade Commands
\`\`\`bash
<aggregated upgrade commands>
\`\`\`
```

Severity tiers:
- **CRITICAL** — Known CVEs rated CVSS 9.0+
- **HIGH** — Known CVEs rated CVSS 7.0–8.9, or critical hygiene issues (e.g., missing lockfile in a production repo)
- **MEDIUM** — Unpinned versions, deprecated packages, local `replace` directives
- **INFO** — Tree-shaking or bundle-size concerns, minor hygiene suggestions

If no issues are found, report a clean bill of health and recommend running audits on a recurring schedule.

### Step 9 — Auto-fix Mode (optional)

After producing the report, ask the user:

> "Would you like me to apply safe upgrades automatically? I'll upgrade patch and minor versions (non-breaking) and run your test suite to verify nothing broke."

If the user agrees:

1. **Determine the package manager** from the manifest files found in Step 1 (npm/yarn/pnpm, pip, go, bundler).

2. **For each package flagged as outdated** (NOT CVE-critical — those require manual review), run the appropriate upgrade command:
   - **npm**: `npm update --save` for minor/patch (does not cross major versions)
   - **pip**: `pip install --upgrade <package>==<safe-version>` for each package individually
   - **go**: `go get <module>@latest` for each indirect dependency
   - **bundler**: `bundle update --conservative` (stays within Gemfile constraints)

3. **After upgrading, detect and run the test suite:**
   - **npm**: `npm test` if defined in `package.json` scripts
   - **pip**: `pytest` or `python -m pytest` if pytest is installed
   - **go**: `go test ./...`
   - **bundler**: `bundle exec rspec` or `bundle exec rake test`

4. **If tests pass:** summarize what was upgraded and confirm. Write a brief upgrade summary to `docs/dependency-upgrades-<date>.md`.

5. **If tests fail:** immediately revert the upgrades (`git checkout -- package*.json` etc.), report which package likely caused the failure, and recommend upgrading that package manually after reading its changelog.

6. **CVE-critical findings are always excluded from auto-fix** — report them separately with a note that they require manual review and testing.
