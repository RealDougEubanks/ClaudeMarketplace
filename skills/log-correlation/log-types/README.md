# How to Add a New Log Type

This directory contains log type definitions. Each `.md` file defines one log type that the `/log-correlation` skill knows how to discover, collect, parse, and correlate.

To add support for a new log format, create a new file in this directory following the template below. No changes to `skill.md` are needed — the skill discovers all `.md` files here at runtime.

---

## Log Type Definition Template

Copy the following template into a new file named `<id>.md` (kebab-case, e.g., `haproxy.md`, `postgres.md`):

```markdown
# Log Type: <Human-Readable Name>

## Metadata
- **id**: `<kebab-case-unique-id>` (e.g., `web-nginx`, `aws-lambda`)
- **category**: one of `os` | `aws` | `application` | `webserver` | `database` | `custom`
- **description**: One sentence describing what this log source is.

## File Paths
Where to find this log on disk (checked in order, first readable path wins):
- `/path/to/default/log.log`
- `/alternate/path/log.log`

If the log is only available via API (e.g., AWS), leave this section empty.

## AWS Source (if applicable)
Leave this section out entirely if this is not an AWS log type.

- **Log group pattern**: `/aws/service/*`
- **CLI command to fetch**:
  ```bash
  aws logs filter-log-events \
    --log-group-name "<group-name>" \
    --start-time <epoch-ms> \
    --end-time <epoch-ms> \
    --filter-pattern "ERROR"
  ```

## Time Extraction Command
Bash command to extract entries for a specific time window. Use `START` and `END` as placeholders for the time bounds — the skill will substitute them.

For file-based logs:
```bash
awk '$4 >= "[START" && $4 <= "[END"' /path/to/log
```

For journalctl:
```bash
journalctl --since "START" --until "END" --no-pager
```

For AWS CLI:
```bash
aws logs filter-log-events --log-group-name "<group>" \
  --start-time START_EPOCH_MS --end-time END_EPOCH_MS \
  --output json
```

## Parsing Pattern
Describe how to normalize a raw log line into the common schema:
`{ timestamp, source, level, message, fields: {} }`

Options:
- **Regex**: provide a named-capture-group regex, e.g.:
  ```
  ^(?P<ip>\S+) \S+ \S+ \[(?P<time>[^\]]+)\] "(?P<request>[^"]+)" (?P<status>\d+) (?P<bytes>\d+)
  ```
- **Field names**: for structured logs (JSON, logfmt), list the field names that map to each normalized field:
  - timestamp: `time` or `ts` or `timestamp`
  - level: `level` or `severity`
  - message: `msg` or `message`
  - fields: all remaining keys

## Error Patterns
Grep patterns (extended regex, one per bullet) that indicate errors or warnings in this log type. These are used to filter collected data and focus correlation on signals.

- `"<pattern1>"` — description of what it matches
- `"<pattern2>"` — description

## Known Correlations
Cross-source patterns this log type participates in. Each bullet describes a multi-source pattern that, when detected, suggests a specific root cause.

Format: `<this log type pattern> + <other log type pattern> = <root cause hypothesis>`

- `<pattern in this log>` + `<pattern in other-log-type-id>` = <root cause>
- `<another pattern>` + `<pattern>` = <root cause>
```

---

## Naming Conventions

| Convention | Rule |
|------------|------|
| File name | `<id>.md` in kebab-case (must match the `id` field in Metadata) |
| Category | Use existing categories where possible; add new ones only if none fit |
| id | Must be unique across all files in this directory |
| Description | One sentence, no period at the end preferred |

---

## Example: Minimal Log Type

```markdown
# Log Type: HAProxy

## Metadata
- **id**: `webserver-haproxy`
- **category**: `webserver`
- **description**: HAProxy TCP/HTTP load balancer access and error logs

## File Paths
- `/var/log/haproxy.log`

## Time Extraction Command
```bash
awk '/START/,/END/' /var/log/haproxy.log
```

## Parsing Pattern
Regex:
```
^(?P<month>\w+)\s+(?P<day>\d+) (?P<time>\S+) (?P<host>\S+) haproxy\[\d+\]: (?P<client>\S+) \[(?P<accept_date>[^\]]+)\] (?P<frontend>\S+) (?P<backend_server>\S+) (?P<timers>\S+) (?P<status_code>\d+)
```

## Error Patterns
- `" 5[0-9][0-9] "` — 5xx HTTP responses
- `"No server is available"` — all backends down
- `"Connection refused"` — backend connection failure

## Known Correlations
- `"No server is available"` + `os-linux` OOM kill = backend process crashed due to memory exhaustion
```
