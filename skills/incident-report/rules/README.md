# Incident Classification Rules

This directory contains the classification rules used by the `/incident-report` skill. Rules are discovered automatically at runtime via Glob — any `.md` file placed here will be loaded and applied.

## How Rules Work

Each rule file defines a named rule using a structured markdown format that Claude interprets at runtime. Rules use plain-English IF/THEN logic rather than code, making them easy to read, customize, and extend without programming knowledge.

### Rule File Format

```markdown
# Rule: <rule-name>

## Trigger Conditions
[Describes when this rule applies — which step of the incident-report workflow invokes it]

## Rule Logic
[IF/THEN statements in plain English that Claude interprets and applies]

## Output
[What this rule produces — a severity label, an escalation list, an SLA value, etc.]
```

### How Rules Are Applied

1. All `.md` files in `rules/` are loaded at the start of `/incident-report`.
2. Rules are applied in filename-alphabetical order (e.g., `escalation.md` before `severity.md` before `sla.md`).
3. Later rules can override earlier ones. If two rules produce conflicting outputs, the last one applied wins.
4. Claude interprets the plain-English logic and applies it to the incident data gathered from the user.

## Built-In Rules

| File | Purpose |
|------|---------|
| `severity.md` | Classifies the incident as SEV1–SEV4 based on scope and impact |
| `escalation.md` | Determines who to notify based on severity |
| `sla.md` | Defines time-to-acknowledge, mitigate, and resolve targets per severity |

## Customizing Rules

### Editing Existing Rules

Open any rule file in this directory and modify the IF/THEN logic. Changes take effect on the next invocation of `/incident-report`.

Common customizations:
- **`severity.md`** — Adjust thresholds (e.g., change the "25% of users" threshold for SEV2 to match your scale).
- **`escalation.md`** — Replace placeholder channel names (`#incident-live`, `#incidents`) with your team's actual Slack channels, PagerDuty service names, or OpsGenie team names.
- **`sla.md`** — Adjust time targets to match your team's SLAs and SLOs.

### Adding New Rules

1. Create a new `.md` file in this directory using the rule format above.
2. Give it a descriptive filename (e.g., `regional-escalation.md`, `gdpr-breach.md`).
3. Write the trigger conditions and IF/THEN logic in plain English.
4. The rule will be auto-discovered and applied on the next invocation.

**Example — Custom rule for a specific team:**

```markdown
# Rule: on-call-override

## Trigger Conditions
Applied after severity classification, before escalation notifications are determined.

## Rule Logic
IF the affected system is "payments" or "billing":
  THEN add the Payments Team lead to all notification lists regardless of severity.

IF the affected system is "authentication" or "identity":
  THEN treat as one severity level higher than classified for escalation purposes only.

## Output
Modified escalation contact list and/or severity override for escalation routing.
```
