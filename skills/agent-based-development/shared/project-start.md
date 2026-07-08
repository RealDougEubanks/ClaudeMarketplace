# Project Start — Bootstrap Procedure

Run this when no `handoffs/` directory exists in the current working directory. The
bootstrapping agent adopts the **Planning** role.

a. Ask for the project-start prompt if not already provided.

b. Adopt the Planning role.

c. Use Bash to create the full directory structure:

   ```
   mkdir -p handoffs/plans handoffs/designs handoffs/dev handoffs/reviews handoffs/docs docs shared/schemas
   ```

   Then use Write to save the envelope schema to `shared/schemas/handoff-envelope.schema.json`
   **in the target project**:

   ```json
   {
     "$schema": "https://json-schema.org/draft/2020-12/schema",
     "type": "object",
     "required": ["taskId", "agent", "status", "timestamp"],
     "additionalProperties": false,
     "properties": {
       "taskId": { "type": "string", "pattern": "^task-[0-9]{3,}$" },
       "agent": { "type": "string" },
       "status": { "enum": ["assigned", "in-progress", "complete", "blocked", "needs-rework"] },
       "timestamp": { "type": "string", "format": "date-time" },
       "payload": { "type": "object" },
       "assumptions": {
         "type": "array",
         "items": {
           "type": "object",
           "required": ["assumption", "why", "date"],
           "properties": {
             "assumption": { "type": "string" },
             "why": { "type": "string" },
             "date": { "type": "string" }
           }
         }
       }
     }
   }
   ```

d. Use Write to create `docs/agentRoster.md` listing active agents. Ask the user which agents
   to enable, or default to: planning, dev-senior, documentation, security, tech-review.

e. Use Write to create the first plan artifact in `handoffs/plans/` using the envelope schema.
   Assign tasks to each active agent.

f. Use Write to create `docs/assumptions.md` with any assumptions made during planning.

## Project-Start Prompt Examples

**Simple:**

> "Create a BASH backup script. Copy source → destination, optional compression, retention copies. Cron-friendly."

**Detailed:**

> "Create a minimal static blog. Home = post list (title, date, excerpt); post detail = full content. Content as Markdown or JSON. Responsive, light/dark toggle, accessible colors. Static HTML/JS. No backend for v1. Document stack and assumptions in docs/assumptions.md."

When given a project-start prompt, Planning must:

- Identify the stack and document it in `docs/assumptions.md`.
- Determine which agents are needed and write `docs/agentRoster.md`.
- Create the first plan artifact in `handoffs/plans/` with assignments for each active agent.
- Adapt granularity to complexity: a single plan for simple projects; per-agent/per-task plans for complex ones.
