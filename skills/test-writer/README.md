# Test Writer Skill

A test generation skill for Claude Code. Given a file or function, it auto-detects your test framework, matches your existing test style, and writes comprehensive tests covering happy paths, edge cases, invalid input, and error conditions.

## What it does

When you run `/test-writer`, Claude will:

1. Ask which file or function to write tests for
2. Read the target file and identify all public/exported functions and methods
3. Detect your test framework by scanning config files and `package.json`
4. Read 1–2 existing test files to match your describe block structure, assertion style, and mock patterns
5. Determine the correct test file location (co-located vs `tests/` directory) by following existing conventions
6. Generate tests covering:
   - **Happy path** — normal valid inputs produce expected output
   - **Edge cases** — empty, zero, null/undefined, boundary values
   - **Invalid input** — wrong types, missing fields, malformed data
   - **Error conditions** — mocked dependency failures and graceful error handling
   - **All public functions** — no exported surface left untested
7. Write (or append to) the test file, run the tests, and report results

## Supported frameworks

| Framework | Detection |
|-----------|-----------|
| Jest | `jest.config.*`, `"jest"` in `package.json` |
| Vitest | `vitest.config.*`, `"vitest"` in devDependencies |
| pytest | `pytest.ini`, `pyproject.toml` `[tool.pytest.ini_options]`, `conftest.py` |
| Go test | `go.mod` + existing `*_test.go` files |
| PHPUnit | `phpunit.xml`, `phpunit.xml.dist`, or `composer.json` dependency |

## How to invoke

```
/test-writer
```

Claude will prompt you for the target file. You can also specify it directly:

```
/test-writer src/utils/parser.ts
/test-writer src/services/orderService.py
```

## Example output

```
## Test Writer — src/utils/parser.ts — 2026-04-06

### Framework Detected
Jest (v29)

### Test File Written
`src/utils/parser.test.ts`

### Coverage
| Function / Method   | Tests Written                          |
|---------------------|----------------------------------------|
| parseCSV            | 4 (happy, empty input, malformed, error) |
| normalizeRow        | 3 (happy, null fields, extra columns)  |
| detectDelimiter     | 3 (comma, tab, unknown — defaults)     |

### Run Results
Tests: 10 passed, 0 failed, 10 total

### Notes
The mock for `fs.readFileSync` uses jest.mock — update if you switch to a streaming API.
```

## Notes

- This skill writes tests only — it does not modify production code.
- If a test file already exists, new tests are appended with Edit; existing tests are never overwritten.
- Tests are run after writing. If any fail, Claude diagnoses and fixes them before finishing.

## Installation

```bash
./scripts/install.sh skills/test-writer [your-project-dir]
```
