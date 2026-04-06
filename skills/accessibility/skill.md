# accessibility

## Purpose
Two modes:
- **Review mode** (`/accessibility`): Audit existing code for WCAG 2.2 AA compliance issues. Produces severity-graded findings with WCAG criterion references and fix diffs.
- **Design mode** (`/accessibility --design`): Provide accessibility guidance when designing a new feature or component.

The goal is not just compliance — it is building products that work for everyone, including users with visual, motor, auditory, and cognitive disabilities.

---

## REVIEW MODE Instructions

**Step 1 — Discover UI code**
Use Glob to find: `**/*.{jsx,tsx,vue,svelte,html,erb,blade.php}`, template files, CSS/SCSS files, any component library files.

**Step 2 — Run automated pattern checks**

Use Grep across all discovered files:

**Images and Media:**
- `<img` without `alt=` attribute → critical
- `<img alt=""` — valid for decorative images, flag for review if unclear
- `<svg` without `role="img"` and `<title>` for informational SVGs
- `<video` without `<track kind="captions">`
- Background images conveying information (CSS `background-image` with no text alternative)

**Semantic Structure:**
- Multiple `<h1>` tags on a page
- Skipped heading levels (`<h2>` followed by `<h4>`)
- `<div>` or `<span>` used as buttons/links (missing `role="button"`, `tabindex`, keyboard handlers)
- `<table>` without `<caption>` or `scope` attributes on `<th>`
- Lists using `<div>` instead of `<ul>`/`<ol>`
- `<b>` and `<i>` used for semantic emphasis (should be `<strong>` and `<em>`)
- Page missing `<main>`, `<nav>`, `<header>`, `<footer>` landmarks

**Forms:**
- `<input>` without associated `<label>` (via `for`/`id` or `aria-label` or `aria-labelledby`)
- `<input>` without `type` attribute
- Required fields without `aria-required="true"` or `required` attribute
- Error messages not associated with their input via `aria-describedby`
- Form submitted programmatically without focus management
- `placeholder` used as the only label (disappears on input — insufficient)
- Autocomplete attributes missing on common fields (name, email, address)

**Keyboard Navigation:**
- `tabindex` values > 0 (disrupts natural tab order)
- Focus traps not implemented in modals/dialogs (focus must be trapped inside)
- Missing `focus` visible styles (`:focus { outline: none }` without replacement)
- `onmouseover`/`onmouseout` without keyboard equivalents (`onfocus`/`onblur`)
- Drag-and-drop without keyboard alternative
- Custom interactive elements without keyboard event handlers (`keydown`/`keyup` for Enter/Space)

**ARIA Usage:**
- `aria-label` on non-interactive elements (unnecessary)
- `aria-hidden="true"` on focusable elements (makes them unreachable but visible)
- Invalid ARIA roles for element type (e.g. `role="button"` on `<a>`)
- `aria-expanded` not toggled on open/close
- `aria-live` regions for dynamic content updates (missing where needed)
- Dialog/modal missing `role="dialog"`, `aria-modal="true"`, `aria-labelledby`
- Required `aria-*` attributes missing for a given role

**Color and Visual:**
- `color: red` or similar semantic-only colour for errors (must also have icon or text)
- Very small font sizes (< 12px for body text)
- `pointer-events: none` removing touch targets
- Touch targets < 44x44px (WCAG 2.5.8)
- `user-select: none` on text content

**Motion and Animation:**
- CSS animations/transitions without `@media (prefers-reduced-motion)` override
- Auto-playing video or audio without user control
- Content that flashes > 3 times per second (seizure risk)

**Language:**
- HTML `<html>` tag missing `lang` attribute
- Mixed-language content not wrapped with `lang` attribute on the element

**Step 3 — Design review (read component logic)**

For complex interactive components (modals, dropdowns, date pickers, comboboxes, tabs), use Read to examine the JavaScript/framework logic and check:
- Focus management: where does focus go when a modal opens? When it closes?
- Escape key handler for dismissible elements
- Arrow key navigation for composite widgets (menus, tabs, carousels)
- Announcement of dynamic content changes via `aria-live` or focus movement
- State communicated to screen readers (selected, expanded, checked, disabled)

