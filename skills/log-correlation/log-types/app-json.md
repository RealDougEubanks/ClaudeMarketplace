# Log Type: Application — Structured JSON Logs

## Metadata
- **id**: `app-json`
- **category**: `application`
- **description**: Structured JSON application logs produced by modern logging libraries such as Pino, Winston, Bunyan, structlog, zerolog, and others

## File Paths
Common locations (checked in order, first readable path wins):
- `/var/log/app/app.log`
- `/var/log/app.log`
- `/opt/app/logs/app.log`
- `/home/app/logs/app.log`
- `./logs/app.log`
- `/tmp/app.log`

Detection: a file is a JSON log if the first non-empty line is valid JSON containing at least one of: `level`, `severity`, `message`, `msg`.

## Time Extraction Command
JSON logs typically use ISO-8601 or Unix epoch timestamps. Use `jq` if available for reliable parsing:

```bash
# Filter by ISO-8601 timestamp range using jq (handles time/ts/timestamp field variants)
jq -c 'select(
  (.time // .ts // .timestamp // "") >= "START_ISO" and
  (.time // .ts // .timestamp // "") <= "END_ISO"
)' /var/log/app/app.log 2>/dev/null
```

Fallback with grep (less precise, matches on timestamp string):
```bash
grep -E '"(time|ts|timestamp)":"2026-01-15T14:[01][0-9]' /var/log/app/app.log
```

Filter for errors only:
```bash
jq -c 'select(
  (.time // .ts // .timestamp // "") >= "START_ISO" and
  (.time // .ts // .timestamp // "") <= "END_ISO" and
  ((.level // .severity // 0) | if type == "number" then . >= 40 else ascii_downcase | test("warn|error|fatal|critical") end)
)' /var/log/app/app.log 2>/dev/null
```

Filter by correlation key (e.g., request ID or trace ID):
```bash
jq -c 'select(
  (.time // .ts // .timestamp // "") >= "START_ISO" and
  tostring | contains("CORRELATION_KEY")
)' /var/log/app/app.log 2>/dev/null
```

## Parsing Pattern
JSON logs vary in field names across libraries. Use this priority order to normalize:

**Timestamp field** (first present wins):
- `time`, `ts`, `timestamp`, `@timestamp`, `datetime`
- If numeric (Unix seconds < 1e10 or Unix ms >= 1e12), convert to ISO-8601 UTC

**Level field** (first present wins):
- String field: `level`, `severity`, `lvl`
  - Normalize case-insensitively: trace, debug, info, warn/warning→warn, error, fatal/critical→fatal
- Numeric field (Pino convention): `level`
  - 10→trace, 20→debug, 30→info, 40→warn, 50→error, 60→fatal

**Message field** (first present wins):
- `message`, `msg`, `text`, `body`, `event`

**Error/exception field** (if present, append to message or add to fields):
- `err`, `error`, `exception`, `stack`, `stackTrace`, `stack_trace`

**Correlation/tracing fields** (add to fields):
- `traceId`, `trace_id`, `requestId`, `request_id`, `correlationId`, `correlation_id`, `spanId`, `span_id`

**All remaining fields** → `fields: {}`

Normalization output:
```
{
  timestamp: "<ISO-8601 UTC>",
  source: "app-json",
  level: "trace|debug|info|warn|error|fatal",
  message: "<string>",
  fields: {
    traceId: "...",
    requestId: "...",
    ...
  }
}
```

## Error Patterns
- `"level":"error"` or `"level":50` — Pino/Winston error level
- `"level":"fatal"` or `"level":60` — fatal/critical error
- `"level":"warn"` or `"level":40` — warning level
- `"severity":"ERROR"` — Google Cloud / structlog error
- `"errorMessage"` — error message field present
- `"stack"` or `"stackTrace"` — stack trace indicates exception
- `"err"` object present — error object attached to log entry
- `"database".*"timeout"` — database operation timeout
- `"connection refused"` — downstream connection failure
- `"ECONNREFUSED"` — Node.js connection refused error code
- `"ETIMEDOUT"` — Node.js connection timeout error code
- `"ENOTFOUND"` — Node.js DNS resolution failure

## Known Correlations
- Database timeout errors + web-nginx 502 = database bottleneck causing application failures visible at the web layer
- `"ECONNREFUSED"` targeting a specific host:port + os-linux `"FAILED"` service = downstream service crashed
- Error rate spike + aws-alb 5xx spike = application errors propagating to load balancer response codes
- `"heap out of memory"` or `"JavaScript heap out of memory"` + os-linux OOM kill = Node.js process OOM
- Auth-related errors (`"Unauthorized"`, `"Forbidden"`, 401/403) + aws-cloudtrail `"AccessDenied"` = IAM or auth configuration issue
- `"connection pool exhausted"` or `"too many clients"` + aws-alb 502 = database connection pool saturated under load
