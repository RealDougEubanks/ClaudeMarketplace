# MVP Readiness Gate

Before marking any task complete, the active agent verifies:

1. **Stability:** All external calls (DB, API, file system) have error handling. No crashes on invalid input. Idempotent where applicable.
2. **Configuration:** App validates required env vars on startup. No hardcoded magic strings, URLs, or ports. No secrets in repo.
3. **Logging:** Logs include timestamps and severity (INFO, WARN, ERROR). No silent failures.
4. **Security (Golden Rules):** All user input validated/sanitized. Least privilege. Secure defaults.
5. **Documentation:** README explains clone-to-run in fewer than 3 steps. Usage examples exist.
6. **Implementation Integrity:** No placeholder code. camelCase naming. Complete README with stack, license, troubleshooting.
