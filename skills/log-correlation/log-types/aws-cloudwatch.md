# Log Type: AWS CloudWatch Logs

## Metadata
- **id**: `aws-cloudwatch`
- **category**: `aws`
- **description**: Generic AWS CloudWatch Logs — any log group not covered by a more specific log type definition

## File Paths
Not applicable — CloudWatch Logs are accessed exclusively via the AWS CLI or SDK.

## AWS Source
- **Log group pattern**: configurable — user must provide the log group name or pattern
- **Required permissions**: `logs:FilterLogEvents`, `logs:DescribeLogGroups`

List available log groups to help the user choose:
```bash
aws logs describe-log-groups \
  --query 'logGroups[*].logGroupName' \
  --output text 2>/dev/null
```

Fetch log events for a time window (times as Unix epoch milliseconds):
```bash
aws logs filter-log-events \
  --log-group-name "<LOG_GROUP_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --filter-pattern "ERROR" \
  --output json 2>/dev/null
```

Fetch without a filter pattern (all events in window):
```bash
aws logs filter-log-events \
  --log-group-name "<LOG_GROUP_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --output json 2>/dev/null
```

Fetch with correlation key (e.g., request ID or trace ID):
```bash
aws logs filter-log-events \
  --log-group-name "<LOG_GROUP_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --filter-pattern '"CORRELATION_KEY"' \
  --output json 2>/dev/null
```

Convert human-readable time to epoch milliseconds (bash):
```bash
date -d "2026-01-15 14:00:00 UTC" +%s%3N   # Linux
date -j -f "%Y-%m-%d %H:%M:%S" "2026-01-15 14:00:00" +%s%3N  # macOS (append 000 for ms)
```

## Time Extraction Command
CloudWatch Logs API handles time filtering natively via `--start-time` and `--end-time` (epoch milliseconds). Use the `aws logs filter-log-events` command above with appropriate epoch values for START and END.

The response JSON structure:
```json
{
  "events": [
    {
      "timestamp": 1705323600000,
      "message": "...",
      "logStreamName": "..."
    }
  ]
}
```

Extract and format events:
```bash
aws logs filter-log-events \
  --log-group-name "<LOG_GROUP_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --output json | jq -r '.events[] | [(.timestamp/1000 | todate), .logStreamName, .message] | @tsv'
```

## Parsing Pattern
CloudWatch wraps the original log message in a JSON envelope:
- **timestamp**: CloudWatch `timestamp` field (Unix epoch ms) → convert to ISO-8601 UTC
- **source**: log group name
- **level**: inferred from message content (application-specific)
- **message**: CloudWatch `message` field (may itself be JSON or plain text)
- **fields**: `logStreamName` → stream context

If `message` is valid JSON, parse it and extract level/message from the inner document per the `app-json` log type patterns.

## Error Patterns
- `"ERROR"` — generic error keyword
- `"WARN"` — generic warning keyword
- `"Exception"` — exception stack trace
- `"Traceback"` — Python traceback
- `"panic"` — Go/application panic
- `"fatal"` — fatal log level
- `"timeout"` — operation timeout
- `"connection refused"` — network failure
- `"AccessDenied"` — IAM permission error
- `"ThrottlingException"` — AWS API throttling

## Known Correlations
- `"AccessDenied"` in CloudWatch + app-json 500 errors = application missing IAM permissions for a downstream AWS service
- `"ThrottlingException"` + app-json timeout errors = AWS API rate limiting causing cascading application failures
- CloudWatch error spike + aws-alb 502s = application errors causing ALB health check failures
- `"connection refused"` + os-linux `"FAILED"` service = downstream service crashed, application unable to connect
