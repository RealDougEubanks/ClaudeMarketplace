# Onboarding

Generate a comprehensive developer onboarding guide for an unfamiliar codebase and write it to `docs/ONBOARDING.md`.

## Instructions

1. Use Read on `README.md`, then attempt to read whichever of the following exist: `package.json`, `pyproject.toml`, `go.mod`, `CLAUDE.md`, `docs/assumptions.md`.

2. Use Glob to map the top-level directory structure (`*`). For each top-level folder found, describe its purpose based on its name and contents (e.g., `src/` → application source, `scripts/` → automation scripts, `docs/` → project documentation).

3. Use Glob to find entry points matching: `index.*`, `main.*`, `server.*`, `app.*`, `cmd/**/*`. Read the primary entry point to understand how the application starts.

4. Use Read on any Makefile, `package.json` (scripts section), or `Taskfile.yml` to identify key commands: install, run, test, build, lint.

5. Use Glob to find `.env.example` or any env var documentation files. List all required environment variables with their descriptions.

6. Use Bash to count files by detected language type. Adapt the command to the language detected:
   - TypeScript/JavaScript: `find . -name "*.ts" -o -name "*.js" | grep -v node_modules | wc -l`
   - Python: `find . -name "*.py" | grep -v __pycache__ | wc -l`
   - Go: `find . -name "*.go" | wc -l`

7. Use Glob to check for `docs/agentRoster.md`. If it exists, read it and include the agent roster section in the guide.

8. Write the completed onboarding guide to `docs/ONBOARDING.md` using Write, following the output structure below.

## Output Structure

Write the following document to `docs/ONBOARDING.md`:

```markdown
# Developer Onboarding Guide — <Project Name>

## What This Project Does
<1-2 sentence summary from README>

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Language | ... |
| Framework | ... |
| Database | ... |
| CI/CD | ... |

## Directory Map
| Path | Purpose |
|------|---------|
| `src/` | ... |

## Getting Started
```bash
# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env
# Edit .env: fill in ...

# 3. Run locally
npm run dev
```

## Key Entry Points
- `src/index.ts:1` — Application bootstrap
- `src/routes/` — API route definitions

## Environment Variables
| Variable | Required | Description |
|----------|----------|-------------|
| DATABASE_URL | Yes | PostgreSQL connection string |

## Key Commands
| Command | What it does |
|---------|-------------|
| `npm run dev` | Start dev server with hot reload |
| `npm test` | Run test suite |

## Architecture Overview
<brief description of the main data/request flow>

## Agent Roster
<include only if docs/agentRoster.md exists>

## How to Contribute
1. Branch from `main` using `feature/` or `fix/` prefix
2. Open a PR — see git-workflow skill for details
3. PRs require at least one approval before merge
```

After writing the file, confirm to the user that `docs/ONBOARDING.md` has been created and summarize the key sections included.