**Step 4 — Colour contrast check**

For each colour combination found in CSS (foreground + background), note it for manual contrast check. Flag common failures:
- Light grey text on white background (very common)
- White text on light brand colours
- Placeholder text colour (usually fails 4.5:1)
- Disabled element text (exempt from contrast but note it)

Remind the user to verify using a contrast checker tool (WebAIM, Colour Contrast Analyser) since exact hex values must be checked at runtime.

**Step 5 — Output findings**

Each finding includes:
- **Severity**: Critical (blocks access entirely for some users), High (significantly impairs), Medium (causes friction), Low (best practice improvement)
- **WCAG Criterion**: e.g. "1.1.1 Non-text Content (Level A)"
- **User Impact**: which users are affected (screen reader users, keyboard-only, low vision, motor impairment, cognitive)
- **Fix**: specific code change with diff

Output format:
```markdown
## Accessibility Review — <scope> — <date>

### Summary
| Severity | Count |
|----------|-------|
| Critical | X |
| High | X |
| Medium | X |
| Low | X |

**WCAG 2.2 Level AA Compliance Estimate:** Likely Fails / Likely Passes / Needs Manual Testing

### Findings

**[CRITICAL] Form inputs missing labels — src/components/ContactForm.tsx**
- **WCAG:** 1.3.1 Info and Relationships (Level A), 4.1.2 Name, Role, Value (Level A)
- **Impact:** Screen reader users cannot identify what information to enter. Affects ~7% of users who use assistive technology.
- **Fix:**
  ```diff
  - <input type="email" placeholder="Enter your email" />
  + <label htmlFor="email">Email address</label>
  + <input id="email" type="email" placeholder="user@example.com" aria-required="true" autocomplete="email" />
  ```

**[HIGH] Modal dialog missing focus trap — src/components/Modal.tsx**
- **WCAG:** 2.1.2 No Keyboard Trap (Level A)
- **Impact:** Keyboard users can tab out of the modal to background content, losing context and control.
- **Fix:** Implement focus trap on mount: query all focusable elements within the modal, intercept Tab/Shift+Tab, and wrap focus at boundaries.
```

---

## DESIGN MODE Instructions (`/accessibility --design`)

When designing a new feature or component, apply these guidelines proactively:

**Component-specific guidance — ask which component is being designed:**

- **Modal/Dialog**: use `role="dialog"`, `aria-modal="true"`, `aria-labelledby` pointing to heading. Trap focus on open, return focus to trigger on close. Close on Escape.
- **Dropdown Menu**: use `role="menu"`, `role="menuitem"`. Arrow keys navigate, Enter/Space select, Escape closes, focus returns to trigger.
- **Tabs**: use `role="tablist"`, `role="tab"`, `role="tabpanel"`. Arrow keys switch tabs. Selected tab has `aria-selected="true"`.
- **Accordion**: use `role="button"` on trigger with `aria-expanded`. Panel content in a sibling element controlled by `aria-controls`.
- **Form**: every input has a visible label. Required fields use `required` and `aria-required`. Errors linked via `aria-describedby`. Error summary at top of form on submit failure.
- **Data Table**: `<caption>` describes table purpose. `<th scope="col/row">` on all headers. Complex tables use `id`/`headers` association.
- **Toast/Alert**: use `role="alert"` for urgent, `role="status"` for non-urgent. `aria-live="assertive"` or `"polite"` respectively.
- **Image with text**: `alt` describing the content and function, not appearance. Decorative: `alt=""`. Informational: descriptive text.
- **Icon button**: `aria-label` required. Never use an icon alone without text label or aria-label.
- **Loading state**: `aria-busy="true"` on the loading container. Announce completion with `aria-live`.

**Design principles to apply throughout:**
1. Provide text alternatives for all non-text content
2. Make all functionality available from keyboard
3. Give users enough time and control (no timeouts without warning)
4. Don't use colour as the only visual means of conveying information
5. Make text readable and understandable (plain language, reading level)
6. Support zoom to 400% without loss of content or functionality
7. Respect `prefers-reduced-motion` and `prefers-color-scheme`
8. Test with a screen reader (NVDA/JAWS on Windows, VoiceOver on macOS/iOS, TalkBack on Android)
