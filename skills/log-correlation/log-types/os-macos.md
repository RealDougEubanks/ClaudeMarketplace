# Log Type: OS — macOS (Unified Log)

## Metadata
- **id**: `os-macos`
- **category**: `os`
- **description**: macOS Unified Logging system accessed via the `log` command-line tool

## File Paths
macOS Unified Log is not stored as plain text files. It is accessed exclusively via the `log` CLI tool. No file paths apply.

## Time Extraction Command

Fetch all entries in a time window (all log levels):
```bash
log show --start "START" --end "END" --info --debug 2>/dev/null
```

Fetch only fault and error entries (recommended for large windows):
```bash
log show --start "START" --end "END" \
  --predicate 'messageType == fault OR messageType == error' \
  2>/dev/null
```

Filter for a specific subsystem or process:
```bash
log show --start "START" --end "END" \
  --predicate 'subsystem == "com.example.myapp" AND (messageType == fault OR messageType == error)' \
  2>/dev/null
```

Filter for a keyword in error-level entries:
```bash
log show --start "START" --end "END" \
  --predicate 'eventMessage CONTAINS "error"' \
  2>/dev/null
```

Note: `START` and `END` must be in the format `YYYY-MM-DD HH:MM:SS`.

## Parsing Pattern
macOS `log show` default output format:
```
^(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+[+-]\d{4}) \S+ (?P<process>[^\[]+)\[(?P<pid>\d+)\](?: \((?P<library>[^)]+)\))?: \((?P<subsystem>[^)]*)\) \[(?P<type>\w+)\] (?P<message>.+)$
```

With `--style json` output (more reliable for parsing):
```bash
log show --start "START" --end "END" --style json \
  --predicate 'messageType == fault OR messageType == error'
```
JSON fields: `timestamp`, `messageType`, `processImagePath`, `subsystem`, `eventMessage`

Normalization:
- timestamp: `timestamp` field (ISO with offset)
- level: `messageType` → `fault`→fatal, `error`→error, `default`→info, `info`→info, `debug`→debug
- message: `eventMessage`
- fields: `processImagePath`, `subsystem`, `pid`

## Error Patterns
- `"fault"` — fault-level log entry (highest severity on macOS)
- `"error"` — error-level log entry
- `"kernel panic"` — kernel panic (usually in crash reports, not unified log)
- `"launchd"` — launchd service management messages
- `"failed to launch"` — process launch failure
- `"crashed"` — process crash notification
- `"watchdog"` — watchdog timeout (app hung)
- `"assertion failed"` — failed assertion (potential crash)
- `"connection refused"` — network connection refused
- `"disk full"` — storage capacity exceeded

## Known Correlations
- launchd `"failed to launch"` + app-json errors = application startup failure
- `"kernel panic"` = standalone root cause, no further correlation needed
- `"watchdog"` timeout + aws-lambda timeout = app hung waiting for downstream Lambda response
- `"disk full"` + app-json write errors = filesystem full causing application write failures
- repeated `"crashed"` + web-nginx 502 = application crashing under load, nginx upstream unavailable
