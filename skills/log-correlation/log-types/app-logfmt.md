# Log Type: Application — logfmt (key=value)

## Metadata
- **id**: `app-logfmt`
- **category**: `application`
- **description**: logfmt key=value structured log format commonly used by Go applications, Logrus (default formatter), and other systems-oriented tools

## File Paths
Common locations (checked in order, first readable path wins):
- `/var/log/app/app.log`
- `/var/log/app.log`
- `/opt/app/logs/app.log`
- `/home/app/logs/app.log`
- `./logs/app.log`
- `/tmp/app.log`

Detection: a file is a logfmt log if the first non-empty line matches the pattern `\w+=\S+` and is NOT valid JSON. Logfmt and JSON logs may coexist in the same file if an app changes formatters — handle mixed files by detecting per-line.

## Time Extraction Command
logfmt logs use ISO-8601 or RFC 3339 timestamps in a `time=` or `ts=` field.

Filter by time window using grep on the timestamp field:
```bash
grep -E '^time="?2026-01-15T14:[01][0-9]' /var/log/app/app.log
```

More precise filtering using awk to compare timestamp strings:
```bash
awk '
  match($0, /time="?([^" ]+)"?/, a) {
    t = a[1]
    if (t >= "START_ISO" && t <= "END_ISO") print
  }
' /var/log/app/app.log
```

Filter for errors only (level=error or level=warn):
```bash
awk '
  match($0, /time="?([^" ]+)"?/, a) {
    t = a[1]
    if (t >= "START_ISO" && t <= "END_ISO" && /level=(error|warn)/) print
  }
' /var/log/app/app.log
```

Filter by correlation key:
```bash
awk '
  match($0, /time="?([^" ]+)"?/, a) {
    t = a[1]
    if (t >= "START_ISO" && t <= "END_ISO" && /CORRELATION_KEY/) print
  }
' /var/log/app/app.log
```

## Parsing Pattern
logfmt parsing regex for extracting all key=value pairs from a line:

```
(\w+)=(?:"([^"]*)"|(\S+))
```

This regex captures:
- Group 1: key name
- Group 2: value (if quoted, without quotes)
- Group 3: value (if unquoted)

Apply iteratively across the entire line to extract all fields.

**Timestamp field** (first present wins):
- `time`, `ts`, `timestamp`
- Values are typically RFC 3339 format: `2026-01-15T14:12:03.456Z` or `2026-01-15T14:12:03+00:00`

**Level field** (first present wins):
- `level`, `lvl`, `severity`
- Common values: `trace`, `debug`, `info`, `warn`, `warning` → warn, `error`, `fatal`, `panic` → fatal

**Message field** (first present wins):
- `msg`, `message`, `text`
- Values are often quoted if they contain spaces: `msg="something went wrong"`

**Error field** (if present):
- `err`, `error`
- Values: `err="context deadline exceeded"` or `error=nil`

**Tracing/correlation fields**:
- `trace_id`, `request_id`, `correlation_id`, `span_id`

**All remaining key=value pairs** → `fields: {}`

Normalization output:
```
{
  timestamp: "<ISO-8601 UTC>",
  source: "app-logfmt",
  level: "trace|debug|info|warn|error|fatal",
  message: "<string>",
  fields: {
    trace_id: "...",
    request_id: "...",
    caller: "...",
    ...
  }
}
```

Special cases:
- `err=<nil>` or `err=nil` — no error; do not treat as error entry
- `level=panic` → normalize to `fatal`
- `level=dpanic` (Zap development panic) → normalize to `error`

## Error Patterns
- `"level=error"` — error-level log entry
- `"level=warn"` — warning-level log entry
- `"level=fatal"` — fatal-level log entry
- `"level=panic"` — panic-level log entry (Go)
- `"err="` followed by non-nil value — error field present
- `"error="` followed by non-nil value — error field variant
- `"context deadline exceeded"` — Go context timeout
- `"connection refused"` — downstream connection failure
- `"i/o timeout"` — Go network I/O timeout
- `"unexpected EOF"` — connection dropped mid-stream
- `"no such host"` — DNS resolution failure
- `"certificate"` + `"expired"` — TLS certificate expiry

## Known Correlations
- `"context deadline exceeded"` + aws-alb `target_processing_time > 29s` = Go handler timed out waiting for downstream, causing ALB 504
- `"connection refused"` targeting database host + web-nginx 502 = database unavailable causing application failure
- `level=fatal` in Go app + os-linux `"FAILED"` systemd unit = application panicked and systemd marked unit failed
- `"no such host"` + aws-cloudtrail DNS-related events = DNS misconfiguration or Route 53 issue
- logfmt error spike + aws-alb 5xx spike = application errors propagating to load balancer
- `"certificate".*"expired"` + web-nginx `"SSL_CTX_set_default_verify_paths"` = TLS certificate expired on upstream connection
