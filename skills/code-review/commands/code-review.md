---
name: code-review
description: Structured engineering code review covering readability, complexity, test gaps, SOLID principles, and API consistency. Complements security-review with general code quality.
---

# Code Review

Perform a structured engineering code review covering readability, complexity, test coverage gaps, SOLID principles, and API consistency.

## Instructions

This skill has two modes:
- **Full mode** (default): complete review covering readability, complexity, test gaps, SOLID principles, and API consistency. Use before PR submission.
- **Quick mode** (`/code-review --quick`): fast scan covering only complexity (functions > 20 lines) and obvious naming violations. Completes in under 60 seconds. Use during active development loops.

When invoked via `/code-review`:

1. **Determine scope.** If the user did not specify a scope, ask if they want to review:
   - The current branch diff (default): `git diff main...HEAD`
   - A specific file or directory
   - All source files in the repo

2. **Gather the diff or file list.**
   - Use Bash to run `git diff main...HEAD --name-only` to list changed files, then `git diff main...HEAD` for the full diff.
   - If there is no diff (clean branch or no changes), use Glob to discover all source files (e.g. `**/*.ts`, `**/*.py`, `**/*.go`, `**/*.js`).

**If quick mode (`/code-review --quick`)**, execute the following steps instead of the full review and then stop:

1. Get the diff or file list using the same approach as full mode steps 1–2 above.
2. Use Grep to find functions/methods longer than 20 lines: look for `function`/`def`/`func` declarations and count lines until the matching closing brace or dedent.
3. Use Grep for obvious naming violations:
   - Single-letter identifiers in function signatures (excluding `i`, `j`, `k`, `n`, `x`, `y`, `e`, `err`, `ctx`)
   - ALL_CAPS non-constant names
   - Common vague abbreviations used as top-level names: `tmp`, `val`, `obj`, `data`, `info`, `flag`
4. Output a compact report in this format:
   ```
   ## Quick Code Review — <scope>

   ### Complexity Issues (<count>)
   - src/auth.ts:42 — `handleUserLoginAndSessionCreation` is 47 lines. Consider splitting.
   - src/api.ts:108 — `processRequestAndBuildResponse` is 31 lines.

   ### Naming Issues (<count>)
   - src/utils.ts:15 — Parameter `d` in function `formatDate(d)` is unclear. Use `date`.

   ✓ No blockers. Run `/code-review` for a full analysis before PR submission.
   ```
5. Skip all SOLID analysis, test gap detection, and ABD artifact writing. Do not proceed to the full review steps below.

**If full mode (default)**, continue with the steps below:

1. **Read and evaluate each changed file** using Read. For each file, assess:

   - **Readability**: Are function and variable names descriptive and unambiguous? Are there magic numbers (use named constants instead)? Is the logic self-evident, or does it require inline comments that are missing?

   - **Complexity**: Flag any function longer than 25 lines. Count cyclomatic complexity by tallying branch points: `if`, `else if`, `else`, `switch` cases, `for`, `while`, `do`, `catch`, ternary operators (`?:`). If branch count > 5, recommend splitting the function.

   - **Test coverage gaps**: Identify every public function or exported method. Use Glob to search for a corresponding test file (`**/*.test.*`, `**/*.spec.*`, `**/*_test.*`). Flag any public surface with no apparent test coverage.

   - **SOLID violations**:
     - *Single Responsibility*: Does the class or module do more than one clearly distinct thing? If yes, suggest splitting.
     - *Open/Closed*: Is there a `switch` or `if-else` chain that dispatches on a type string/enum that could be replaced by polymorphism or a strategy pattern?
     - *DRY*: Are there duplicate logic blocks of 5 or more lines? Suggest extracting to a shared function.

   - **API consistency**: Do function signatures, return types, and error handling patterns match conventions used elsewhere in the codebase? Use Grep to spot-check similar functions if needed.

   - **Naming conventions**: Check `CLAUDE.md` or `docs/assumptions.md` if present for project naming rules. Flag any deviation (e.g. snake_case in a camelCase project).

2. **Write a review artifact (optional).** Check whether `handoffs/reviews/` exists. If it does, write a JSON file there using the ABD envelope schema:
   ```json
   {
     "agent": "code-review",
     "timestamp": "<ISO-8601>",
     "scope": "<branch or file list>",
     "findings": [ /* array of finding objects */ ]
   }
   ```

3. **Output a markdown report** with the structure below. Every finding must include a `file:line` citation where possible.

## Output Format

```
## Code Review — <branch or scope> — <date>

### Summary
| Category       | Issues |
|----------------|--------|
| Readability    | X      |
| Complexity     | X      |
| Test gaps      | X      |
| SOLID          | X      |
| Consistency    | X      |

### Findings

**[CATEGORY] Short title of the issue**
- File: `path/to/file.ts:42`
- Description: What the problem is and why it matters.
- Recommendation: Specific, actionable fix.
```

### Categories

Use one of: `READABILITY`, `COMPLEXITY`, `TEST_GAP`, `SOLID`, `CONSISTENCY`, `NAMING`.

### Severity

Prefix each finding title with its severity in brackets before the category:
- `[HIGH]` — likely to cause bugs or maintenance failures
- `[MED]` — degrades maintainability or testability
- `[LOW]` — style or minor improvement

Example: `**[MED][COMPLEXITY] processOrder is too long**`

### Notes

- This skill covers **engineering quality only**. It does NOT audit for security vulnerabilities — use `/security-review` for that.
- Keep findings actionable. Prefer two or three high-value findings over an exhaustive list of nitpicks.
- If no issues are found in a category, write "None found." in the summary row.
