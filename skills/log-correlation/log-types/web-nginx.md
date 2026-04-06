# Log Type: Web Server — Nginx

## Metadata
- **id**: `web-nginx`
- **category**: `webserver`
- **description**: Nginx HTTP server access log (combined format) and error log

## File Paths
Access log (checked in order, first readable path wins):
- `/var/log/nginx/access.log`
- `/var/log/nginx/access_log`
- `/usr/local/var/log/nginx/access.log`
- `/opt/homebrew/var/log/nginx/access.log`

Error log (checked in order, first readable path wins):
- `/var/log/nginx/error.log`
- `/var/log/nginx/error_log`
- `/usr/local/var/log/nginx/error.log`
- `/opt/homebrew/var/log/nginx/error.log`

Note: Virtual host configurations may write to separate log files (e.g., `/var/log/nginx/<vhost>-access.log`). Check `/etc/nginx/sites-enabled/` or `/etc/nginx/conf.d/` for non-default paths.

## Time Extraction Command

**Access log** — combined format timestamp is in field 4 (`[$time_local]`):
```bash
# Filter access log for a time window (adapt date format to match log locale)
awk '$4 >= "[15/Jan/2026:14:00:00" && $4 <= "[15/Jan/2026:14:30:00"' /var/log/nginx/access.log
```

Filter access log for 5xx errors in time window:
```bash
awk '$4 >= "[15/Jan/2026:14:00:00" && $4 <= "[15/Jan/2026:14:30:00" && $9 ~ /^5/' /var/log/nginx/access.log
```

Filter access log for a specific IP:
```bash
awk '$4 >= "[15/Jan/2026:14:00:00" && $4 <= "[15/Jan/2026:14:30:00" && $1 == "CLIENT_IP"' /var/log/nginx/access.log
```

**Error log** — timestamp format is `YYYY/MM/DD HH:MM:SS`:
```bash
awk '$1 >= "2026/01/15" && $2 >= "14:00:00" && $1 <= "2026/01/15" && $2 <= "14:30:00"' /var/log/nginx/error.log
```

Grep for errors in error log only:
```bash
grep -E "\[error\]|\[crit\]|\[alert\]|\[emerg\]" /var/log/nginx/error.log | \
  awk '$1 >= "2026/01/15" && $2 >= "14:00:00" && $1 <= "2026/01/15" && $2 <= "14:30:00"'
```

## Parsing Pattern

**Access log — Nginx combined format:**
```
$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
```

Regex:
```
^(?P<remote_addr>\S+) \S+ (?P<remote_user>\S+) \[(?P<time_local>[^\]]+)\] "(?P<request>[^"]*)" (?P<status>\d{3}) (?P<body_bytes_sent>\d+) "(?P<http_referer>[^"]*)" "(?P<http_user_agent>[^"]*)"$
```

Access log normalization:
- timestamp: `time_local` → parse as `DD/Mon/YYYY:HH:MM:SS +ZZZZ` → ISO-8601 UTC
- source: `web-nginx`
- level: `status` → 5xx=error, 4xx=warn, 3xx=info, 2xx=info
- message: `request` + status (e.g., `GET /api/orders 502`)
- fields: `remote_addr`, `status`, `body_bytes_sent`, `http_referer`, `http_user_agent`

**Error log format:**
```
YYYY/MM/DD HH:MM:SS [level] PID#TID: *CID message
```

Regex:
```
^(?P<date>\d{4}/\d{2}/\d{2}) (?P<time>\d{2}:\d{2}:\d{2}) \[(?P<level>\w+)\] (?P<pid>\d+)#(?P<tid>\d+): (?:\*(?P<cid>\d+) )?(?P<message>.+)$
```

Error log normalization:
- timestamp: `date` + `time` → ISO-8601 UTC (note: no timezone in error log; assume server local time)
- source: `web-nginx`
- level: `level` → emerg/alert/crit→fatal, error→error, warn→warn, notice/info→info, debug→debug
- message: `message` capture group
- fields: `pid`, `tid`, `cid` (connection ID)

## Error Patterns

**Access log:**
- `" 5[0-9][0-9] "` — 5xx HTTP response status codes
- `" 502 "` — Bad Gateway (upstream returned invalid response or connection refused)
- `" 503 "` — Service Unavailable (no healthy upstreams)
- `" 504 "` — Gateway Timeout (upstream did not respond in time)
- `" 499 "` — Client Closed Request (client disconnected before nginx responded)

**Error log:**
- `"[error]"` — error-level nginx message
- `"[crit]"` — critical nginx message
- `"[alert]"` — alert-level nginx message
- `"[emerg]"` — emergency-level nginx message (nginx may be unable to start)
- `"upstream timed out"` — upstream connection or read timeout
- `"connect() failed"` — unable to connect to upstream
- `"no live upstreams"` — all upstream servers are down or failing health checks
- `"upstream prematurely closed connection"` — upstream closed connection before response was complete
- `"recv() failed"` — network read error
- `"SSL_do_handshake() failed"` — TLS handshake failure with upstream
- `"could not be resolved"` — upstream hostname DNS resolution failure
- `"worker process".*"exited"` — worker process crash

## Known Correlations
- Access log 502 + app-json `"connection refused"` or app-logfmt `"connection refused"` = application process down or not listening
- Access log 502 + os-linux `"FAILED"` systemd unit = application service crashed
- Access log 504 + app-json `"timeout"` or `"context deadline exceeded"` = application taking too long; check slow queries or downstream dependencies
- Error log `"upstream timed out"` + aws-alb `target_processing_time > 29s` = request chain timeout cascade
- Error log `"no live upstreams"` + aws-alb 503 = all application servers failing health checks
- Access log 499 spike = clients timing out or retrying; check upstream response times
- Error log `"could not be resolved"` + aws-cloudtrail DNS events = DNS failure for upstream hostname
