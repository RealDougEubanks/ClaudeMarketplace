# Code Review Skill

A structured engineering code review for Claude Code. Evaluates changed or specified source files across five quality dimensions and produces a markdown report with file:line citations.

## What it does

When you run `/code-review`, Claude will:

1. Collect the diff for the current branch (`git diff main...HEAD`) or scan specified files
2. Read each changed file and evaluate it against five categories:
   - **Readability** — clear names, no magic numbers, self-evident logic
   - **Complexity** — functions over 25 lines or cyclomatic complexity over 5 branch points
   - **Test coverage gaps** — public functions with no corresponding test file
   - **SOLID violations** — Single Responsibility, Open/Closed, and DRY checks
   - **API consistency** — signatures, return types, and error handling match codebase patterns
3. Optionally write a JSON review artifact to `handoffs/reviews/` (if that directory exists)
4. Output a markdown summary table and detailed findings with severity labels

## What it does NOT cover

This skill covers **engineering code quality only**. It does not audit for:

- Security vulnerabilities (SQL injection, XSS, authentication flaws, etc.)
- Dependency vulnerabilities
- Secrets or credentials in source

For security audits, use `/security-review`.

## How to invoke

```
/code-review
```

Optionally specify scope:

```
/code-review src/services/orderService.ts
/code-review src/
```

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

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "code-review@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/code-review` in any Claude Code session.
