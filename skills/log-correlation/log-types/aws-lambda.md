# Log Type: AWS Lambda Logs

## Metadata
- **id**: `aws-lambda`
- **category**: `aws`
- **description**: AWS Lambda function logs via CloudWatch Logs — includes invocation lifecycle events, application output, cold start data, and error details

## File Paths
Not applicable — Lambda logs are stored in CloudWatch Logs and accessed via the AWS CLI.

## AWS Source
- **Log group pattern**: `/aws/lambda/<function-name>`
- **Required permissions**: `logs:FilterLogEvents`, `logs:DescribeLogGroups`, `logs:DescribeLogStreams`

List Lambda log groups:
```bash
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/" \
  --query 'logGroups[*].logGroupName' \
  --output text 2>/dev/null
```

Fetch all events for a Lambda function in a time window:
```bash
aws logs filter-log-events \
  --log-group-name "/aws/lambda/<FUNCTION_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --output json 2>/dev/null
```

Fetch only error events (timeout, Runtime.ExitError, application errors):
```bash
aws logs filter-log-events \
  --log-group-name "/aws/lambda/<FUNCTION_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --filter-pattern "?\"Task timed out\" ?\"Runtime.ExitError\" ?\"errorMessage\" ?\"ERROR\"" \
  --output json 2>/dev/null
```

Fetch REPORT lines (performance data for every invocation):
```bash
aws logs filter-log-events \
  --log-group-name "/aws/lambda/<FUNCTION_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --filter-pattern "REPORT RequestId" \
  --output json 2>/dev/null
```

Fetch by correlation key (e.g., Request ID):
```bash
aws logs filter-log-events \
  --log-group-name "/aws/lambda/<FUNCTION_NAME>" \
  --start-time START_EPOCH_MS \
  --end-time END_EPOCH_MS \
  --filter-pattern '"CORRELATION_KEY"' \
  --output json 2>/dev/null
```

## Time Extraction Command
Lambda logs are time-filtered via CloudWatch `--start-time` and `--end-time` (epoch milliseconds). See the AWS Source section for commands. Substitute START_EPOCH_MS and END_EPOCH_MS with Unix timestamps multiplied by 1000.

The `message` field in each CloudWatch event contains the raw Lambda log line.

## Parsing Pattern
Lambda log lines come in several formats. Parse each line after extracting the CloudWatch `message` field:

**Lifecycle lines:**

START line:
```
START RequestId: <uuid> Version: <version>
```
Fields: `request_id`, `version`; level → `info`

END line:
```
END RequestId: <uuid>
```
Fields: `request_id`; level → `info`

REPORT line:
```
REPORT RequestId: <uuid>    Duration: 1234.56 ms    Billed Duration: 1235 ms    Memory Size: 512 MB    Max Memory Used: 234 MB    Init Duration: 456.78 ms
```
Fields: `request_id`, `duration_ms`, `billed_duration_ms`, `memory_size_mb`, `max_memory_used_mb`, `init_duration_ms` (cold start if present); level → `info`

Timeout line:
```
<timestamp> <request_id> Task timed out after <N.NN> seconds
```
Fields: `request_id`, `timeout_seconds`; level → `error`

Runtime error:
```json
{"errorMessage":"...", "errorType":"...", "stackTrace":["..."]}
```
Fields: `error_message`, `error_type`, `stack_trace`; level → `error`

**Application log lines** (structured JSON or plain text):
- If the message is valid JSON, parse per `app-json` patterns
- If the message is plain text, treat as: timestamp (from CloudWatch envelope), level (inferred), message (raw text)

Normalization:
- timestamp: CloudWatch `timestamp` (epoch ms) → ISO-8601 UTC
- source: `aws-lambda`
- level: see per-format rules above; default `info`
- message: formatted summary of the log line type
- fields: `request_id`, performance metrics, error details as applicable

**Cold start detection:**
A REPORT line containing `Init Duration` indicates a cold start invocation. Flag these entries separately.

## Error Patterns
- `"Task timed out"` — function exceeded its configured timeout
- `"Runtime.ExitError"` — Lambda runtime exited unexpectedly (process crash, OOM, unhandled exception)
- `"Runtime.ImportModuleError"` — Lambda unable to import the handler module (deployment/dependency issue)
- `"Runtime.HandlerNotFound"` — handler function not found in the module
- `"errorMessage"` — structured error response from the function
- `"ERROR"` — application error log (case-sensitive CloudWatch filter pattern)
- `"Unhandled"` — unhandled exception or promise rejection (Node.js)
- `"FATAL"` — fatal application error
- `"out of memory"` — process killed due to memory exhaustion (will appear as `Runtime.ExitError`)
- `"Init Duration"` — present in REPORT lines; flag if > 1000ms (slow cold start)
- `"Max Memory Used"` in REPORT near `Memory Size` — flag if Max Memory Used > 90% of Memory Size

## Known Correlations
- `"Task timed out"` + aws-alb `504` = Lambda timeout causing ALB gateway timeout
- `"Runtime.ExitError"` + os-linux OOM kill messages = Lambda process killed by OOM (check Max Memory Used near Memory Size)
- `"Runtime.ImportModuleError"` = deployment artifact issue; check recent deploys
- cold start spike (`Init Duration`) + aws-alb target_processing_time spike = cold start latency causing ALB timeout or slow responses
- `"errorMessage"` containing `"AccessDenied"` + aws-cloudtrail `"AccessDenied"` = Lambda execution role missing permissions
- repeated `"Task timed out"` + app-json database timeout = Lambda waiting on slow database query; check RDS metrics
