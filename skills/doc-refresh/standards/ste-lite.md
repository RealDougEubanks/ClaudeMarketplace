# STE-lite: tiered ASD-STE100 writing rules without the controlled dictionary

Use this file when the selected standard is `ste-lite` or `ste`, and for the "always" tier
that applies to every document (see the catalog).

## What it is

ASD-STE100 Simplified Technical English (STE) is maintained by ASD (the Aerospace, Security
and Defence Industries Association of Europe). The current edition is Issue 9, released in
January 2025. The standard has two parts: writing rules and a controlled dictionary of about
900 approved words. Each approved word has one meaning and one part of speech.

"STE-lite" is an in-house convention, not a named standard. It keeps the writing rules, splits
them into two tiers, and drops the closed dictionary. The dictionary is the costly part: it
needs trained writers and checker tools, and ASD itself says that STE belongs inside a wider
company style guide.

Do not describe STE-lite as a percentage of STE ("80% STE"). The rules do not carry equal
weight, and no published source defines a percentage. Describe it as "ASD-STE100 Issue 9
writing rules, tiered, no controlled dictionary."

Sources:

- ASD-STE100 home and free copy request: <https://www.asd-ste100.org/>
- Issue 9 announcement: <https://www.asd-europe.org/news-media/news-events/news/simplified-technical-english-asd-ste100-issue-9>

> Paraphrase the rules below. Do not copy rule text or dictionary entries from the standard;
> ASD keeps the copyright.

## Tier 1 — always (every document, whatever the standard)

These rules carry most of STE's value and cost little readability.

| Area | Rule |
|---|---|
| Sentence length | 20 words or fewer in procedural steps. 25 words or fewer in other prose. |
| Paragraphs | One topic. 6 sentences or fewer. Use a list or a table for 3 or more parallel items. |
| Steps | One instruction per numbered step. A short note after the instruction is permitted. |
| Notices | Put a safety or security notice immediately before the step that it applies to. |
| Terminology | One term for one concept. Build a short project glossary before you write, and use only those terms. |
| Order | Put conditions first ("If X, do Y."). Put the most important information first. |
| Articles | Keep "the" and "a". Do not write telegraphic text. |

## Tier 2 — procedural (procedures, runbooks, troubleshooting, reference, agent context)

These rules make instructions unambiguous, which also helps AI agents. They cost readability
in conceptual text, so apply them only to these document types — and, in every document, to
the text of numbered steps.

| Area | Rule |
|---|---|
| Mood | Imperative for instructions ("Set the token."). |
| Voice | Active. Use passive only when the actor is unknown or not relevant. |
| Modal verbs | Do not use "would", "could", "should", "might" or "may". Use "can" for ability, "must" for obligation, "do not" for prohibition. |
| "-ing" forms | Do not use "-ing" verb forms in phrases such as "by setting X" or "before running Y" ("set X", "before you run Y"). Fixed technical nouns such as "logging" are permitted. |
| Verb forms | Simple present, simple past, simple future, imperative. |
| Noun clusters | 3 words or fewer. Code identifiers and product names are exempt. |

## What STE-lite relaxes

- No controlled dictionary. Use normal technical English plus the project's technical nouns
  and verbs (STE rules for technical nouns and technical verbs already allow domain terms).
- "You" is permitted in descriptive text.
- Table cells can be fragments.
- Code, commands, configuration, and error strings stay verbatim, even when they break a rule.
- Headings can be noun phrases.
- Outside Tier 2 document types, prose (not steps) follows the plain-language standard.

## Full `ste` mode

The controlled dictionary is not bundled with this skill. If the user selects `ste`:

1. Ask whether they have the ASD-STE100 Issue 9 dictionary available.
2. If they do, apply Tier 1 and Tier 2 to all prose, restrict vocabulary to the dictionary
   plus project technical terms, and report non-approved words.
3. If they do not, apply `ste-lite` and say so in the summary.

Full STE fits regulated or contractual work: aerospace, defence, and some medical-device
documentation. Do not choose it automatically for software docs.

## Notice levels

These levels follow the STE convention (warning before caution) in software terms:

| Notice | Use for |
|---|---|
| `> **SECURITY:**` | Credentials, tokens, secrets, permissions, network exposure, data in state or logs |
| `> **WARNING:**` | An action that destroys or replaces live data or resources |
| `> **CAUTION:**` | An action that can cause an unwanted change, a replacement, or wasted work, but no data loss |

Each notice: 1 to 3 short sentences. State the risk, then the action to take.

## Glossary file

Write the project glossary to a temporary file so the checker can enforce it. Use one line per
concept, with the preferred term, a colon, and the terms to avoid:

```text
# preferred: avoid, avoid
subaccount: sub-account, child account
API token: API key
```

## Measure conformance

Run the bundled checker with the tier that matches the document type:

```bash
# Tier 2 document types (runbook, troubleshooting, reference, agent context)
python3 "${CLAUDE_PLUGIN_ROOT:-skills/doc-refresh}/scripts/ste_check.py" --tier full --glossary <glossary> <files>

# All other document types (Tier 2 rules apply only inside numbered steps)
python3 "${CLAUDE_PLUGIN_ROOT:-skills/doc-refresh}/scripts/ste_check.py" --tier always --glossary <glossary> <files>
```

The checker tests the rules that a script can test: sentence and paragraph length, modal
verbs, "-ing" phrases, likely passive voice, glossary terms to avoid, and the accessibility
markup rules from the catalog (alt text, link text, heading order). The passive-voice and
"-ing" checks are heuristics: review each hit, and keep the sentence when the rewrite is worse.
The checker skips frontmatter, HTML comments, code blocks, tables, and headings.

A score is the share of sentences with no violation. Aim for 90% or more, and fix every
glossary violation. A high score is necessary, not sufficient: also read the text for the
rules no script can test (one instruction per step, condition first, notice placement).
