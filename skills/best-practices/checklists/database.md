# Database / ORM Checks

- [ ] No database migrations — schema changes applied manually
- [ ] Migrations not versioned or stored in the repo
- [ ] Missing indexes on foreign keys
- [ ] Missing indexes on columns used in `WHERE`, `ORDER BY`, `GROUP BY`
- [ ] `SELECT *` queries (over-fetching)
- [ ] No soft-delete pattern for business-critical records
- [ ] Transactions not used for multi-step operations that must be atomic
- [ ] No connection pooling configuration
- [ ] Passwords or PII stored without hashing/encryption
