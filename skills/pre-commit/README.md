<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# pre-commit

This skill is a fast quality gate that you run before a commit. It scans the staged files
for common problems. It can also install a git hook, so that the blocking checks run on each
`git commit`.

Claude does not start this skill by itself (`disable-model-invocation: true`). You must type
the slash command.

## Usage

| Slash command | Mode | Result |
|---|---|---|
| `/pre-commit` | A: run checks now (default) | Scans the staged files, or the modified files if nothing is staged. |
| `/pre-commit install` | B: install the git hook | Writes a `pre-commit` hook to the hooks directory of the repository. |
| `/pre-commit uninstall` | C: remove the git hook | Removes the hook of this skill and restores an earlier hook, if one was backed up. |

## Checks and Severity

Each finding has one of two severity levels:

- **BLOCKER**: the commit is blocked until you fix the problem.
- **WARNING**: the commit is not blocked. Claude asks you to confirm before you continue.

| Check | Finding | Severity |
|---|---|---|
| Secret scan | Hardcoded passwords, API keys, tokens, AWS credentials, private key headers | BLOCKER (WARNING in `*.test.*` and `*.spec.*` files) |
| Dead code scan | `stub` or `placeholder` in non-test files | BLOCKER |
| Dead code scan | `TODO`, `FIXME`, `HACK`, `XXX`, `impl later`, 3 or more lines of commented-out code | WARNING |
| Naming check | ALL_CAPS non-constants, single-letter variables outside loop counters, names shorter than 3 characters in function signatures | WARNING |
| Branch check | A commit directly to `main` | BLOCKER |
| Conflict markers | `<<<<<<< HEAD` merge conflict markers | BLOCKER |
| Trailing whitespace | Lines that end with whitespace | WARNING |

## Mode A: Run Checks Now

```
/pre-commit
```

The skill runs all checks and prints a summary table. Then it does one of these:

- If there is a BLOCKER, it lists each finding with the file and line number, and stops the commit.
- If there are only WARNINGs, it asks: "Proceed with commit anyway? (y/n)".
- If all checks pass, it prints "All checks passed. Safe to commit."

If nothing is staged or modified, the skill reports that there is nothing to check.

## What Each Check Finds

### Secret scan

The secret scan looks for these patterns:

- Assignments with `=` or `:` (code, YAML, and JSON) to names such as `password`, `passwd`, `pwd`, `api_key`, `apikey`, `api_token`, `access_token`, `secret_key`, `client_secret`, and `secret`
- Shell exports such as `export API_TOKEN=...`
- AWS key assignments and literal `AKIA...` access key IDs
- Token prefixes: `sk-ant-`, `sk-proj-`, `github_pat_`, `ghp_`, `glpat-`, `npm_`, `AIza`, `xox[baprs]-`, `sk_live_`
- PEM private key headers, for example `-----BEGIN RSA PRIVATE KEY-----`
- Long mixed-case literals assigned to names that contain `key`, `token`, `secret`, or `auth`

The scan skips `*.example` and `*.sample` files, and paths under `node_modules/` or
`vendor/`. It scans test files, but a match in a test file is a WARNING. The report shows
only the first 4 characters of each matched value.

### Dead code scan

The scan reads staged source files and skips `.md`, `.txt`, and other documentation files.
`stub` and `placeholder` show incomplete code, so they are BLOCKERs. Other placeholder
markers and commented-out code blocks are WARNINGs.

### Naming check

The check reads each staged source file. It uses the naming rules in `CLAUDE.md` if the file
exists. All naming findings are WARNINGs.

### Branch check

A commit directly to `main` is a BLOCKER. Make a feature branch and open a pull request.

### Conflict markers and trailing whitespace

A `<<<<<<< HEAD` marker shows an unresolved merge conflict, so it is a BLOCKER. Trailing
whitespace is a WARNING.

## Mode B: Install the Git Hook

Run this command one time in each clone of the repository:

```
/pre-commit install
```

The skill finds the hooks directory with `git rev-parse --git-path hooks`. Usually this is
`.git/hooks`. The skill writes a fixed script to `pre-commit` in that directory and makes it
executable.

> **CAUTION:** If `core.hooksPath` is set, a hook manager (for example, husky or lefthook)
> probably controls the hooks. The installer warns you and stops. Call the checks from the
> config of the hook manager, or confirm that you want to install the hook anyway.

The installed hook uses only shell checks, so it works without Claude Code. It blocks a
commit for these findings:

- A commit directly to `main` or `master`.
- A possible secret in a staged file. In a staged test file, this is a warning only.
- Merge conflict markers (lines that start with `<<<<<<<` or `>>>>>>>`) in a staged file.

If the `claude` CLI is installed, the hook also runs an advisory review. The review is
limited to 60 seconds where the `timeout` command exists. It can only warn. It cannot block
or approve a commit.

If a different `pre-commit` hook exists (for example, the hook from the doc-refresh skill),
the installer moves it to `pre-commit.backup.pre-commit`. The new hook runs the old hook first
on each commit. The installer does not overwrite an existing backup. If the existing hook has
the marker line `# claude-skill-hook: pre-commit`, the installer upgrades it in place.

Git hooks are local to your computer. Each team member must run `/pre-commit install` in
their clone. You can also add the command to the setup script of the project.

## Mode C: Remove the Git Hook

```
/pre-commit uninstall
```

The skill removes the hook only if the hook has the marker line
`# claude-skill-hook: pre-commit`. If a backup exists, the skill restores it as the active
hook. The skill does not touch a hook from a different tool.

## Skip the Hook in an Emergency

> **SECURITY:** A bypass skips the secret scan. Use a bypass only for a clear, urgent reason,
> such as the revert of a production incident. After the emergency, review the commit for
> the problems that the hook did not check.

To skip only this hook, use the hook-specific variable. A chained earlier hook still runs:

```bash
SKIP_PRE_COMMIT=1 git commit ...
```

`git commit --no-verify` also works, but it skips **all** hooks. Use it only when every hook
must be skipped. Do not make a bypass part of your usual workflow.
