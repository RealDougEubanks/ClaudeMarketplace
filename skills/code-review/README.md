<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# Code Review Skill

The code-review skill does a structured engineering review of source files. It checks
readability, complexity, test gaps, SOLID principles, API consistency, and naming. It writes a
markdown report with a `file:line` citation for each finding.

## Usage

```
/code-review [--quick] [path]
```

| Argument | Effect |
|----------|--------|
| *(none)* | Full mode. The skill asks for the scope: the branch diff (default), a file or directory, or all source files. |
| `path` | Review this file or directory. |
| `--quick` | Quick mode. Check only long functions and clear naming problems. |

Examples:

```
/code-review
/code-review src/services/orderService.ts
/code-review --quick src/
```

Claude Code has a built-in `/code-review` slash command with the same name. If the built-in
command runs instead of this skill, type `/code-review:code-review`.

## Modes

| Mode | Checks | Use it |
|------|--------|--------|
| Full (default) | Readability, complexity, test gaps, SOLID, API consistency, naming | Before you open a pull request |
| Quick (`--quick`) | Functions longer than 20 lines; clear naming problems | During active development |

Quick mode does not check SOLID principles or test gaps, and it does not write a review
artifact.

## What it does

1. **Find the default branch.** The skill reads `origin/HEAD`. If that fails, it reads the
   output of `git remote show origin`. It does not assume `main`.
2. **Get the scope.** The default scope is `git diff <default>...HEAD`. If the branch has no
   changes, the skill reviews all source files.
3. **Read and evaluate each file** in full mode:
   - **Readability:** clear names, no magic numbers, logic that is easy to follow.
   - **Complexity:** functions longer than 25 lines, or more than 5 branch points.
   - **Test gaps:** public functions with no matching test file.
   - **SOLID:** Single Responsibility, Open/Closed, and DRY (duplicate blocks of 5 or more
     lines).
   - **API consistency:** signatures, return types, and error handling that differ from the
     rest of the codebase.
   - **Naming:** differences from the naming rules in `CLAUDE.md` or `docs/assumptions.md`.
4. **Write a review artifact.** If `handoffs/reviews/` exists, the skill writes a JSON
   artifact there.
5. **Write the report.** The report has a summary table and the findings.

## Severity

Each finding title starts with a severity and a category, for example
`[MED][COMPLEXITY]`.

| Severity | Meaning |
|----------|---------|
| `[HIGH]` | Likely to cause bugs or maintenance failures |
| `[MED]` | Makes the code harder to maintain or test |
| `[LOW]` | Style or a minor improvement |

Categories: `READABILITY`, `COMPLEXITY`, `TEST_GAP`, `SOLID`, `CONSISTENCY`, `NAMING`.

## Scope limits

This skill checks engineering quality only. It does not check for:

- Security vulnerabilities (SQL injection, XSS, authentication flaws)
- Dependency vulnerabilities
- Secrets or credentials in source

For a security audit, use `/full-security-review`.

## Example output

```
## Code Review — feature/checkout-flow — 2026-04-06

### Summary
| Category       | Issues |
|----------------|--------|
| Readability    | 1      |
| Complexity     | 2      |
| Test gaps      | 3      |
| SOLID          | 1      |
| Consistency    | 0      |

### Findings

**[HIGH][COMPLEXITY] processOrder is too long**
- File: `src/services/orderService.ts:88`
- Description: Function has 62 lines and 9 branch points. Difficult to unit-test in isolation.
- Recommendation: Extract validation into `validateOrderInput()` and persistence into `persistOrder()`.

**[MED][TEST_GAP] applyDiscount has no test coverage**
- File: `src/utils/pricing.ts:14`
- Description: Exported function with no matching test file found.
- Recommendation: Add `src/utils/pricing.test.ts` covering happy path, zero discount, and negative discount edge cases.
```

## Installation

Add this repository as a marketplace in `~/.claude/settings.json`, then enable the plugin:

```json
{
  "enabledPlugins": {
    "code-review@claude-skills-marketplace": true
  }
}
```

Then type `/code-review` in a Claude Code session. If the built-in command takes precedence,
type `/code-review:code-review`.
