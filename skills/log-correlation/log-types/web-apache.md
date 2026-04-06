# Log Type: Web Server — Apache HTTP Server

## Metadata
- **id**: `web-apache`
- **category**: `webserver`
- **description**: Apache HTTP Server access log (combined format) and error log

## File Paths
Access log (checked in order, first readable path wins):
- `/var/log/apache2/access.log`
- `/var/log/httpd/access_log`
- `/var/log/apache2/access_log`
- `/usr/local/var/log/httpd/access_log`
- `/opt/homebrew/var/log/httpd/access_log`

Error log (checked in order, first readable path wins):
- `/var/log/apache2/error.log`
- `/var/log/httpd/error_log`
- `/var/log/apache2/error_log`
- `/usr/local/var/log/httpd/error_log`
- `/opt/homebrew/var/log/httpd/error_log`

Note: Virtual host configurations may write to separate log files. Check `/etc/apache2/sites-enabled/` or `/etc/httpd/conf.d/` for non-default paths.

## Time Extraction Command

**Access log** — combined format, same structure as Nginx; timestamp in field 4 (`[$time_local]`):
```bash
# Filter access log for a time window
awk '$4 >= "[15/Jan/2026:14:00:00" && $4 <= "[15/Jan/2026:14:30:00"' /var/log/apache2/access.log
```

Filter for 5xx errors in time window:
```bash
awk '$4 >= "[15/Jan/2026:14:00:00" && $4 <= "[15/Jan/2026:14:30:00" && $9 ~ /^5/' /var/log/apache2/access.log
```

Filter for a specific client IP:
```bash
awk '$4 >= "[15/Jan/2026:14:00:00" && $4 <= "[15/Jan/2026:14:30:00" && $1 == "CLIENT_IP"' /var/log/apache2/access.log
```

**Error log** — Apache error log format varies by version. Apache 2.4+ format:
```
[DayOfWeek Mon DD HH:MM:SS.usec YYYY] [module:level] [pid N:tid N] message
```

Filter error log by time (approximate, using grep on date string):
```bash
grep "Jan 15" /var/log/apache2/error.log | \
  awk '{
    split($2, t, ":")
    hhmm = t[1] ":" t[2]
    if (hhmm >= "14:00" && hhmm <= "14:30") print
  }'
```

Filter error log for errors only:
```bash
grep -E "\[error\]|\[crit\]|\[alert\]|\[emerg\]" /var/log/apache2/error.log
```

## Parsing Pattern

**Access log — Apache combined format** (identical to Nginx combined format):
```
%h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-Agent}i"
```

Regex:
```
^(?P<remote_addr>\S+) (?P<ident>\S+) (?P<auth_user>\S+) \[(?P<time_local>[^\]]+)\] "(?P<request>[^"]*)" (?P<status>\d{3}) (?P<bytes>\S+) "(?P<referer>[^"]*)" "(?P<user_agent>[^"]*)"$
```

Access log normalization:
- timestamp: `time_local` → parse as `DD/Mon/YYYY:HH:MM:SS +ZZZZ` → ISO-8601 UTC
- source: `web-apache`
- level: `status` → 5xx=error, 4xx=warn, 3xx=info, 2xx=info
- message: `request` + status (e.g., `GET /index.php 500`)
- fields: `remote_addr`, `status`, `bytes`, `referer`, `user_agent`

**Error log — Apache 2.4+ format:**
```
[DayOfWeek Mon DD HH:MM:SS.usec YYYY] [module:level] [pid N:tid N] message
```

Example:
```
[Wed Jan 15 14:12:03.456789 2026] [proxy:error] [pid 1234:tid 140234] AH01114: HTTP: failed to make connection to backend: 10.0.0.5
```

Regex:
```
^\[(?P<weekday>\w+) (?P<month>\w+) (?P<day>\d+) (?P<time>\d{2}:\d{2}:\d{2}\.\d+) (?P<year>\d{4})\] \[(?P<module>[^:]+):(?P<level>\w+)\] \[pid (?P<pid>\d+)(?::tid (?P<tid>\d+))?\] (?:(?P<error_code>AH\d+): )?(?P<message>.+)$
```

Error log normalization:
- timestamp: reconstruct from `weekday month day time year` → ISO-8601 UTC
- source: `web-apache`
- level: `level` → emerg/alert/crit→fatal, error→error, warn→warn, notice/info→info, debug→debug
- message: `message` capture group (with `error_code` prefix if present)
- fields: `module`, `pid`, `tid`, `error_code`

**Apache error codes:** `AH` prefixed codes (e.g., `AH01114`, `AH00898`) provide more specific error context. Common ones:
- `AH00898`: Error reading from remote server
- `AH01114`: HTTP: failed to make connection to backend
- `AH01084`: Pass request body failed
- `AH00945`: Reqtimeout: read timeout
- `AH00526`: Premature end of script headers

## Error Patterns

**Access log:**
- `" 5[0-9][0-9] "` — 5xx HTTP response status codes
- `" 500 "` — Internal Server Error
- `" 502 "` — Bad Gateway (proxy/mod_proxy error)
- `" 503 "` — Service Unavailable
- `" 504 "` — Gateway Timeout

**Error log:**
- `"[error]"` — error-level Apache message
- `"[crit]"` — critical Apache message
- `"[alert]"` — alert-level Apache message
- `"[emerg]"` — emergency-level Apache message
- `"AH[0-9]+"` — Apache error code (any)
- `"AH01114"` — failed to connect to backend (mod_proxy)
- `"AH00898"` — error reading from remote server
- `"Premature end of script headers"` — CGI/PHP script error
- `"File does not exist"` — 404-generating missing file
- `"mod_fcgid".*"error"` — FastCGI error
- `"PHP Fatal error"` — PHP fatal error in error log
- `"connection refused"` — backend connection refused

## Known Correlations
- Access log 500 + error log `"Premature end of script headers"` = PHP or CGI script crashing
- Access log 502 + error log `"AH01114"` or `"connection refused"` = backend application process down
- Access log 503 + error log `"no workers available"` = worker process pool exhausted under load
- Access log 504 + error log `"AH00945"` (reqtimeout) = backend application too slow to respond
- Error log `"PHP Fatal error"` + app-json fatal level = PHP application crash correlating with application logs
- Access log 403 spike + aws-cloudtrail `"AccessDenied"` = coordinated access control failure across web and AWS layers
