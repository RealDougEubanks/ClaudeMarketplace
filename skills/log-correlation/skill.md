# Skill: log-correlation

## Purpose

Correlate and troubleshoot logs across OS, AWS, application, and web server sources. Identify root causes, error patterns, and timelines across multiple log sources simultaneously.

Invoked via: `/log-correlation`

---

## How Extensibility Works

This skill loads log type definitions from `skills/log-correlation/log-types/` (or the installed plugin path). Each `.md` file defines one log type. To add support for a new log format, create a new file in that directory following the template in `log-types/README.md`.

When the skill runs, it first discovers all `.md` files in `log-types/` and reads them to build a registry of known log types, their file paths, extraction commands, parsing patterns, and error signatures. This means new log types are available immediately — no changes to `skill.md` required.

---

## Instructions

### Step 1 — Discover Installed Log Type Definitions

Use Glob to find all `.md` files in the `log-types/` directory relative to where this skill is installed (e.g., `skills/log-correlation/log-types/*.md` or `.claude/skills/log-correlation/log-types/*.md`). Read each file to load the log type registry. Parse these sections from each file:

- **id** and **category** from the Metadata section
- **File Paths** — the on-disk paths to check
- **AWS Source** — CLI command to fetch (if applicable)
- **Time Extraction Command** — Bash command template
- **Parsing Pattern** — regex or field map for normalization
- **Error Patterns** — grep patterns for filtering
- **Known Correlations** — cross-source patterns

Store these as an in-memory registry keyed by `id`.

### Step 2 — Ask the User for Scope

Prompt the user for the following information before proceeding:

1. **What are you troubleshooting?** (symptom, error message, or incident description)
2. **Time window** — e.g., "last 2 hours", "between 14:00 and 14:30 UTC on 2026-01-15"
3. **Log sources to include** — list sources by their log type id, or say "all available"
4. **Correlation key** (optional) — a request ID, trace ID, user ID, or IP address to use as a pivot across all sources

If the user has already provided any of this information in their invocation, use it without re-asking.

### Step 3 — Discover Available Logs

Based on the loaded log type registry, determine which sources are accessible in this environment:

- For each log type with **File Paths**, use Bash to check whether each path exists and is readable:
  ```bash
  [ -r /var/log/syslog ] && echo "readable" || echo "not accessible"
  ```
- For AWS log types, check if AWS CLI is configured:
  ```bash
  aws --version 2>/dev/null && aws sts get-caller-identity --query Account --output text 2>/dev/null
  ```
- Report a table of all log types: which are accessible, which are not, and why (file not found, AWS CLI missing, insufficient permissions).

Only proceed with sources the user has selected (or all accessible sources if "all available" was requested).

### Step 4 — Collect Log Data

For each accessible source in scope, use Bash to extract log entries for the specified time window.

Use the **Time Extraction Command** from each log type definition, substituting the user-provided time window. Apply the **Error Patterns** as grep filters when collecting data to limit volume:

```bash
# Example: nginx access log, filter for 5xx errors in window
awk '$4 >= "[15/Jan/2026:14:00:00" && $4 <= "[15/Jan/2026:14:30:00"' /var/log/nginx/access.log \
  | grep -E '" 5[0-9][0-9] '
```

For AWS sources, run the appropriate `aws` CLI command from the **AWS Source** section of the log type definition.

If a correlation key was provided, also run a targeted grep/filter for that key across every source.

Collect results per source. Note entry counts and actual time ranges found.

### Step 5 — Parse and Normalize

For each log entry collected, normalize it to a common schema using the **Parsing Pattern** defined in the log type:

```
{
  timestamp: ISO-8601 string (UTC),
  source: log type id,
  level: "trace" | "debug" | "info" | "warn" | "error" | "fatal" | "unknown",
  message: string,
  fields: { ...any additional extracted key-value pairs }
}
```

Level normalization:
- Map HTTP 5xx → "error", 4xx → "warn", 2xx/3xx → "info"
- Map syslog severity numbers to levels
- Map Pino numeric levels: 10→trace, 20→debug, 30→info, 40→warn, 50→error, 60→fatal
- Map string levels case-insensitively

If a timestamp cannot be parsed, flag the entry with `level: "unknown"` and include the raw line in `message`.

### Step 6 — Correlate Across Sources

With all normalized entries in hand:

