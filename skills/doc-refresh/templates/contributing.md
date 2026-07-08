<!--
doc: CONTRIBUTING
last-refreshed: YYYY-MM-DD
generated-by: doc-refresh skill
-->

# Contributing to <Project Name>

## Before You Start

1. Read `README.md` to understand what the project does.
2. Check open issues — avoid duplicate work.
3. For large changes, open an issue first to discuss the approach.

> **SECURITY:** Never commit secrets, API keys, tokens, or credentials.
> They are hard to revoke once pushed. See `SECURITY.md`.

## Workflow

1. Branch from `main`:

   ```bash
   git checkout main && git pull
   git checkout -b feature/short-description
   ```

2. Make your changes.
3. Run tests: `<test command>`
4. Ensure no linting errors: `<lint command>`
5. Open a PR with a clear title and description.

## PR Checklist

- [ ] Tests pass
- [ ] No new secrets or hardcoded credentials
- [ ] Docs updated if behavior changed
- [ ] At least 1 reviewer approved before merge

## Code Style

<Populate from .eslintrc / .prettierrc / pyproject.toml / golangci.yml — or state: "Run the linter">
