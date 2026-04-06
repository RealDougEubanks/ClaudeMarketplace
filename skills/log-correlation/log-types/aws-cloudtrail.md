# Log Type: AWS CloudTrail

## Metadata
- **id**: `aws-cloudtrail`
- **category**: `aws`
- **description**: AWS CloudTrail API event history — records all AWS API calls made in an account, including who, what, when, and from where

## File Paths
Not applicable — CloudTrail events are accessed via the AWS CLI or S3 (for full trail logs).

## AWS Source
- **Required permissions**: `cloudtrail:LookupEvents`
- **Data retention**: CloudTrail event history via `lookup-events` covers the last 90 days; full trail logs require an S3-backed trail

Fetch API events for a time window:
```bash
aws cloudtrail lookup-events \
  --start-time "START_ISO" \
  --end-time "END_ISO" \
  --output json 2>/dev/null
```

Fetch only error events (events with an `errorCode`):
```bash
aws cloudtrail lookup-events \
  --start-time "START_ISO" \
  --end-time "END_ISO" \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole \
  --output json 2>/dev/null
```

Filter for a specific IAM user or role:
```bash
aws cloudtrail lookup-events \
  --start-time "START_ISO" \
  --end-time "END_ISO" \
  --lookup-attributes AttributeKey=Username,AttributeValue="<username>" \
  --output json 2>/dev/null
```

Filter by resource (e.g., a specific S3 bucket, EC2 instance):
```bash
aws cloudtrail lookup-events \
  --start-time "START_ISO" \
  --end-time "END_ISO" \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue="<resource-name>" \
  --output json 2>/dev/null
```

Extract all events and format as TSV:
```bash
aws cloudtrail lookup-events \
  --start-time "START_ISO" \
  --end-time "END_ISO" \
  --output json | jq -r '.Events[] | [.EventTime, .EventName, .Username // "unknown", (.CloudTrailEvent | fromjson | .errorCode // "OK"), (.CloudTrailEvent | fromjson | .sourceIPAddress)] | @tsv'
```

Note: START_ISO and END_ISO are ISO-8601 format, e.g., `"2026-01-15T14:00:00Z"`.

## Time Extraction Command
CloudTrail `lookup-events` accepts `--start-time` and `--end-time` in ISO-8601 format. Substitute START_ISO and END_ISO with the user-provided time window.

The response JSON structure:
```json
{
  "Events": [
    {
      "EventId": "...",
      "EventName": "PutObject",
      "ReadOnly": "false",
      "EventTime": "2026-01-15T14:12:03Z",
      "EventSource": "s3.amazonaws.com",
      "Username": "my-app-role",
      "Resources": [...],
      "CloudTrailEvent": "{...}"  // JSON string of the full event
    }
  ]
}
```

The `CloudTrailEvent` field is a JSON string that must be parsed separately. Key fields within it:
- `errorCode` — present only if the API call failed
- `errorMessage` — human-readable error description
- `userIdentity` — IAM identity details (type, arn, accountId, sessionContext)
- `sourceIPAddress` — caller IP or AWS service name
- `requestParameters` — input to the API call
- `responseElements` — output from the API call (may be null for read-only events)

## Parsing Pattern
Two-stage parsing:

**Stage 1 — outer envelope:**
- timestamp: `EventTime` (ISO-8601)
- source: `aws-cloudtrail`
- level: `error` if `CloudTrailEvent` contains `errorCode`; otherwise `info`
- message: `EventName` + error code/message if present
- fields: `EventSource`, `Username`, `Resources`

**Stage 2 — CloudTrailEvent inner JSON:**
Parse the string with `jq . <<< "$cloudtrailEvent"` and extract:
- `errorCode`: maps to level → `error`; specific codes drive Known Correlations
- `errorMessage`: append to message
- `userIdentity.arn`: who made the call
- `sourceIPAddress`: caller IP
- `requestParameters`: relevant request fields

## Error Patterns
- `"errorCode"` present in CloudTrailEvent JSON — any failed API call
- `"AccessDenied"` — IAM authorization failure
- `"AccessDeniedException"` — SDK/CLI authorization failure variant
- `"ThrottlingException"` — API rate limit exceeded
- `"ValidationException"` — invalid API request parameters
- `"ConditionalCheckFailedException"` — DynamoDB condition check failed
- `"ResourceNotFoundException"` — referenced resource does not exist
- `"NoSuchBucket"` — S3 bucket not found
- `"InvalidSignatureException"` — request signature mismatch (clock skew or wrong key)
- `"ExpiredTokenException"` — temporary credentials expired

## Known Correlations
- `"AccessDenied"` + app-json 403/500 errors = application IAM role missing required permissions
- `"ThrottlingException"` on `DescribeInstances` + app-json latency spike = application polling AWS APIs too aggressively
- `"ExpiredTokenException"` + app-json auth errors = EC2 instance metadata service issue or short-lived credentials not refreshed
- `"AccessDenied"` on `AssumeRole` + aws-cloudwatch `"AccessDenied"` = cross-account role trust policy missing or incorrect
- `"InvalidSignatureException"` + os-linux clock skew messages = system clock out of sync causing AWS signature validation failures
