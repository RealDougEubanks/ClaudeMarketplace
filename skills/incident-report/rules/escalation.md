# Rule: Escalation and Notification

## Trigger Conditions

Applied during Step 6 of `/incident-report` after severity has been confirmed. Used to determine who must be notified, through which channels, and within what timeframe.

## Rule Logic

Apply the notification requirements corresponding to the confirmed severity level. Record each notification requirement in the report's "Notifications Sent" section as a table row, marking each as `Sent` or `[TODO: confirm]`.

---

### SEV1 — Critical / All-hands

Notify immediately (within 5 minutes of declaring SEV1):

1. **Page the on-call engineer** via PagerDuty or OpsGenie — high-urgency alert.
2. **Notify the engineering lead** — direct message or phone call.
3. **Notify the CTO** — direct message or phone call.
4. **Open the incident Slack channel:** `#incident-live` — post the incident ID, severity, and one-line summary. Pin the message.
5. **Customer communication:** If the incident is user-facing, publish an initial status page update within 5 minutes. Send external communication to affected users within 15 minutes.
6. **Status page update:** Mark the affected service as "Investigating" within 5 minutes.
7. **Bridge / war room:** Open a video call or Slack huddle and post the link in `#incident-live`.

Ongoing during SEV1:
- Update the status page every 15–30 minutes.
- Post a brief update in `#incident-live` every 30 minutes even if no new information.

---

### SEV2 — High

Notify within 15 minutes of declaring SEV2:

1. **Page the on-call engineer** via PagerDuty or OpsGenie — standard urgency.
2. **Notify the engineering lead** — Slack direct message.
3. **Post in `#incidents` Slack channel** — include incident ID, severity, one-line summary, and link to the tracking ticket.
4. **Status page update:** If user-facing, mark as "Investigating" or "Degraded Performance" as appropriate.

No all-hands bridge required unless the incident degrades to SEV1.

---

### SEV3 — Medium

Notify within 1 hour of declaring SEV3:

1. **Create a Jira ticket** (or equivalent tracking ticket) — link it to the incident report.
2. **Post in `#engineering` Slack channel** — include incident ID, severity, and summary.
3. **No page required** unless the incident shows signs of degrading to SEV2 or higher.

---

### SEV4 — Low

Standard ticket workflow:

1. **Create a Jira ticket** (or equivalent tracking ticket) with priority Low.
2. **No immediate notification** required beyond standard ticket creation.
3. **Assign to the appropriate team** for resolution in the next sprint.

---

## Escalation Trigger

If the incident worsens during response, re-apply this rule at the new severity level and escalate immediately. Always err on the side of over-notifying — it is easier to stand down than to catch up on a missed escalation.

## Output

The rule produces a notification requirements list for the report's "Notifications Sent" section:

| Notification | Channel / Method | Required By | Sent At | Sent By |
|-------------|-----------------|-------------|---------|---------|
| [contact/channel] | [method] | [HH:MM from incident start] | [TODO] | [TODO] |

**CUSTOMIZE:** Replace `#incident-live`, `#incidents`, `#engineering`, "engineering lead", and "CTO" with your team's actual Slack channel names, contact roles, and tooling (PagerDuty service name, OpsGenie team, etc.). Add rows for any additional notification paths your team uses (e.g., legal counsel for SEV1 security incidents, customer success lead for large accounts).
