# Log Type: OS — Linux (syslog / journald)

## Metadata
- **id**: `os-linux`
- **category**: `os`
- **description**: Linux system logs via syslog/rsyslog (`/var/log/syslog`, `/var/log/messages`) and systemd journald (`journalctl`)

## File Paths
Where to find this log on disk (checked in order, first readable path wins):
- `/var/log/syslog`
- `/var/log/messages`
- `/var/log/system.log`

## Time Extraction Command

Prefer `journalctl` if systemd is present (more reliable time filtering):
```bash
journalctl --since "START" --until "END" --no-pager --output short-iso
```

Fallback for file-based syslog (assumes format: `Mon DD HH:MM:SS`):
```bash
awk 'NR==1{start=ARGV[2]; end=ARGV[3]} $0 ~ start, $0 ~ end' /var/log/syslog
```

Practical grep fallback for a specific hour window:
```bash
grep -E "^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) (0?[0-9]|[12][0-9]|3[01]) 14:" /var/log/syslog
```

## Parsing Pattern
Syslog format regex (RFC 3164):
```
^(?P<month>\w{3})\s+(?P<day>\d{1,2}) (?P<time>\d{2}:\d{2}:\d{2}) (?P<host>\S+) (?P<process>[^\[:\s]+)(?:\[(?P<pid>\d+)\])?: (?P<message>.+)$
```

journald short-iso format:
```
^(?P<timestamp>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4}) (?P<host>\S+) (?P<process>[^\[:\s]+)(?:\[(?P<pid>\d+)\])?: (?P<message>.+)$
```

Normalization:
- timestamp: reconstruct from `month day time` (assume current year) or use journald ISO timestamp directly
- level: inferred from message content (see Error Patterns below); default `info`
- message: `message` capture group
- fields: `host`, `process`, `pid`

## Error Patterns
- `"kernel:"` — kernel messages (may indicate hardware or driver issues)
- `"Out of memory"` — OOM condition
- `"oom-kill"` — OOM killer invoked a process kill
- `"segfault"` — segmentation fault (application crash)
- `"FAILED"` — systemd unit failure
- `"error"` — generic error keyword (case-insensitive)
- `"panic"` — kernel or application panic
- `"I/O error"` — disk I/O failure
- `"disk full"` — filesystem capacity exhausted
- `"No space left on device"` — write failure due to full disk
- `"authentication failure"` — PAM/auth failure
- `"Connection refused"` — network connection refused
- `"Cannot allocate memory"` — memory allocation failure

## Known Correlations
- `"Out of memory"` OOM kill + app-json `"connection refused"` = application process killed by OOM, causing downstream connection failures
- `"No space left on device"` + app-json write errors = disk full causing application write failures
- `"FAILED"` systemd unit + web-nginx 502 = application service crashed, nginx upstream unavailable
- `"segfault"` + aws-alb target unhealthy = application crash causing ALB health check failures
- `"disk full"` + aws-lambda `"Runtime.ExitError"` = Lambda unable to write temp files
