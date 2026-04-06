# accessibility

A Claude Code skill for auditing existing UI code against WCAG 2.2 AA and providing proactive accessibility guidance when designing new components.

## Commands

- `/accessibility` — Audit existing code for WCAG 2.2 AA issues (review mode)
- `/accessibility --design` — Get accessibility guidance while designing a new feature or component (design mode)

## Modes

### Review Mode (default, `/accessibility`)

Scans your UI codebase for accessibility issues using static analysis patterns:

1. Discovers all UI files (JSX, TSX, Vue, Svelte, HTML, ERB, Blade, CSS/SCSS)
2. Runs Grep-based pattern checks across all files
3. Reads complex interactive components to check focus management and ARIA logic
4. Notes colour combinations for manual contrast verification
5. Produces a severity-graded findings report with WCAG criterion references, user impact, and fix diffs

### Design Mode (`/accessibility --design`)

When building a new feature or component, this mode provides proactive guidance:

- Component-specific ARIA patterns (modals, menus, tabs, accordions, forms, tables, toasts)
- Keyboard interaction models for each component type
- Focus management patterns (where focus goes on open/close/navigate)
- Screen reader announcement strategies

## WCAG 2.2 AA Overview

WCAG 2.2 is organized around four principles (POUR):

| Principle | Meaning |
|-----------|---------|
| Perceivable | Information must be presentable in ways users can perceive |
| Operable | UI components and navigation must be operable |
| Understandable | Information and operation must be understandable |
| Robust | Content must be interpretable by a wide range of user agents |

Level AA compliance is the legal standard in most jurisdictions (ADA, EN 301 549, AODA).

## What Each Check Catches

| Check Area | Issues Found |
|------------|-------------|
| Images and Media | Missing alt text, uncaptioned video, decorative image misuse |
| Semantic Structure | Heading hierarchy, landmark regions, div-as-button anti-pattern |
| Forms | Missing labels, required field marking, error association |
| Keyboard Navigation | Tab order issues, focus traps, missing keyboard handlers |
| ARIA Usage | Invalid roles, aria-hidden on focusable elements, missing live regions |
| Color and Visual | Semantic-only color, small touch targets, pointer-events misuse |
| Motion and Animation | Missing prefers-reduced-motion support, autoplaying media |
| Language | Missing lang attribute on html element |

## Who Is Affected

| Disability Type | Examples of Issues Caught |
|----------------|--------------------------|
| Visual (blindness, low vision) | Missing alt text, poor contrast, no landmarks |
| Motor (limited mobility, tremor) | No keyboard access, small touch targets, positive tabindex |
| Auditory (deaf, hard of hearing) | Missing video captions, audio-only content |
| Cognitive (ADHD, dyslexia) | Complex navigation, time limits, flashing content |

Approximately 15% of the global population has some form of disability. Accessible products are better products for everyone.

## Severity Levels

| Severity | Definition |
|----------|-----------|
| Critical | Blocks access entirely for one or more disability groups |
| High | Significantly impairs use; major friction or partial access loss |
| Medium | Causes friction or confusion; workaround usually exists |
| Low | Best practice improvement; minor impact on specific scenarios |

## Manual Testing Guidance

Automated checks catch approximately 30-40% of accessibility issues. Manual testing is essential:

**Keyboard-only testing:**
1. Unplug your mouse
2. Tab through every interactive element — verify visible focus, logical order
3. Activate buttons with Enter/Space, navigate menus with arrow keys
4. Dismiss modals with Escape, verify focus returns to trigger

**Screen reader testing:**
- macOS / iOS: VoiceOver (built-in, free) — Cmd+F5 to activate
- Windows: NVDA (free) or JAWS (paid)
- Android: TalkBack (built-in)

**Zoom testing:**
- Set browser zoom to 400% — verify no content is hidden or overlapping
- Enable OS-level large text — verify layout adapts

## Colour Contrast Tools

Since Claude cannot render pixels, contrast ratios must be verified with external tools:

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/) (desktop app, picks colours from screen)
- [Accessible Colors](https://accessible-colors.com/) (suggests accessible alternatives)

WCAG AA requires:
- Normal text (< 18pt or < 14pt bold): 4.5:1 contrast ratio
- Large text (≥ 18pt or ≥ 14pt bold): 3:1 contrast ratio
- UI components and graphics: 3:1 against adjacent colors

## Component Design Patterns

| Component | Key Requirements |
|-----------|-----------------|
| Modal/Dialog | `role="dialog"`, `aria-modal="true"`, focus trap, Escape to close |
| Dropdown Menu | `role="menu"`, arrow key navigation, Escape closes |
| Tabs | `role="tablist/tab/tabpanel"`, arrow key switching, `aria-selected` |
| Accordion | `aria-expanded` on trigger, `aria-controls` pointing to panel |
| Form | Visible label per input, error linked via `aria-describedby` |
| Data Table | `<caption>`, `<th scope>`, complex tables use `id`/`headers` |
| Toast/Alert | `role="alert"` (urgent) or `role="status"` (non-urgent) |
| Icon Button | `aria-label` always required |
| Loading | `aria-busy="true"` + `aria-live` for completion announcement |

## Integration with Other Skills

- `/code-review` — general code quality review (run alongside accessibility)
- `/best-practices` — broader frontend best practices
