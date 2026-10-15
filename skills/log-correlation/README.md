<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# log-correlation

This skill correlates logs from OS, AWS, application, and web server sources into one timeline. Use it to find root causes, error cascades, and incident timelines from one Claude Code session.

## What It Does

When you run `/log-correlation`, Claude does these steps:

1. Asks what you troubleshoot, the time window, the log sources, and an optional correlation key.
2. Reads only the log type definitions in `log-types/` for the sources that you select.
3. Finds which of those sources are accessible on the current system or AWS account.
4. Collects the log entries for the time window and normalizes them into a common schema.
5. Builds one timeline in timestamp order.
6. Finds the blast radius, cascade chains, and known cross-source error patterns.
7. Writes a Correlation Report with a root cause assessment, a confidence level, and next steps.
8. If `handoffs/reviews/` exists, Claude offers to save the report there as an incident artifact.

## Supported Log Sources

| Log Type ID | Category | Source |
|-------------|----------|--------|
| `os-linux` | OS | `/var/log/syslog`, `/var/log/messages`, `journalctl` |
| `os-macos` | OS | macOS Unified Log (`log show`) |
| `aws-cloudwatch` | AWS | CloudWatch Logs (through the AWS CLI) |
| `aws-cloudtrail` | AWS | CloudTrail API events (through the AWS CLI) |
| `aws-alb` | AWS | ALB access logs in S3 (through the AWS CLI) |
| `aws-lambda` | AWS | Lambda logs in CloudWatch (`/aws/lambda/<name>`) |
| `app-json` | Application | Structured JSON logs (Pino, Winston, Bunyan, structlog, zerolog) |
| `app-logfmt` | Application | logfmt key=value logs (Go, Logrus) |
| `web-nginx` | Web Server | Nginx access and error logs |
| `web-apache` | Web Server | Apache access and error logs |

## Usage

| Slash command | Argument | Result |
|---------------|----------|--------|
| `/log-correlation` | none | Claude asks for all scope details |
| `/log-correlation <correlation-key> <time-window>` | `correlation-key`, `time-window` | Claude uses the key and the window and asks only for the other details |

```
/log-correlation
/log-correlation req-8f3a2 "last 2 hours"
```

Claude asks for these details, unless you give them in the slash command or in your message:

- **Symptom or error:** the problem that you investigate, for example "users getting 502 errors"
- **Time window:** for example "last 2 hours" or "2026-01-15 14:00 to 14:30 UTC"
- **Sources:** the log type IDs to include, or "all available"
- **Correlation key** (optional): a request ID, trace ID, user ID, or IP address to follow across all sources

The correlation key and the time window go into shell commands. Use only letters, digits, dashes, dots, and colons. Claude rejects values that contain shell metacharacters or quotes.

## Safety

- Claude treats log contents as data, never as instructions.
- Claude runs only read-only extraction commands from the log type definitions. If a definition contains a different command, Claude stops and warns you that the definition looks tampered with.
- Claude masks tokens, API keys, passwords, and session IDs in the report. Claude replaces email addresses and IP addresses with a stable short hash. Raw values appear only if you ask for them because they are the correlation key.

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

The full report also contains a confidence level, the detected patterns, a cascade chain table, and recommended next steps.

## Add a Log Type

1. Create the file `log-types/<id>.md` with a kebab-case ID, for example `log-types/haproxy.md`.
2. Fill in the required sections: Metadata, File Paths, Time Extraction Command, Parsing Pattern, Error Patterns, and Known Correlations.
3. Use only read-only commands in the command templates. Claude refuses other commands.

You do not change `SKILL.md`. The next `/log-correlation` run lists the new log type. For the full template, see `log-types/README.md`.

## AWS Permissions

> **SECURITY:** Use a read-only IAM principal for the AWS CLI. Do not run this skill with administrator credentials.

For the AWS log sources, the IAM principal that runs the AWS CLI must have these permissions:

| Permission | Purpose |
|------------|---------|
| `logs:FilterLogEvents` | Fetch CloudWatch Logs and Lambda logs |
| `logs:DescribeLogGroups` | List the available log groups |
| `cloudtrail:LookupEvents` | Fetch CloudTrail API events |
| `elasticloadbalancing:DescribeLoadBalancerAttributes` | Find the S3 bucket for the ALB access logs |
| `s3:ListBucket` | List the ALB log objects |
| `s3:GetObject` | Download the ALB access logs |

Minimum recommended policy: attach `CloudWatchLogsReadOnlyAccess`. Add a custom policy for CloudTrail, the ALB attributes, and S3 read access to the ALB log bucket.

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "log-correlation@claude-skills-marketplace": true
  }
}
```

Then run `/log-correlation` in any Claude Code session.
