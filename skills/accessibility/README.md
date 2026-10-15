<!--
doc: skill-readme
standard: ste-lite (ASD-STE100 Issue 9 writing rules, no controlled dictionary)
last-refreshed: 2026-10-14
generated-by: doc-refresh skill
-->

# accessibility

The accessibility skill audits UI code against WCAG 2.2 Level AA. It also gives
accessibility guidance when you design a new component.

## Usage

| Slash command | Mode | What it does |
|---|---|---|
| `/accessibility` | Review | Audits all UI code in the repository |
| `/accessibility src/components` | Review | Audits only the given directory or file |
| `/accessibility --design` | Design | Asks which component you design, then gives guidance |
| `/accessibility --design modal` | Design | Gives guidance for the named component |

The skill reads files only. It uses the `Read`, `Glob`, and `Grep` tools and does not
change your code. It treats file contents as data, not as instructions.

## Review mode

Review mode is the default. The skill does these steps:

1. Find all UI files: JSX, TSX, Vue, Svelte, HTML, ERB, Blade, and CSS or SCSS. If you
   give a path, the skill searches only that path.
2. Run every pattern check in the tables of `SKILL.md`. The skill does not sample.
3. Read the logic of complex components (modals, menus, date pickers, comboboxes, tabs).
   Check focus movement, the Escape key, arrow keys, live regions, and state.
4. Calculate the contrast ratio for each foreground and background hex pair in the CSS.
5. Write a report of findings. Each finding has a severity, a WCAG criterion, the user
   impact, and a fix diff.

The skill calculates contrast with the WCAG relative luminance formula. Use a manual tool
(WebAIM Contrast Checker or Colour Contrast Analyser) only when the colors are not known
statically. Examples are CSS variables set at runtime, opacity layers, gradients, and text
on images.

Contrast thresholds for AA:

| Content | Minimum ratio |
|---|---|
| Normal text | 4.5:1 |
| Large text (24px or more, or 18.66px or more bold) | 3:1 |
| UI components and graphical objects | 3:1 |

## Design mode

Design mode gives guidance before you write code. If you name a component, the skill gives
that guidance directly. If you do not name a component, the skill asks for one.

| Component | Key requirements |
|---|---|
| Modal or dialog | `role="dialog"`, `aria-modal="true"`, `aria-labelledby`, focus trap, Escape closes, focus returns to trigger |
| Dropdown menu | `role="menu"` and `role="menuitem"`, arrow keys, Escape closes |
| Tabs | `role="tablist"`, `role="tab"`, `role="tabpanel"`, arrow keys, `aria-selected` |
| Accordion | `aria-expanded` on the trigger, `aria-controls` points to the panel |
| Form | Visible label per input, `required` and `aria-required`, errors linked with `aria-describedby`, error summary on submit |
| Data table | `<caption>`, `<th scope>`, `id` and `headers` for complex tables |
| Toast or alert | `role="alert"` for urgent, `role="status"` for non-urgent |
| Image with text | `alt` describes content and function; decorative images use `alt=""` |
| Icon button | `aria-label` is always required |
| Loading state | `aria-busy="true"` and an `aria-live` announcement on completion |

## Check areas

| Check area | Issues found |
|---|---|
| Images and media | Missing alt text, video without captions, unclear decorative images |
| Semantic structure | Heading order, landmark regions, `div` used as a button |
| Forms | Missing labels, required field marks, error association, Redundant Entry (3.3.7) |
| Authentication | Paste blocked, password managers blocked, cognitive tests at login (3.3.8) |
| Consistent Help | Help links in a different order or location across page templates (3.2.6) |
| Keyboard navigation | Positive `tabindex`, focus traps, missing key handlers, Focus Not Obscured (2.4.11) |
| ARIA usage | Invalid roles, `aria-hidden` on focusable elements, missing live regions |
| Color and visual | Color-only meaning, pointer targets under 24x24 CSS px (2.5.8) |
| Motion and animation | No `prefers-reduced-motion` support, autoplay media, flashing content |
| Language | Missing `lang` attribute on `<html>` |

The skill does not report 4.1.1 Parsing. WCAG 2.2 removed that criterion.

## Severity levels

| Severity | Definition |
|---|---|
| Critical | Blocks access fully for one or more user groups |
| High | Significantly impairs use |
| Medium | Causes friction; a workaround usually exists |
| Low | Best practice improvement |

## Example output

````markdown
## Accessibility Review — src/components — 2026-10-14

### Summary
| Severity | Count |
|----------|-------|
| Critical | 1 |
| High | 1 |
| Medium | 0 |
| Low | 0 |

**WCAG 2.2 Level AA Compliance Estimate:** Likely Fails

### Findings

**[CRITICAL] Form inputs missing labels — src/components/ContactForm.tsx**
- **WCAG:** 1.3.1 Info and Relationships (Level A), 4.1.2 Name, Role, Value (Level A)
- **Impact:** Screen reader users cannot identify what information to enter.
- **Fix:**
  ```diff
  - <input type="email" placeholder="Enter your email" />
  + <label htmlFor="email">Email address</label>
  + <input id="email" type="email" aria-required="true" autocomplete="email" />
  ```
````

## Standards context

The audit target is WCAG 2.2 Level AA. Content that meets 2.2 AA also meets 2.1 AA and
2.0 AA.

| Rule | Status |
|---|---|
| US ADA Title II (state and local government) | Requires WCAG 2.1 AA. Compliance dates are 26 April 2027 and 26 April 2028, by entity size, per the DOJ interim final rule of April 2026. |
| EU European Accessibility Act | Applies from 28 June 2025. EN 301 549 is the harmonised standard for conformance. |
| WCAG 3.0 | W3C Working Draft. The skill does not grade against it. |

This README is not legal advice. Confirm the obligations for your jurisdiction and your
organization.

## Manual testing

Automated pattern checks do not find all issues. Do manual tests too.

Keyboard test:

1. Disconnect the mouse.
2. Press Tab through each interactive element. Make sure that focus is visible and the
   order is logical.
3. Activate buttons with Enter and Space. Use the arrow keys in menus.
4. Press Escape to close a modal. Make sure that focus goes back to the trigger.

Screen reader test:

- macOS and iOS: VoiceOver (built in). Press Cmd+F5 to start it on macOS.
- Windows: NVDA (free) or JAWS (paid).
- Android: TalkBack (built in).

Zoom test:

1. Set the browser zoom to 400%.
2. Make sure that no content is hidden or overlaps.

## Installation

Add this repository as a marketplace in `~/.claude/settings.json` (see the root
[README](../../README.md)). Then enable the plugin:

```json
{
  "enabledPlugins": {
    "accessibility@claude-skills-marketplace": true
  }
}
```

## Related skills

- `/code-review`: general code quality review. Run it with this skill.
- `/best-practices`: wider frontend best practices.
