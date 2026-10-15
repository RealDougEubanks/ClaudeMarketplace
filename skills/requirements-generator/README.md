<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# requirements-generator

This skill changes a feature description, user story, or project idea into a structured
requirements document. It saves the document to
`docs/requirements/<feature-name>-requirements.md`.

## Usage

| Slash command | Mode | Use |
|---|---|---|
| `/requirements-generator [feature description]` | Description mode (default) | You give a description, a user story, or a Jira or Confluence URL. If you give no description, Claude asks for one. |
| `/requirements-generator --interview` | Interview mode | Claude asks 7 questions, one at a time, and writes the requirements from your answers. |

```
/requirements-generator
/requirements-generator --interview
```

Use the skill at the start of a feature or project.

## What It Does

1. **Gets the input.** Accepts a pasted description, a Jira or Confluence URL, or a short spoken-style description.
2. **Reads the codebase.** Finds the tech stack and reads 3 to 5 representative files, so the requirements fit the code that exists.
3. **Reads existing requirements.** Reads `docs/requirements/` to prevent duplicates.
4. **Makes a feature name.** Changes the description into a kebab-case name, for example `user-authentication`.
5. **Writes the requirements document** with these sections:
   - Overview and stakeholders
   - Functional requirements (FR-001, FR-002, and so on). Each one is specific, testable, and states *what*, not *how*.
   - Non-functional requirements: performance, security, accessibility, and scalability
   - Gherkin acceptance criteria (Given/When/Then) for each key requirement
   - Edge cases and error scenarios
   - Out-of-scope items
   - Assumptions, with the effect if each one is wrong
   - Open questions, with the person who must answer each one
6. **Saves the document** to `docs/requirements/<feature-name>-requirements.md`.
7. **Offers Jira or Confluence integration.** If Atlassian MCP tools are available, Claude asks if you want a Confluence page or a Jira epic.
8. **Confirms completion.** Gives the file path and the number of requirements and scenarios.

In interview mode, the document starts with an **Interview Summary** section. It gives each
answer in 1 or 2 sentences.

> **Note:** The Atlassian MCP tools come from the MCP configuration of your session. They are
> not in the `allowed-tools` list of the skill. If no Atlassian MCP connection is available,
> the skill skips step 7.

## Interview Questions

| # | Question |
|---|---|
| 1 | Who is the primary user? |
| 2 | What problem does this solve? |
| 3 | What does success look like? |
| 4 | What are the constraints (technology, performance, compliance)? |
| 5 | What is explicitly out of scope? |
| 6 | What can go wrong? |
| 7 | Who else is affected? |

## Output Format

The skill writes one file for each feature:

```
docs/requirements/
  user-authentication-requirements.md
  payment-processing-requirements.md
  ...
```

Each document starts with `Version: 1.0` and `Status: Draft`, ready for stakeholder review.

## Gherkin Acceptance Criteria

Each key functional requirement gets a Gherkin scenario:

```gherkin
Scenario: Successful user login
  Given a registered user with email "user@example.com"
  And the user is on the login page
  When they submit valid credentials
  Then they are redirected to the dashboard
  And a session token is created with 24h expiry
```

You can use these scenarios directly as BDD test specifications.

## Use with the ABD Workflow

1. Run `/requirements-generator` to write `docs/requirements/<feature>-requirements.md`.
2. Give the FR-NNN items to the `agent-based-development` skill to split the work into tasks.
3. Track the open questions in Jira, in Confluence, or in `docs/ToDo.md`.
4. Give the acceptance criteria to the `test-writer` skill to make test scaffolding.

## When to Use

- Before you start a new feature or system.
- When a stakeholder request is vague and you need clear specifications.
- During sprint planning, so that the team agrees on the scope.
- To record what is out of scope for a feature.

## Installation

Enable the plugin through the Claude Code marketplace. Add this to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "requirements-generator@claude-skills-marketplace": true
  }
}
```

Then run `/requirements-generator` in a Claude Code session.
