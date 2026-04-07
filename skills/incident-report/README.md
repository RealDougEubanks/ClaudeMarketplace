# incident-report

Generate professional incident reports from symptoms, log data, and timeline information. Uses customizable templates and severity/escalation/SLA classification rules. Reports are saved to `docs/incidents/` and can optionally be published to Confluence or linked to Jira tickets.

## What It Does

When you invoke `/incident-report`, Claude:

1. Loads all templates from `templates/` and rules from `rules/` at runtime (auto-discovers new files).
2. Collects incident details from you — or extracts them from a prior `/log-correlation` output.
3. Classifies the incident as SEV1–SEV4 using `rules/severity.md` and asks you to confirm or override.
4. Suggests the best-matching template based on incident keywords; lets you choose from all available templates.
5. Fills the template, inserting `[TODO: ...]` placeholders for any missing data rather than fabricating content.
6. Applies escalation rules (`rules/escalation.md`) to populate the Notifications section.
7. Applies SLA rules (`rules/sla.md`) to calculate whether SLA targets were met or breached.
8. Saves the report to `docs/incidents/INC-<YYYYMMDD>-<short-title>.md`.
9. Offers to publish to Confluence, create Jira action items, or hand off to the `/agent-based-development` workflow.

## Invocation

```
/incident-report
```

Claude will walk you through gathering incident information interactively. You can also paste in log output or a `/log-correlation` summary and Claude will extract the fields automatically.

## Built-In Templates

| Template File | Incident Types | Best For |
|---------------|---------------|----------|
| `generic.md` | incident, outage, issue, problem | Any incident not matching a specific type |
| `outage.md` | outage, down, unavailable, 5xx, degraded | Full or partial service unavailability |
| `security.md` | security, breach, vulnerability, unauthorized, intrusion, CVE | Security incidents and vulnerabilities |
| `performance.md` | slow, latency, timeout, performance, degradation, high CPU, memory | Performance regressions and degradations |
| `data-loss.md` | data loss, corruption, deleted, missing data, database | Data loss, corruption, or recovery scenarios |

## Severity Classification

| Level | Label | Criteria |
|-------|-------|----------|
| SEV1 | Critical / All-hands | Complete outage, confirmed data breach, revenue system down |
| SEV2 | High | Partial outage >25% users, active exploit, severe performance degradation |
| SEV3 | Medium | <25% users affected, non-critical feature down, minor degradation |
| SEV4 | Low | Minor bug with workaround, cosmetic issue |

## Customization

### Adding a New Template

1. Create a new `.md` file in `templates/` (e.g., `templates/database-failover.md`).
2. Add a frontmatter block at the top (between `---` delimiters) with:
   - `id`: unique identifier (kebab-case)
   - `name`: human-readable name
   - `incident_types`: array of keywords for auto-selection
   - `required_sections`: array of section names that must be filled
3. Use `{{variable}}` placeholders in the template body.
4. The skill will discover and offer your template automatically on next invocation.

See `templates/README.md` for the full variable reference and template format.

### Customizing Severity Rules

Edit `rules/severity.md` to adjust the classification thresholds. The file uses plain-English IF/THEN rules that Claude interprets at runtime.

### Customizing Escalation Contacts

Edit `rules/escalation.md` to replace placeholder channel names and contact roles with your team's actual values.

### Customizing SLA Targets

Edit `rules/sla.md` to adjust time-to-acknowledge, mitigate, and resolve targets per severity level.

### Adding New Rule Files

Drop any `.md` file into `rules/`. It will be auto-discovered and applied. Use the rule format described in `rules/README.md`.

## Output File Naming

Reports are saved as:

```
docs/incidents/INC-<YYYYMMDD>-<kebab-case-short-title>.md
```

Example: `docs/incidents/INC-20260406-api-gateway-outage.md`

## Integrations

### Confluence (Atlassian MCP)

If Atlassian MCP tools are configured in your Claude Code environment, the skill can publish the completed report directly to a Confluence space you specify.

### Jira (Atlassian MCP)

If Atlassian MCP tools are configured, the skill can create one Jira ticket per action item extracted from the report, with severity-based priority.

### Agent-Based Development

The skill can generate a handoff artifact compatible with the `/agent-based-development` workflow, allowing action items to flow directly into the multi-agent development process.

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "incident-report@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/incident-report` in any Claude Code session.
## Related Skills

- `/log-correlation` — correlate and analyze logs before writing an incident report
- `/agent-based-development` — multi-agent workflow for resolving and tracking action items
- `/security-review` — standalone security audit to run before filing a security incident report
