---
model: sonnet
description: Generate React or Vue components with prop types, styling, accessibility, and tests
---

Generate a production-quality UI component from the description provided in `$ARGUMENTS`.

## Step 1 — Parse the Request

Extract from `$ARGUMENTS`:
- **Component name** (e.g., "DataTable", "Modal", "SearchBar")
- **Feature requirements** (what the component should do)
- **Framework preference** (React or Vue — detect from project if not stated)
- **Variants or states** (e.g., "loading, error, empty states")

If the description is minimal (e.g., just "Modal"), generate a fully-featured, accessible version with sensible defaults.

## Step 2 — Detect Project Conventions

Search the project to determine:

1. **Framework:** React (JSX/TSX) or Vue (SFC `.vue` files). Check `package.json` for `react`, `vue`, `next`, `nuxt`, etc.
2. **Language:** TypeScript or JavaScript. Check for `tsconfig.json`, existing file extensions.
3. **Styling approach:** CSS Modules, Tailwind CSS, styled-components, Emotion, SCSS, plain CSS, or a UI library (shadcn/ui, MUI, Chakra, Vuetify, etc.). Check existing components.
4. **State management:** React hooks, Zustand, Redux, Pinia, Vuex.
5. **Component patterns:** Read 1-2 existing components to match:
   - File naming convention (`PascalCase.tsx`, `kebab-case.vue`)
   - Directory structure (flat, feature-based, atomic design)
   - Export patterns (default export vs named export)
   - Props definition pattern (interface, type, defineProps)

## Step 3 — Design the Component API

Before writing code, define the component's public interface:

```
## Component Design: [Name]

### Props
| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| ...  | ...  | ...     | ...      | ...         |

### Events / Callbacks
| Event | Payload | Description |
|-------|---------|-------------|
| ...   | ...     | ...         |

### Slots / Children (if applicable)
| Slot | Description |
|------|-------------|
| ...  | ...         |

### States
- Default, Loading, Error, Empty, Disabled (as applicable)
```

## Step 4 — Generate the Component

Write the component following these quality standards:

### Props and Types
- Define a clear TypeScript interface or type for all props (React) or use `defineProps` with type annotations (Vue)
- Use sensible defaults for optional props
- Add JSDoc comments on non-obvious props

### Accessibility (WCAG 2.1 AA)
- Use semantic HTML elements (`<button>`, `<nav>`, `<dialog>`, `<table>`, not generic `<div>` for everything)
- Add appropriate ARIA attributes:
  - `role` when semantic HTML is insufficient
  - `aria-label` or `aria-labelledby` for interactive elements
  - `aria-expanded`, `aria-haspopup`, `aria-controls` for disclosure patterns
  - `aria-live` for dynamic content updates
  - `aria-describedby` for form validation errors
- Ensure keyboard navigation:
  - All interactive elements focusable via Tab
  - Escape key closes modals/popups
  - Arrow keys for menu/list navigation
  - Enter/Space activates buttons and controls
- Provide visible focus indicators
- Maintain sufficient color contrast (do not rely on color alone)
- Support `prefers-reduced-motion` for animations

### Styling
- Match the project's styling approach exactly
- Support light and dark themes if the project uses them
- Make the component responsive by default
- Use design tokens or CSS variables from the existing system when available

### State Handling
- Handle loading, error, and empty states gracefully
- Show meaningful feedback for each state (skeletons, error messages, empty illustrations)
- Use controlled and uncontrolled patterns appropriately

### Performance
- Memoize expensive computations
- Use `React.memo` / `useMemo` / `useCallback` where appropriate (React)
- Use `computed` and `watch` efficiently (Vue)
- Lazy-load heavy dependencies if applicable
- Avoid unnecessary re-renders from inline object/function creation in JSX

## Step 5 — Generate Tests

Write tests covering:

### Rendering
- Renders without crashing with minimum required props
- Renders all variants and states correctly
- Applies custom className or style props

### Interaction
- Click handlers fire with correct arguments
- Keyboard navigation works (Tab, Enter, Escape, Arrow keys)
- Form inputs update correctly on change

### Accessibility
- No accessibility violations (use `jest-axe` or `vitest-axe` if available)
- ARIA attributes are present and correct
- Focus management works as expected

### Edge Cases
- Very long text content (truncation, wrapping)
- Missing optional props (defaults apply)
- Rapid interaction (debouncing, double-click prevention)
- Empty data sets

Place the test file adjacent to the component following project conventions.

## Step 6 — Generate a Storybook Story (if applicable)

If the project uses Storybook (check for `.storybook/` directory or `@storybook/*` in dependencies), generate a story file with:
- Default story
- One story per variant/state
- Interactive args/controls for key props

## Step 7 — Verify and Report

1. Run the type checker (if TypeScript).
2. Run the linter.
3. Run tests.

```
## Component Generation Report

**Component:** [Name]
**Framework:** React / Vue
**Language:** TypeScript / JavaScript
**Styling:** Tailwind / CSS Modules / styled-components / etc.

### Files Created
- (path) — component source
- (path) — test file
- (path) — story file (if applicable)
- (path) — style file (if applicable)

### Props: (count)
### Test Cases: (count)
### Accessibility Features:
- (list of a11y features implemented)

### Usage Example
(short code snippet showing how to use the component)
```
