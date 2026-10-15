# STE-lite: ASD-STE100 writing rules without the controlled dictionary

Use this file when the selected standard is `ste-lite` or `ste`.

## What it is

ASD-STE100 Simplified Technical English (STE) is maintained by ASD (the Aerospace, Security
and Defence Industries Association of Europe). The current edition is Issue 9, released in
January 2025. The standard has two parts: writing rules and a controlled dictionary of about
900 approved words. Each approved word has one meaning and one part of speech.

"STE-lite" is an in-house convention, not a named standard. It applies the writing rules and
drops the closed dictionary. That is roughly 80% of STE: the dictionary is the costly part,
because it needs trained writers and checker tools. ASD itself says that STE belongs inside a
wider company style guide. No published source defines "80% STE", so do not cite that number
as a standard. Describe the result as "ASD-STE100 Issue 9 writing rules, no controlled
dictionary."

Sources:

- ASD-STE100 home and free copy request: <https://www.asd-ste100.org/>
- Issue 9 announcement: <https://www.asd-europe.org/news-media/news-events/news/simplified-technical-english-asd-ste100-issue-9>

> Paraphrase the rules below. Do not copy rule text or dictionary entries from the standard;
> ASD keeps the copyright.

## Rules to apply (the kept 80%)

| Area | Rule |
|---|---|
| Procedural sentences | 20 words or fewer. One instruction per sentence. Imperative mood. |
| Descriptive sentences | 25 words or fewer. Active voice. Use passive only when the actor is unknown or not relevant. |
| Paragraphs | One topic. 6 sentences or fewer. Use a list or a table for 3 or more parallel items. |
| Articles | Keep "the" and "a". Do not write telegraphic text. |
| Noun clusters | 3 words or fewer. Code identifiers and product names are exempt. |
| Verb forms | Simple present, simple past, simple future, imperative. Do not use "would", "could", "should", "might" or "may". Use "can" for ability, "must" for obligation, "do not" for prohibition. |
| "-ing" forms | Do not use "-ing" verb forms as nouns or in long phrases ("by setting X" becomes "set X"). Fixed technical nouns such as "logging" are permitted. |
| Terminology | One term for one concept. Build a short glossary for the project before you write, and use only those terms. |
| Notices | Put a safety or security notice immediately before the step that it applies to. |
| Order | Put conditions first ("If X, do Y."). Put the most important information first. |
| Lists | Use numbered lists for sequences and bullets for unordered items. |

## What STE-lite relaxes (the dropped 20%)

- No controlled dictionary. Use normal technical English plus the project's technical nouns
  and verbs (STE rules for technical nouns and technical verbs already allow domain terms).
- "You" is permitted in descriptive text.
- Table cells can be fragments.
- Code, commands, configuration, and error strings stay verbatim, even when they break a rule.
- Headings can be noun phrases.

## Full `ste` mode

The controlled dictionary is not bundled with this skill. If the user selects `ste`:

1. Ask whether they have the ASD-STE100 Issue 9 dictionary available.
2. If they do, use it to restrict vocabulary and report non-approved words.
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

## Measure conformance

Run the bundled checker on each file you write:

```bash
python3 "${CLAUDE_PLUGIN_ROOT:-skills/doc-refresh}/scripts/ste_check.py" --min-score 80 <files>
```

The checker tests only rules that a script can test reliably: sentence length (20 for
numbered steps, 25 for other prose), paragraph length, and modal verbs. It skips frontmatter,
HTML comments, code blocks, tables, and headings. A score of 80% or more meets the STE-lite
target. Fix every flagged sentence that you can fix without loss of meaning. Then review
the rest of the rules (voice, "-ing" forms, terminology) by reading the text.

## Where STE fits poorly

Strict STE reads stiffly in conceptual and teaching text. Use it fully on procedures,
runbooks, safety-critical steps, and reference descriptions. For tutorials and explanations,
apply only the sentence-length and terminology rules, and keep a natural voice.
