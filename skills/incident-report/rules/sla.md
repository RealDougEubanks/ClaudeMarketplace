# Rule: SLA Definitions

## Trigger Conditions

Applied during Step 7 of `/incident-report` after severity has been confirmed and incident duration is known. Used to calculate whether SLA targets were met or breached.

## Rule Logic

Look up the SLA targets for the confirmed severity level. Compare each target against the actual times provided by the user. For each metric, output `MET` or `BREACHED`. If breached, calculate and state the overage (e.g., "BREACHED by 45 minutes").

If any actual time is not yet known (incident still ongoing), mark that metric as `[TODO: calculate after resolution]`.

---

### SEV1 — Critical / All-hands

| Metric | SLA Target |
|--------|-----------|
| Time to acknowledge | 5 minutes from incident start |
| Time to mitigate | 30 minutes from incident start |
| Time to resolve | 4 hours from incident start |
| Post-mortem due | 48 hours after resolution |

**Post-mortem required:** Yes — mandatory.

---

### SEV2 — High

| Metric | SLA Target |
|--------|-----------|
| Time to acknowledge | 15 minutes from incident start |
| Time to mitigate | 2 hours from incident start |
| Time to resolve | 24 hours from incident start |
| Post-mortem due | 5 business days after resolution |

**Post-mortem required:** Yes — mandatory.

---

### SEV3 — Medium

| Metric | SLA Target |
|--------|-----------|
| Time to acknowledge | 1 hour from incident start |
| Time to mitigate | 8 hours from incident start |
| Time to resolve | 1 week from incident start |
| Post-mortem due | Optional — recommended if root cause is unclear |

**Post-mortem required:** Optional.

---

### SEV4 — Low

| Metric | SLA Target |
|--------|-----------|
| Time to acknowledge | Next business day |
| Time to resolve | Next sprint |
| Post-mortem due | Not required |

**Post-mortem required:** No.

---

## SLA Breach Handling

IF any SLA target was missed:

1. Mark the metric as `BREACHED` in the SLA Status section of the report.
2. State the overage: "BREACHED — exceeded target by [duration]".
3. Add an action item to the Action Items table: "SLA breach review — document contributing factors to the SLA miss and recommend process changes."
4. Note that SLA breach data should be tracked in the team's reliability metrics dashboard.

## Post-Mortem Due Date Calculation

Calculate the post-mortem due date from the resolution timestamp:

- SEV1: `resolution_time + 48 hours`
- SEV2: `resolution_time + 5 business days` (exclude weekends and holidays)
- SEV3: Optional — if conducted, recommend scheduling within 2 weeks

If the incident is still ongoing, note: `[TODO: calculate post-mortem due date after resolution]`.

## Output

The rule produces an SLA Status section for the report:

```
## SLA Status

**Severity:** {{severity}}

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Time to acknowledge | [target] | [actual or TODO] | MET / BREACHED by [duration] |
| Time to mitigate | [target] | [actual or TODO] | MET / BREACHED by [duration] |
| Time to resolve | [target] | [actual or TODO] | MET / BREACHED by [duration] |

**Post-mortem due:** [calculated date or TODO]
```

**CUSTOMIZE:** Adjust the time targets in each severity section to match your team's documented SLAs and SLOs. If your team uses different metrics (e.g., MTTR, MTTD, MTTA as separate KPIs tracked in a dashboard), add notes here about where those metrics are recorded.
