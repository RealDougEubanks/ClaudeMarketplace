# database-design

A Claude Code skill for designing database schemas from domain requirements and auditing existing schemas for common issues.

## Commands

- `/database-design` — Design a new database schema (design mode, default)
- `/database-design --review` — Audit an existing schema (review mode)

## Modes

### Design Mode (default)

Guides you through creating a production-ready database schema from scratch:

1. Gathers domain description, data volume estimates, read/write ratios, and compliance requirements
2. Recommends appropriate database type(s) with justification
3. Models entities and relationships with full field definitions
4. Produces a Mermaid ERD diagram saved to `docs/database/schema.md`
5. Recommends an index strategy for each table
6. Identifies PII and compliance requirements, recommending encryption and row-level security where needed
7. Generates backwards-compatible migration files to `db/migrations/` or `migrations/`

### Review Mode (`--review`)

Audits an existing schema against a comprehensive checklist:

- **Normalization**: repeating groups, transitive dependencies, duplicate data
- **Indexes**: missing FK indexes, missing query indexes, redundant indexes
- **Data integrity**: FK constraints, NOT NULL, CHECK constraints, soft delete consistency
- **Security**: PII encryption, password hashing, row-level security, audit logs
- **Migrations**: versioning, backwards compatibility, CONCURRENTLY for large tables
- **Performance**: N+1 risks, large blob handling, partition strategy

Produces a severity-graded report (Critical/High/Medium/Low) with specific fix recommendations and migration SQL.

## Supported Databases

- PostgreSQL (primary target — RLS, CONCURRENTLY, partitioning)
- MySQL / MariaDB
- SQLite (dev/embedded)
- MongoDB (document store guidance)
- Redis / DynamoDB (key-value guidance)
- TimescaleDB / InfluxDB (time-series guidance)

## Supported ORMs / Schema Formats

- Prisma (`schema.prisma`)
- ActiveRecord / Rails (`schema.rb`, `db/migrate/`)
- Django (`models.py`, `migrations/`)
- TypeORM / Drizzle (entity files)
- Raw SQL (`schema.sql`, numbered migration files)

## Output Files

| File | Contents |
|------|----------|
| `docs/database/schema.md` | Mermaid ERD + table definitions |
| `db/migrations/<timestamp>_<name>.sql` | Forward migration SQL |
| `db/migrations/<timestamp>_<name>_rollback.sql` | Rollback migration SQL |

## Migration Safety Rules

- Add columns as nullable first; populate data; then apply NOT NULL
- Never DROP or RENAME a column without a deprecation period
- Use `CREATE INDEX CONCURRENTLY` on large tables to avoid locking
- Every forward migration has a corresponding rollback migration
- Breaking changes require a multi-step deployment process

## Integration with Other Skills

- `/architecture-design` — use after `/database-design` to document the full system architecture
- `/security-review` — run after schema design to review for security vulnerabilities
- `/api-design` — design REST or GraphQL APIs on top of the schema

## ERD Format

This skill uses [Mermaid](https://mermaid.js.org/) `erDiagram` syntax, which renders in GitHub, GitLab, Notion, and most modern documentation tools.
