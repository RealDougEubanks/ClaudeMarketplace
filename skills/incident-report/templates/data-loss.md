---
id: data-loss
name: Data Loss / Corruption
incident_types: [data loss, corruption, deleted, missing data, database]
required_sections: [summary, data_scope, recovery_options, data_integrity_verification, action_items]
---

# Data Loss / Corruption Incident Report: {{incident_title}}

**Incident ID:** {{incident_id}}
**Date:** {{date}}
**Severity:** {{severity}} — {{severity_label}}
**Status:** {{status}}
**Duration:** {{duration}}

> **SENSITIVE** — This report documents data loss or corruption. If PII was involved, regulatory notification deadlines may apply. See the Regulatory Notification section.

---

## Executive Summary

{{summary}}

**User Impact:** {{user_impact}}
**Systems Affected:** {{systems_affected}}

---

## Data Scope

**What data was lost or corrupted:**

[TODO: Describe the affected data as specifically as possible. Include table names, S3 prefixes, file paths, or other identifiers.]

| Data Set | Type | Estimated Record Count | Date Range | PII Involved? |
|----------|------|----------------------|------------|--------------|
| [TODO] | [TODO: table / file / object] | [TODO: e.g., ~50,000 rows] | [TODO: YYYY-MM-DD to YYYY-MM-DD] | [TODO: Yes / No] |

**Total estimated data affected:** [TODO: e.g., 2.3 GB, 50,000 records]
**Is the data loss confirmed complete, or is scope still being assessed?** [TODO]

**How was the loss or corruption discovered?**
[TODO: e.g., user report, monitoring alert, data integrity check, scheduled validation job]

---

## Recovery Options

[TODO: Describe all available recovery paths, their completeness, and estimated data loss (RPO) for each.]

### Backups Available

| Backup | Type | Timestamp | Estimated Data Loss (RPO) | Recovery Time Estimate (RTO) |
|--------|------|-----------|--------------------------|------------------------------|
| [TODO] | [TODO: full / incremental / snapshot] | [TODO] | [TODO: e.g., 24 hours of data] | [TODO: e.g., 4 hours] |

### Point-in-Time Recovery

**PITR available:** [TODO: Yes / No]
**Recovery window:** [TODO: e.g., up to 35 days]
**Target recovery point:** [TODO: e.g., 2026-04-05T14:00:00Z — last known good state]

### Replayable Events

**Event log / change data capture available:** [TODO: Yes / No]
**Events replayable from:** [TODO: timestamp]
**Estimated completeness:** [TODO: e.g., 100% / partial — explain gaps]

### Selected Recovery Strategy

[TODO: Describe which recovery option was selected and why. Document the trade-offs — e.g., chose backup restore over PITR due to faster RTO despite greater data loss.]

**Actual RPO achieved:** [TODO: how much data was ultimately lost after recovery]
**Actual RTO achieved:** [TODO: how long recovery took]

---

## Timeline

| Time (UTC) | Event | Who |
|------------|-------|-----|
| {{timeline}} | | |

---

## Root Cause

{{root_cause}}

---

## Detection

**Detected by:** {{detection_method}}
**Time to detect:** [TODO: time from data loss event to detection]
**Time to begin recovery:** [TODO: time from detection to start of recovery process]
**Time to full recovery:** [TODO: time from detection to confirmed data restoration]

---

## Response

**Responders:** {{responders}}

### Actions Taken

| Time (UTC) | Action | Who |
|------------|--------|-----|
| {{timeline}} | | |

---

## Data Integrity Verification

[TODO: Describe how the team confirmed that recovery was complete and the restored data is correct and consistent.]

**Verification method:** [TODO: e.g., row count comparison, checksum validation, application-level smoke tests, manual spot checks]

| Check | Expected | Actual | Pass? |
|-------|----------|--------|-------|
| [TODO: e.g., total row count in orders table] | [TODO] | [TODO] | [TODO: Yes / No] |
| [TODO: e.g., referential integrity check] | [TODO] | [TODO] | [TODO: Yes / No] |

**Verification confirmed by:** [TODO: name / role]
**Verification completed at:** [TODO: timestamp UTC]

---

## Regulatory Notification

**PII involved:** [TODO: Yes / No]
**If yes — estimated number of individuals affected:** [TODO]
**GDPR notification required:** [TODO: Yes / No — 72-hour window from discovery if PII of EU residents involved]
**HIPAA notification required:** [TODO: Yes / No]
**State breach notification required:** [TODO: Yes / No — specify state laws applicable]
**Cyber insurance notification required:** [TODO: Yes / No]

**Notification deadlines:**
- [TODO: list applicable deadlines and dates]

---

## SLA Status

[TODO: populated from rules/sla.md based on severity and duration]

---

## Notifications Sent

[TODO: populated from rules/escalation.md based on severity]

---

## Action Items

| # | Action | Owner | Due Date | Status |
|---|--------|-------|----------|--------|
| {{action_items}} | | | | |

---

## Lessons Learned

### What went well

[TODO: fill after post-mortem]

### What could be improved

[TODO: fill after post-mortem]

### Data protection improvements to make

[TODO: List specific improvements — e.g., reduce backup interval, enable PITR on additional databases, add data integrity validation jobs, implement soft-delete pattern, add deletion confirmation gates.]

### Follow-up work

[TODO: link to Jira tickets created]

---

*Report generated by `/incident-report` skill — Claude Code Skills Marketplace*
