<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# database-design

The database-design skill designs database schemas from domain requirements. It also audits
existing schemas for common problems.

## Usage

```
/database-design
/database-design --review [path]
```

| Slash command | Mode |
|---------------|------|
| `/database-design` | Design mode (default). Design a new schema. |
| `/database-design --review` | Review mode. Audit the existing schema in the repository. |
| `/database-design --review <path>` | Review mode. Audit only the files in this directory. |

## Design mode (default)

The skill does these steps:

1. Ask for the domain, the one-year data volume, the read/write ratio, and any existing schema.
2. Ask for compliance needs (PII, HIPAA, PCI).
3. Recommend one or more database types and give the reasons.
4. Model the entities and relationships, with full field definitions.
5. Normalize to third normal form (3NF). Record each denormalization decision in `docs/assumptions.md`.
6. Recommend indexes for each table.
7. Identify PII and compliance needs. Recommend encryption, row-level security, retention rules, and an audit log table where they apply.
8. Write migration files that keep backward compatibility.
9. Save the ERD to `docs/database/schema.md` and the migrations to `db/migrations/` or `migrations/`.

Each table gets `created_at` and `updated_at`. Business-critical tables also get
`deleted_at` for soft delete.

### Primary keys

The skill uses UUIDs for distributed systems and auto-increment keys for simple systems. For
UUIDs, it recommends UUIDv7 (RFC 9562). UUIDv7 keys are time-ordered, so inserts append to the
B-tree index. Random UUIDv4 keys fragment the index and make inserts slower on large tables.

A UUIDv7 key shows when the row was created. If that is sensitive, use UUIDv4.

## Review mode (`--review`)

The skill finds migration files, ORM model files, and schema definitions. Then it audits them
against this checklist:

| Area | Checks |
|------|--------|
| Normalization | Repeating groups, transitive dependencies, duplicate data |
| Indexes | Foreign key indexes, `WHERE` and `ORDER BY` columns, unique constraints, redundant indexes |
| Data integrity | Foreign key constraints, `NOT NULL`, `CHECK` constraints, timestamps, consistent soft delete |
| Security | PII encryption, password hashes, row-level security, audit logs |
| Migrations | Versioned files, backward compatibility, `CONCURRENTLY` or batches on large tables, rollbacks |
| Performance | N+1 risks, large text and blob fields, partitions for tables over 100M rows, connection pools |

The report grades each finding by severity (Critical, High, Medium, Low). Each finding has a
fix and, where it applies, migration SQL.

## Supported database types

| Type | Examples | Use it for |
|------|----------|-----------|
| Relational | PostgreSQL, MySQL, MariaDB, SQLite | Structured data, ACID transactions, complex queries |
| Document | MongoDB | Variable schema, nested data, content |
| Key-value | Redis, DynamoDB | Sessions, cache, leaderboards, feature flags |
| Time-series | TimescaleDB, InfluxDB | Metrics, IoT, audit logs, events |
| Search | Elasticsearch, Meilisearch | Full-text search, faceted filters |
| Graph | Neo4j | Highly connected data such as social networks |
| Vector | pgvector, Pinecone, Qdrant | Embedding similarity search, RAG pipelines |

PostgreSQL is the primary target for row-level security, `CREATE INDEX CONCURRENTLY`, and
partitions.

## Supported ORMs and schema formats

- Prisma (`schema.prisma`)
- ActiveRecord / Rails (`schema.rb`, `db/migrate/`)
- Django (`models.py`, `migrations/`)
- TypeORM (`*.entity.ts`, `ormconfig.*`, `data-source.ts`)
- Drizzle (`drizzle.config.*`, `drizzle/**/*.ts`)
- Raw SQL (`schema.sql`, numbered migration files)

## Output files

| File | Contents |
|------|----------|
| `docs/database/schema.md` | Mermaid ERD and table definitions |
| `db/migrations/` or `migrations/` | Forward and rollback migration files (SQL or ORM-specific) |

## Migration safety rules

The skill follows these rules in each migration that it writes:

- Add a column as nullable, fill the data, then add `NOT NULL`.
- Do not drop or rename a column without a deprecation period.
- Use `CREATE INDEX CONCURRENTLY` on large tables. This prevents table locks.
- Write a rollback migration for each forward migration.
- Split breaking changes into steps for zero-downtime deployment.

> **CAUTION:** Review each generated migration before you run it on a shared or production
> database. Test the rollback migration in a staging database first.

## Integration with other skills

| Slash command | Use it |
|---------------|--------|
| `/architecture-design` | After `/database-design`, to document the full system |
| `/full-security-review` | After the schema design, to find security vulnerabilities |
| `/api-design` | To design REST or GraphQL APIs on top of the schema |

## ERD format

The skill uses the [Mermaid](https://mermaid.js.org/) `erDiagram` syntax. GitHub, GitLab,
Notion, and most documentation tools render it.

## Installation

Add this repository as a marketplace in `~/.claude/settings.json`, then enable the plugin:

```json
{
  "enabledPlugins": {
    "database-design@claude-skills-marketplace": true
  }
}
```
