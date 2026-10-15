<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# test-writer

This skill writes unit and integration tests for a file or function. It finds your test
framework, copies the style of your existing tests, and covers the happy path, edge cases,
invalid input, and error conditions.

## Usage

| Slash command | Arguments | Result |
|---|---|---|
| `/test-writer` | None | Claude asks for the target file or function. |
| `/test-writer <file-or-function>` | A file path or a function name | Claude writes tests for that target. |

```
/test-writer
/test-writer src/utils/parser.ts
/test-writer src/services/orderService.py
```

If you give a function name and the file is not clear, Claude asks for the file.

## What It Does

1. Gets the target file or function.
2. Reads the target file. Finds all exported or public functions, classes, and methods, and the dependencies to mock.
3. Finds the test framework from the config files and package manifests. If there is more than one framework, Claude asks which one to use.
4. Reads 1 or 2 existing test files to copy the block structure, assertion style, and mock setup.
5. Puts the test file in the same location pattern as the existing tests. If there are no tests, the test file goes next to the source file.
6. Writes these tests for each public function or method:
   - **Happy path**: valid inputs give the expected output.
   - **Edge cases**: empty values, zero, null, maximum values, and off-by-one boundaries.
   - **Invalid input**: wrong types, missing fields, and malformed data.
   - **Error conditions**: mocked dependency failures.
7. Creates the test file, or adds new tests to the end of an existing file.
8. Runs the tests and reports the results. If a test fails, Claude finds the cause and fixes the test before it stops.

Some targets have no exports, for example a CLI entry point. For these, the skill writes
integration-style tests. The tests run the module through its public interface or as a subprocess.

## Supported Frameworks

| Framework | Detection | Run command |
|---|---|---|
| Jest | `jest.config.*`, `"jest"` in `package.json` | `npm test -- <testfile>` or `node_modules/.bin/jest` |
| Vitest | `vitest.config.*`, `"vitest"` in devDependencies | `npm test -- <testfile>` or `vitest run` |
| Mocha | `.mocharc.*`, `"mocha"` in devDependencies | `npm test -- <testfile>` or `mocha` |
| pytest | `pytest.ini`, `[tool.pytest.ini_options]` in `pyproject.toml`, `conftest.py` | `python -m pytest <testfile> -v` |
| Go test | `go.mod` and existing `*_test.go` files | `go test ./... -run <TestName>` |
| PHPUnit | `phpunit.xml`, `phpunit.xml.dist`, `phpunit/phpunit` in `composer.json` | `vendor/bin/phpunit <testfile>` |
| RSpec | `.rspec`, `spec/spec_helper.rb`, `rspec` in `Gemfile` | `bundle exec rspec <testfile>` |
| JUnit | `junit` in `pom.xml` or `build.gradle` / `build.gradle.kts` | `mvn test -Dtest=<TestClass>` or `gradle test --tests <TestClass>` |
| xUnit / NUnit / MSTest | Package references in `*.csproj` | `dotnet test --filter <TestClass>` |

For JavaScript and TypeScript, the skill uses the test script of the project or the local
binary in `node_modules/.bin`. It does not use `npx` unless you approve it first, because
`npx` can download and run a package from the network.

## Example Output

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

## Limits

- The skill writes tests only. It does not change production code.
- If the test file exists, the skill adds tests with Edit. It does not overwrite existing tests.
- The skill writes deterministic tests. It mocks `Date.now()`, `Math.random()`, and other non-deterministic values before it uses them in assertions.

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "test-writer@claude-skills-marketplace": true
  }
}
```

Then run `/test-writer` in a Claude Code session.
