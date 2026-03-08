# CLAUDE.md Templates

> Guide to writing effective CLAUDE.md files and ready-to-use templates for different project types.

`CLAUDE.md` is the single most important file for Claude Code. It gives Claude persistent context about your project — the tech stack, conventions, commands, and how to work effectively in your codebase. A good CLAUDE.md can be the difference between Claude producing generic code and Claude producing code that fits your project perfectly.

---

## How CLAUDE.md Works

- Claude reads `CLAUDE.md` at the **start of every session**
- It acts as a system prompt scoped to your project
- Place it in the **repo root** for project-wide context
- Place it in **subdirectories** for directory-specific context (e.g., `frontend/CLAUDE.md`)
- Supports standard Markdown formatting

---

## Templates

| Template | Lines | Best For | Link |
|----------|:-----:|----------|------|
| Starter | ~40 | Solo projects, quick setup | [starter.md](starter.md) |
| Team Project | ~100 | Team conventions, CI/CD | [team-project.md](team-project.md) |
| Monorepo | ~80 | Multi-package workspaces | [monorepo.md](monorepo.md) |

### How to choose

- **Starter**: You work alone or want minimal setup. Copy, fill in the blanks, done.
- **Team Project**: You have a team with shared conventions, CI/CD, and a PR process.
- **Monorepo**: You have multiple packages/apps in one repository (e.g., Turborepo, Nx, Lerna).

---

## What to Include

A good CLAUDE.md has these sections:

### 1. Project Overview (required)
What the project is and what it does. One paragraph is enough.

### 2. Tech Stack (required)
Languages, frameworks, and major dependencies. Claude uses this to choose the right patterns.

### 3. Commands (required)
How to build, test, lint, and run the project. Claude needs these to verify its work.

### 4. Project Structure (recommended)
Brief description of the directory layout. Helps Claude navigate the codebase.

### 5. Conventions (recommended)
Code style, naming rules, architecture patterns. The more specific, the better.

### 6. What to Avoid (recommended)
Anti-patterns, deprecated libraries, known pitfalls. Prevents common mistakes.

### 7. CI/CD and Deployment (optional)
How the project is tested and deployed. Useful for DevOps-related tasks.

---

## Writing Tips

### Be specific, not vague

```markdown
<!-- Bad -->
Follow best practices for React.

<!-- Good -->
Use functional components with TypeScript. Extract reusable logic into custom hooks
prefixed with `use`. State management: useState for local, Zustand for global.
```

### Include actual commands

```markdown
<!-- Bad -->
Run the tests before committing.

<!-- Good -->
Run tests: `npm test`
Run single test file: `npm test -- --grep "UserService"`
Run with coverage: `npm test -- --coverage`
```

### Specify what NOT to do

```markdown
<!-- Bad -->
(nothing about what to avoid)

<!-- Good -->
Do NOT:
- Use class components (always functional)
- Use `any` type in TypeScript (use `unknown` and narrow)
- Import from `lodash` directly (use `lodash-es` for tree-shaking)
- Put business logic in React components (use service layer)
```

### Keep it scannable

- Use headers, bullet points, and code blocks
- Front-load the most important information
- Keep it under 150 lines — too long and the signal gets diluted

---

## Layered CLAUDE.md

For large projects, use multiple CLAUDE.md files:

```
project-root/
  CLAUDE.md              # Global: tech stack, conventions, commands
  frontend/
    CLAUDE.md            # Frontend-specific: React patterns, component structure
  backend/
    CLAUDE.md            # Backend-specific: API conventions, database patterns
  infrastructure/
    CLAUDE.md            # Infra-specific: Terraform conventions, cloud setup
```

Claude loads the root file plus any CLAUDE.md files in the current working directory chain.

---

## Maintenance

- **Review quarterly** — update when your stack or conventions change
- **Add pain points** — if Claude keeps making the same mistake, add a rule
- **Remove stale info** — outdated conventions cause confusion
- **Version control it** — CLAUDE.md should be committed and reviewed like code
