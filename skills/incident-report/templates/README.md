# Incident Report Templates

This directory contains the report templates used by the `/incident-report` skill. Templates are discovered automatically at runtime via Glob — any `.md` file placed here will be offered as a template option.

## Template Format

Every template is a markdown file with two parts: a frontmatter block and a template body.

### Frontmatter

The frontmatter block appears between `---` delimiters at the very top of the file. It uses YAML-like syntax and specifies:

```markdown
---
id: my-template
name: My Custom Template
incident_types: [keyword1, keyword2, keyword3]
required_sections: [summary, timeline, root_cause, action_items]
---
```

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier for this template (kebab-case). |
| `name` | Yes | Human-readable name shown in the template selection menu. |
| `incident_types` | Yes | Array of keywords. When the user's incident description contains any of these keywords, this template is suggested automatically. |
| `required_sections` | Yes | Array of section names that must be filled before the report is considered complete. Claude will warn if any of these are still `[TODO]` after filling. |

### Template Body

The template body is standard markdown. Use `{{variable}}` placeholders for dynamic content. Claude replaces these at fill time.

#### Available Variables

| Variable | Description |
|----------|-------------|
| `{{incident_title}}` | Short descriptive title of the incident. |
| `{{incident_id}}` | Generated ID in the format `INC-<YYYYMMDD>-<slug>`. |
| `{{date}}` | Date the report was generated (YYYY-MM-DD UTC). |
| `{{severity}}` | Severity level (e.g., `SEV1`). |
| `{{severity_label}}` | Full severity label (e.g., `SEV1 — Critical / All-hands`). |
| `{{start_time}}` | Incident start time (UTC). |
| `{{end_time}}` | Incident end time (UTC), or `Ongoing`. |
| `{{duration}}` | Duration from start to resolution, or `Ongoing`. |
| `{{status}}` | `Resolved` or `Ongoing`. |
| `{{summary}}` | Executive summary of what happened. |
| `{{user_impact}}` | Description of user impact (number of users, features affected). |
| `{{systems_affected}}` | Comma-separated list of affected services/systems. |
| `{{root_cause}}` | Root cause description, or `Under investigation`. |
| `{{timeline}}` | Formatted as markdown table rows: `| HH:MM UTC | event | who |`. |
| `{{action_items}}` | Formatted as markdown table rows: `| N | action | owner | due date | status |`. |
| `{{detection_method}}` | How the incident was detected (alert, user report, monitoring, etc.). |
| `{{responders}}` | Comma-separated list of people who responded. |
| `{{notifications_sent}}` | Populated from `rules/escalation.md` based on severity. |

#### Conditional Sections

Wrap optional content in section markers. Claude can include or exclude these blocks based on context:

```markdown
<!-- SECTION: customer-comms -->
## Customer Communication

[Content only included when user-facing impact was confirmed]

<!-- /SECTION -->
```

## Creating a Custom Template

1. Copy `generic.md` as a starting point.
2. Give it a new `id` and `name` in the frontmatter.
3. Add keywords to `incident_types` that match your incident scenario.
4. Add, remove, or rearrange sections as needed.
5. Save the file in this directory with a `.md` extension.

The skill will discover your template automatically on the next invocation.

## Built-In Templates

| File | ID | Best For |
|------|----|----------|
| `generic.md` | generic | Any incident not matching a specific type |
| `outage.md` | outage | Full or partial service unavailability |
| `security.md` | security | Security incidents and vulnerabilities |
| `performance.md` | performance | Performance regressions and degradations |
| `data-loss.md` | data-loss | Data loss, corruption, or recovery scenarios |