1. **Build a unified timeline** sorted by `timestamp` ascending.

2. **Apply correlation key filter** — if the user provided a request ID, trace ID, user ID, or IP address, filter the unified timeline to entries containing that key in any field. Show both the filtered view and note how many entries were excluded.

3. **Identify blast radius** — for the first error-or-worse entry in the timeline, collect all entries from any source within a ±30-second window. These are services that were active at the time of the first failure.

4. **Flag cascading failures** — scan the timeline for the same error message (or error pattern) appearing in multiple sources in sequence within a short window (< 60 seconds). Mark these as "cascade chain".

5. **Check Known Correlations** — for each log type's **Known Correlations** section, test whether those patterns are present in the unified timeline (e.g., "502 from nginx" AND "connection refused" in app logs within 5 seconds of each other). Flag any matches.

### Step 7 — Root Cause Analysis

Analyze the unified timeline to identify the most likely root cause:

1. **First error rule** — the earliest error-level entry is the most likely root cause; subsequent errors in other services are likely downstream effects.

2. **Error spike detection** — calculate error rate per minute across the window. Flag any minute where error rate increases by more than 10x vs. the prior 5-minute baseline.

3. **Novel error detection** — compare error messages seen before the incident window vs. during. Flag errors that appear for the first time during the window.

4. **Known pattern matching** — if any **Known Correlations** rules matched in Step 6, use them to generate a specific root cause hypothesis (e.g., "502 from nginx + connection refused in app logs = app server down").

5. **Recovery detection** — identify the timestamp when error rate returns to baseline. Note the total incident duration.

Produce a concise root cause statement with supporting evidence (timestamps, entry counts, source names).

### Step 8 — Output the Correlation Report

Produce a structured report in this format:

```markdown
## Log Correlation Report — <symptom> — <time window>

### Sources Analyzed
| Source | Log Type | Entries Collected | Time Range |
|--------|----------|------------------|------------|
| /var/log/nginx/access.log | web-nginx | 1,247 | 14:00–14:30 |
| /var/log/nginx/error.log | web-nginx | 23 | 14:00–14:30 |
| /aws/lambda/my-function | aws-lambda | 4,102 | 14:00–14:30 |

### Unified Timeline (errors and warnings only)
| Time (UTC) | Source | Level | Message |
|------------|--------|-------|---------|
| 14:12:03.021 | app-json | ERROR | Database connection timeout after 5000ms |
| 14:12:03.847 | web-nginx | ERROR | 502 Bad Gateway — upstream /api |
| 14:12:04.103 | aws-alb | WARN | Target unhealthy: 3/5 targets failing health check |

*(Truncate to first 50 entries if timeline is very long; note total count)*

### Root Cause Assessment
**Most likely root cause:** <one sentence>
**Evidence:** <2-3 sentences citing timestamps, sources, and entry counts>
**Confidence:** High / Medium / Low — <brief rationale>

### Patterns Detected
- <N> occurrences of "<pattern>" between <time> and <time>
- Error rate spike: <before>% → <after>% at <time>
- Recovery detected at <time> (incident duration: <duration>)
- Known correlation matched: <rule description>

### Cascade Chain (if detected)
| Time | Source | Message |
|------|--------|---------|
| ...  | ...    | ...     |

### Recommended Next Steps
1. <Specific actionable step with reference to a config, metric, or service>
2. <Additional step>
3. <Additional step>
```

If no errors were found in the time window, say so explicitly and suggest widening the window or checking that log paths are correct.

### Step 9 — Check for Handoffs

If a `handoffs/reviews/` directory exists (in the current project), offer to write the correlation report as an incident artifact:

```
Would you like me to save this report to handoffs/reviews/incident-<timestamp>.md for team handoff?
```

If the user confirms, write the report there using the Write tool.

---

## Output Format

See Step 8 above for the full report template. Key principles:

- **Be specific**: include exact timestamps, entry counts, and source file paths — never vague summaries.
- **Cite evidence**: every root cause claim must reference specific log entries with timestamps.
- **Acknowledge uncertainty**: if data is insufficient, say so. Do not fabricate correlations.
- **Prioritize signal over noise**: filter to errors/warnings in the timeline; note info-level context only when directly relevant.
- **Be actionable**: next steps must be concrete — reference specific config files, metrics dashboards, or commands the user can run.
