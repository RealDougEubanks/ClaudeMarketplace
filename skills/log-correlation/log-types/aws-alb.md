# Log Type: AWS ALB Access Logs

## Metadata
- **id**: `aws-alb`
- **category**: `aws`
- **description**: AWS Application Load Balancer access logs stored in S3 — records every request processed by the ALB including timing, status codes, and target information

## File Paths
Not applicable — ALB access logs are stored in S3 and accessed via the AWS CLI.

## AWS Source
- **Required permissions**: `s3:GetObject`, `s3:ListBucket`, `elasticloadbalancing:DescribeLoadBalancerAttributes`
- **Log location**: S3 bucket configured on the ALB (format: `s3://<bucket>/AWSLogs/<account-id>/elasticloadbalancing/<region>/<year>/<month>/<day>/`)

Identify the S3 bucket for a given ALB:
```bash
aws elbv2 describe-load-balancer-attributes \
  --load-balancer-arn "<ALB_ARN>" \
  --query 'Attributes[?Key==`access_logs.s3.bucket`].Value' \
  --output text 2>/dev/null
```

List available log files for a specific date:
```bash
aws s3 ls "s3://<BUCKET>/AWSLogs/<ACCOUNT_ID>/elasticloadbalancing/<REGION>/2026/01/15/" 2>/dev/null
```

Download and decompress log files for a time window (logs are gzipped):
```bash
aws s3 cp "s3://<BUCKET>/AWSLogs/<ACCOUNT_ID>/elasticloadbalancing/<REGION>/2026/01/15/" . \
  --recursive --exclude "*" --include "*.log.gz" 2>/dev/null
gunzip *.log.gz
```

Alternatively, stream and filter without downloading:
```bash
aws s3 cp "s3://<BUCKET>/<KEY>" - 2>/dev/null | gunzip | \
  awk '{print $2, $8, $10, $11, $13}' | \
  awk '$2 >= "14:00" && $2 <= "14:30"'
```

## Time Extraction Command
ALB log files are partitioned by date in S3. For a time window:

1. Download the relevant day's log files (see AWS Source above)
2. Filter by time using awk on field 2 (the `time` field in ISO-8601 format):

```bash
awk '$2 >= "START_ISO" && $2 <= "END_ISO"' *.log
```

Filter for errors only:
```bash
awk '$2 >= "START_ISO" && $2 <= "END_ISO" && ($8 ~ /^5/ || $8 == "-")' *.log
```

Where field numbers map to (1-indexed, space-delimited):
1. `type` — request type (http, https, h2, ws, wss, grpcs)
2. `time` — ISO-8601 timestamp of when the load balancer received the request
3. `elb` — ALB name
4. `client:port` — client IP and port
5. `target:port` — target IP and port (or `-` if no target was selected)
6. `request_processing_time` — time from receiving request to sending it to target (seconds, `-1` on error)
7. `target_processing_time` — time from sending request to target to receiving response (seconds, `-1` on error/timeout)
8. `response_processing_time` — time from receiving target response to sending response to client (seconds, `-1` on error)
9. `elb_status_code` — HTTP response code from ALB to client
10. `target_status_code` — HTTP response code from target to ALB (`-` if no target response)
11. `received_bytes` — bytes received from client
12. `sent_bytes` — bytes sent to client
13. `"request"` — quoted HTTP method, URL, and protocol
14. `"user_agent"` — quoted user agent string
15. `ssl_cipher` — SSL cipher (or `-`)
16. `ssl_protocol` — SSL protocol (or `-`)
17. `target_group_arn` — ARN of the target group
18. `"trace_id"` — X-Amzn-Trace-Id header value
19. `"domain_name"` — SNI domain name
20. `"chosen_cert_arn"` — certificate ARN
21. `matched_rule_priority` — rule priority (0 if default rule)
22. `request_creation_time` — time the load balancer received the request from the client
23. `"actions_executed"` — actions taken (forward, authenticate, etc.)
24. `"redirect_url"` — redirect target URL (or `-`)
25. `"lambda_error_reason"` — Lambda error reason (or `-` for non-Lambda targets)
26. `"target_port_list"` — space-delimited list of targets (multi-target)
27. `"target_status_code_list"` — status codes for each target
28. `"classification"` — HTTP desync classification
29. `"classification_reason"` — reason for desync classification

## Parsing Pattern
Space-delimited with some quoted fields. Parse with awk or a dedicated ALB log parser.

Normalization:
- timestamp: field 2 (`time`, ISO-8601)
- source: `aws-alb`
- level: `elb_status_code` (field 9) → 5xx=error, 4xx=warn, 2xx/3xx=info; `-1` fields=error
- message: `elb_status_code` + `target_status_code` + `request` (method + URL)
- fields:
  - `client`: field 4 (client IP:port)
  - `target`: field 5 (target IP:port)
  - `request_processing_time`: field 6
  - `target_processing_time`: field 7
  - `response_processing_time`: field 8
  - `elb_status_code`: field 9
  - `target_status_code`: field 10
  - `request`: field 13
  - `trace_id`: field 18

## Error Patterns
- `" 5[0-9][0-9] "` — 5xx elb_status_code (ALB error response)
- `" 4[0-9][0-9] "` — 4xx elb_status_code (client error)
- `" -1 "` — processing time of -1 (connection/timeout error)
- `" - "` in target_status_code position — no response from target (connection refused or timeout)
- `"target_status_code:-"` — target did not respond

## Known Correlations
- `target_processing_time > 29` + elb_status_code `504` = Lambda function or target exceeded 29-second ALB timeout
- elb_status_code `502` + target_status_code `-` = target refused connection (process down or port not listening)
- elb_status_code `503` = no healthy targets in the target group; check target health
- elb_status_code `504` + app-json `"timeout"` = application taking too long to respond; check for slow queries or external dependencies
- target_processing_time spike (> 5s) + aws-cloudwatch memory usage increase = application memory pressure causing slowness
- elb_status_code `502` + os-linux `"FAILED"` unit = application process crashed
