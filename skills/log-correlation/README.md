# log-correlation

Correlate and troubleshoot logs across OS, AWS, application, and web server sources in a single unified timeline. Identify root causes, error cascades, and incident timelines without switching between tools.

## What It Does

When you invoke `/log-correlation`, the skill:

1. Loads log type definitions from `log-types/` (extensible — drop in a new `.md` file to add support for any log format)
2. Asks what you are troubleshooting, the time window, and which sources to include
3. Discovers which log sources are accessible on the current system
4. Collects and normalizes log entries into a common schema
5. Builds a unified timeline sorted by timestamp
6. Identifies blast radius, cascade chains, and known cross-source error patterns
7. Produces a structured Correlation Report with root cause assessment and next steps

## Supported Log Sources

| Log Type ID | Category | Source |
|-------------|----------|--------|
| `os-linux` | OS | `/var/log/syslog`, `/var/log/messages`, `journalctl` |
| `os-macos` | OS | macOS Unified Log (`log show`) |
| `aws-cloudwatch` | AWS | CloudWatch Logs (via AWS CLI) |
| `aws-cloudtrail` | AWS | CloudTrail API events (via AWS CLI) |
| `aws-alb` | AWS | ALB access logs (S3-backed, via AWS CLI) |
| `aws-lambda` | AWS | Lambda logs via CloudWatch (`/aws/lambda/<name>`) |
| `app-json` | Application | Structured JSON logs (Pino, Winston, Bunyan, etc.) |
| `app-logfmt` | Application | logfmt key=value logs (Go/Logrus) |
| `web-nginx` | Web Server | Nginx access and error logs |
| `web-apache` | Web Server | Apache access and error logs |

## How to Invoke

```
/log-correlation
```

The skill will prompt you for:

- **Symptom or error** — what you are investigating (e.g., "users getting 502 errors", "lambda timeouts")
- **Time window** — e.g., "last 2 hours" or "2026-01-15 14:00 to 14:30 UTC"
- **Sources** — which log types to include, or "all available"
- **Correlation key** (optional) — a request ID, trace ID, user ID, or IP address to pivot on

You can provide these upfront to skip the prompts:

```
/log-correlation symptom="502 errors on /api/orders" window="2026-01-15 14:00-14:30 UTC" sources="web-nginx,app-json,aws-alb" correlation-key="req-abc123"
```

## Example Output

```markdown
## Log Correlation Report — 502 errors on /api/orders — 14:00–14:30 UTC

### Sources Analyzed
| Source | Log Type | Entries Collected | Time Range |
|--------|----------|------------------|------------|
| /var/log/nginx/access.log | web-nginx | 1,247 | 14:00–14:30 |
| /var/log/app/app.log | app-json | 892 | 14:00–14:30 |

### Unified Timeline
| Time (UTC) | Source | Level | Message |
|------------|--------|-------|---------|
| 14:12:03.021 | app-json | ERROR | Database connection timeout after 5000ms |
| 14:12:03.847 | web-nginx | ERROR | 502 Bad Gateway — upstream /api |

### Root Cause Assessment
**Most likely root cause:** Database connection pool exhausted at 14:12:03
**Evidence:** First error appears in app-json logs 826ms before nginx 502s.
```

## How to Add a New Log Type

See `log-types/README.md` for the full template. In short:

1. Create a new file: `log-types/<id>.md` (kebab-case, e.g., `log-types/haproxy.md`)
2. Fill in the required sections: Metadata, File Paths, Time Extraction Command, Parsing Pattern, Error Patterns, Known Correlations
3. Drop the file into `log-types/` — no changes to `skill.md` needed
4. The next invocation of `/log-correlation` will automatically discover and use the new log type

## AWS Permissions Required

For AWS log sources, the IAM principal running the AWS CLI must have:

| Permission | Purpose |
|------------|---------|
| `logs:FilterLogEvents` | Fetch CloudWatch Logs and Lambda logs |
| `logs:DescribeLogGroups` | List available log groups |
| `cloudtrail:LookupEvents` | Fetch CloudTrail API events |
| `s3:GetObject` | Download ALB access logs from S3 |
| `elasticloadbalancing:DescribeLoadBalancers` | Identify ALB log bucket |

Minimum recommended policy: attach `CloudWatchLogsReadOnlyAccess` and a custom policy for CloudTrail and S3 access to the ALB log bucket.

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "log-correlation@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/log-correlation` in any Claude Code session.
