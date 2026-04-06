# Rule: Severity Classification

## Trigger Conditions

Applied during Step 3 of `/incident-report` after incident information has been gathered. Used to classify the incident as SEV1, SEV2, SEV3, or SEV4.

## Rule Logic

Evaluate the incident description against the criteria below. Apply the **highest matching severity**. When multiple criteria are met, use the most severe. If in doubt, escalate to the higher severity — downgrade after resolution if appropriate.

---

### SEV1 (Critical)

Classify as SEV1 if ANY of the following are true:

- Complete service outage: the primary service or product is unavailable for all or nearly all users.
- Security breach with confirmed data exfiltration: an attacker has confirmed access to and removal of sensitive data.
- Data loss affecting production data: records have been permanently lost or corrupted in a production database.
- Revenue-generating system is fully unavailable: checkout, payments, billing, or order processing is down.
- All users are affected: 100% or near-100% of active users cannot use the core product.

**Output label:** `SEV1 — Critical / All-hands`

---

### SEV2 (High)

Classify as SEV2 if ANY of the following are true (and SEV1 criteria are not met):

- Partial outage affecting more than 25% of active users.
- A critical feature is completely unavailable (e.g., user login, search, primary API).
- Performance degradation exceeds 5x the baseline p95 latency and has persisted for more than 15 minutes.
- A security vulnerability is confirmed and is actively being exploited in production.
- A specific geographic region or availability zone is fully unavailable.
- A significant third-party integration required for core functionality is down.

**Output label:** `SEV2 — High`

---

### SEV3 (Medium)

Classify as SEV3 if ANY of the following are true (and SEV1/SEV2 criteria are not met):

- Degraded experience for fewer than 25% of active users.
- A non-critical or secondary feature is completely unavailable (e.g., notifications, export, analytics dashboard).
- Performance degradation is less than 5x baseline and has persisted for less than 30 minutes.
- A security vulnerability has been discovered but is not yet confirmed to be exploited.
- A non-production environment (staging, QA) is affected but production is not.

**Output label:** `SEV3 — Medium`

---

### SEV4 (Low)

Classify as SEV4 if ALL of the following are true:

- A minor bug affects a small number of users (less than 1% or fewer than 10 users reported).
- A workaround exists and is available to affected users.
- The issue is cosmetic, non-functional, or affects an internal-only tool.
- There is no data loss, security exposure, or revenue impact.

**Output label:** `SEV4 — Low`

---

## Override Rule

If the user explicitly overrides the classification, record the override in the report metadata:

```
Severity override: User changed from [original] to [override]. Reason: [user-provided reason].
```

Always confirm the final classification with the user before proceeding.

## Output

The rule produces:
- A severity level: `SEV1`, `SEV2`, `SEV3`, or `SEV4`
- A severity label: the full string shown above (e.g., `SEV1 — Critical / All-hands`)
- A list of the specific criteria that triggered the classification (for transparency)

**CUSTOMIZE:** Adjust thresholds (e.g., the 25% user threshold for SEV2) to match your product's scale and your team's definitions.
