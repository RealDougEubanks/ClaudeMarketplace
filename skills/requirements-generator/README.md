# Requirements Generator Skill

Converts a feature description, user story, or project idea into a structured requirements document and saves it to `docs/requirements/<feature-name>-requirements.md`.

## Usage

```
/requirements-generator
```

Invoke this skill at the start of any feature or project. Claude will prompt you for a description if none is provided.

## What It Does

1. **Gathers input** — accepts a pasted description, Jira/Confluence URL, or conversational description.
2. **Reads the existing codebase** — detects the tech stack and conventions so requirements fit what already exists.
3. **Checks for existing requirements** — reads `docs/requirements/` to avoid duplication.
4. **Generates a full requirements document** covering:
   - Overview and stakeholders
   - Functional requirements (FR-001, FR-002, ...) — specific, testable, implementation-agnostic
   - Non-functional requirements (performance, security, accessibility, scalability)
   - Gherkin acceptance criteria (Given/When/Then) for each key requirement
   - Edge cases and error scenarios
   - Out-of-scope items to prevent scope creep
   - Assumptions made during generation
   - Open questions requiring stakeholder input
5. **Writes the document** to `docs/requirements/<feature-name>-requirements.md`.
6. **Offers Jira/Confluence integration** if Atlassian MCP tools are available in the session.

## Output Format

Documents follow this structure:

```
docs/requirements/
  user-authentication-requirements.md
  payment-processing-requirements.md
  ...
```

Each document is versioned (`Version: 1.0`, `Status: Draft`) and ready for stakeholder review.

## Gherkin Acceptance Criteria

Each key functional requirement gets a corresponding Gherkin scenario:

```gherkin
Scenario: Successful user login
  Given a registered user with email "user@example.com"
  And the user is on the login page
  When they submit valid credentials
  Then they are redirected to the dashboard
  And a session token is created with 24h expiry
```

These scenarios are written to be directly usable as BDD test specifications.

## Integration with ABD Planning Workflow

The requirements-generator skill fits naturally into the Agent-Based Development (ABD) workflow:

1. Run `/requirements-generator` to produce `docs/requirements/<feature>-requirements.md`.
2. Use the generated FR-NNN items as input to the `agent-based-development` skill for task decomposition.
3. Track open questions through your Jira/Confluence integration or `docs/ToDo.md`.
4. Reference acceptance criteria in `test-writer` skill to generate test scaffolding.

## When to Use

- Before starting any new feature or system
- When refining a vague stakeholder request into implementable specifications
- During sprint planning to ensure shared understanding
- To document the scope boundary for a feature (what is explicitly out of scope)

## Installation

Enable via the Claude Code marketplace. Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "requirements-generator@claude-skills-marketplace": true
  }
}
```

Once enabled, invoke with `/requirements-generator` in any Claude Code session.
