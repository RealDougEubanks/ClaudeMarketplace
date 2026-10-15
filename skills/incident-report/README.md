<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# incident-report

This skill writes an incident report from symptoms, log data, and timeline information. It uses templates that you can change, plus rules for severity, escalation, and SLA. The skill saves each report to `docs/incidents/`. It can also publish the report to Confluence or create Jira tickets for the action items.

## What It Does

When you run `/incident-report`, Claude does these steps:

1. Finds all templates in `templates/` and all rules in `rules/` at runtime. New files are found automatically.
2. Collects the incident details from you, or extracts them from `/log-correlation` output or pasted log lines.
3. Classifies the incident as SEV1 to SEV4 with `rules/severity.md`. You confirm or override the severity.
4. Suggests the template that matches the incident keywords. You can select a different template or give a path to a custom template.
5. Fills the template. Where data is missing, Claude writes a `[TODO: ...]` placeholder. Claude does not invent data.
6. Applies `rules/escalation.md` to fill the Notifications Sent section.
7. Applies `rules/sla.md` to mark each SLA target as `MET` or `BREACHED`.
8. Redacts credentials, tokens, session IDs, and victim PII as `[REDACTED]`.
9. Saves the report to `docs/incidents/INC-<YYYYMMDD>-<short-title>.md`.
10. Offers follow-up actions: publish to Confluence, create Jira tickets, or hand off to `/agent-based-development`.

## Usage

| Slash command | Argument | Result |
|---------------|----------|--------|
| `/incident-report` | none | Claude asks for the incident details one by one |
| `/incident-report [incident description]` | `incident description` | Claude starts from your description and asks only for missing details |

```
/incident-report
```

You can also paste log output or a `/log-correlation` summary. Claude extracts the fields and asks you to confirm them.

## Built-In Templates

| Template File | Incident Types | Best For |
|---------------|---------------|----------|
| `generic.md` | incident, outage, issue, problem | Any incident that does not match a specific type |
| `outage.md` | outage, down, unavailable, 5xx, degraded | Full or partial service unavailability |
| `security.md` | security, breach, vulnerability, unauthorized, intrusion, CVE | Security incidents and vulnerabilities |
| `performance.md` | slow, latency, timeout, performance, degradation, high CPU, memory | Performance regressions and degradations |
| `data-loss.md` | data loss, corruption, deleted, missing data, database | Data loss, corruption, or recovery |

## Severity Classification

| Level | Label | Criteria (summary of `rules/severity.md`) |
|-------|-------|----------|
| SEV1 | Critical / All-hands | Complete outage, confirmed data exfiltration, production data loss, revenue system down |
| SEV2 | High | Partial outage for more than 25% of users, critical feature down, actively exploited vulnerability, more than 5x baseline p95 latency for more than 15 minutes |
| SEV3 | Medium | Fewer than 25% of users affected, secondary feature down, unexploited vulnerability, non-production environment only |
| SEV4 | Low | Minor bug with a workaround, cosmetic issue, no data loss or security exposure |

If more than one level matches, Claude uses the highest. If you override the severity, the report records the original level, the new level, and your reason.

## Customization

### Add a Template

1. Create a `.md` file in `templates/`, for example `templates/database-failover.md`.
2. Add a frontmatter block between `---` delimiters at the top of the file.
3. In the frontmatter, set `id` (kebab-case), `name`, `incident_types` (keywords for selection), and `required_sections`.
4. Use `{{variable}}` placeholders in the template body.

Claude finds and offers the new template the next time you run the slash command. For the full variable list and template format, see `templates/README.md`.

### Change the Severity Rules

Edit `rules/severity.md`. The file uses plain-English IF/THEN rules that Claude interprets at runtime.

### Change the Escalation Contacts

Edit `rules/escalation.md`. Replace the placeholder channel names and contact roles with the values for your team.

### Change the SLA Targets

Edit `rules/sla.md`. Set the time-to-acknowledge, time-to-mitigate, and time-to-resolve targets for each severity level.

### Add a Rule File

Put a `.md` file in `rules/`. Claude finds it automatically and applies all rule files in alphabetical filename order. For the rule format, see `rules/README.md`.

## Output File Naming

Claude saves each report as:

```
docs/incidents/INC-<YYYYMMDD>-<kebab-case-short-title>.md
```

The title slug has a maximum of 40 characters. Example: `docs/incidents/INC-20260406-api-gateway-outage.md`

> **SECURITY:** A security incident report is marked CONFIDENTIAL. If you commit it to a shared repository, all people with access to the repository can read it. Save the report outside the repository or in a restricted location.

Before Claude saves a security-type report, it warns you and offers a different location.

## Integrations

### Confluence (Atlassian MCP)

If the Atlassian MCP tools are configured, Claude can publish the report as a new page in a Confluence space that you specify. If the tools are not available, Claude gives instructions for manual publishing.

### Jira (Atlassian MCP)

If the Atlassian MCP tools are configured, Claude can create one Jira ticket for each action item in the report. The ticket priority comes from the incident severity.

### Agent-Based Development

Claude can write a handoff artifact to `handoffs/plans/` for the `/agent-based-development` workflow. The artifact uses the incident ID as `taskId` and lists the action items as task assignments.

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "incident-report@claude-skills-marketplace": true
  }
}
```

Then run `/incident-report` in any Claude Code session.

## Related Skills

- `/log-correlation`: correlates and analyzes logs before you write an incident report
- `/agent-based-development`: multi-agent workflow to resolve and track action items
- `/full-security-review`: security audit to run before you file a security incident report
