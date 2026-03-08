# Workflow: New Feature

> Full feature development cycle: plan, implement, test, review, and ship.

---

## Overview

| Phase | Mode | Recipes Used | Time |
|-------|------|-------------|------|
| 1. Plan | Plan | — | 5-10 min |
| 2. Scaffold | Code | `/component-gen`, `/api-gen` | 5-15 min |
| 3. Implement | Code | Subagents (frontend-dev, backend-dev) | 15-60 min |
| 4. Test | Code | `/test-gen`, test-runner subagent | 10-20 min |
| 5. Review | Code | `/code-review`, code-reviewer subagent | 5-10 min |
| 6. Ship | Code | `/pr-description`, `/commit-message` | 5 min |

---

## Step 1: Plan

**Mode**: Plan (or use `shift+tab` to toggle)

Start by asking Claude to analyze the requirements and propose an implementation plan. Plan mode prevents any code changes — Claude will only think and discuss.

**Prompt**:
```
I need to implement [feature description].

Here are the requirements:
- [requirement 1]
- [requirement 2]
- [requirement 3]

Analyze the existing codebase and propose an implementation plan. Include:
1. Which files need to be created or modified
2. Data model changes (if any)
3. API endpoints needed (if any)
4. Frontend components needed (if any)
5. Potential risks or edge cases
```

**What to look for**:
- Does the plan cover all requirements?
- Are the file changes reasonable?
- Are edge cases addressed?
- Is the approach consistent with existing patterns?

---

## Step 2: Scaffold

**Mode**: Code

Create the skeleton — empty files, interfaces, type definitions, and API stubs.

**Prompt**:
```
Let's implement the plan. Start by scaffolding:
1. Create the necessary files and directories
2. Define the TypeScript interfaces/types
3. Create empty function signatures with TODO comments
4. Set up the routing/API endpoints (stubs only)

Don't implement business logic yet — just the structure.
```

**Recipes to use**:
- `/component-gen` — if the feature includes React/Vue components
- `/api-gen` — if the feature includes REST endpoints

---

## Step 3: Implement

**Mode**: Code

Now fill in the business logic. For complex features, delegate to specialized subagents.

**For frontend work**:
```
Implement the frontend components we scaffolded. Follow the React patterns
in our skills (functional components, proper hooks usage, accessibility).
Focus on [specific component] first.
```

**For backend work**:
```
Implement the API endpoints and service logic we scaffolded. Follow our
API design conventions (proper status codes, error responses, validation).
Start with [specific endpoint].
```

**For complex features** — delegate to subagents:
```
Use the frontend-dev subagent to implement the UI components,
then use the backend-dev subagent for the API layer.
```

**Tips**:
- Implement one module at a time, not everything at once
- Ask Claude to verify each module works before moving on
- Keep related changes in the same logical unit

---

## Step 4: Test

**Mode**: Code

Generate and run tests for the new feature.

**Prompt**:
```
Generate tests for the feature we just implemented:
1. Unit tests for all service/utility functions
2. Integration tests for API endpoints
3. Component tests for React components
4. Cover edge cases: empty input, invalid data, error states

Run the tests and fix any failures.
```

**Recipes to use**:
- `/test-gen` — generate test files
- Test-runner subagent — run tests and fix failures automatically

**Coverage check**:
```
Check test coverage for the files we changed. We need at least 80% line coverage.
```

---

## Step 5: Review

**Mode**: Code

Self-review before opening a PR.

**Prompt**:
```
/code-review
```

This runs the code review command on staged changes. Alternatively, delegate to the code-reviewer subagent for a more thorough review:

```
Use the code-reviewer subagent to review all changes in this branch.
Focus on: bugs, security issues, performance, and adherence to our conventions.
```

**Fix any issues found before proceeding.**

---

## Step 6: Ship

**Mode**: Code

Create a clean commit and PR.

**Generate commit message**:
```
/commit-message
```

**Generate PR description**:
```
/pr-description
```

**Or do it all at once**:
```
Commit all changes with a conventional commit message, then create a PR
with a clear description of what was implemented and how to test it.
```

---

## Checklist

Before marking the feature as done:

- [ ] All requirements are implemented
- [ ] Unit tests pass with adequate coverage
- [ ] Integration tests pass
- [ ] Code review issues are resolved
- [ ] No linting errors (hook should catch this)
- [ ] PR description explains the changes
- [ ] Documentation updated (if applicable)
- [ ] Feature tested manually in development
