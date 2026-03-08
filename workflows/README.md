# Workflows

> End-to-end guides that combine multiple Claude Code recipes into complete development workflows.

Workflows show you how to chain commands, subagents, hooks, and skills together for real-world scenarios. Each workflow walks through a full development cycle from start to finish.

---

## Available Workflows

| Workflow | Scenario | Steps | Link |
|----------|----------|:-----:|------|
| New Feature | Build a feature from scratch | 6 | [new-feature.md](new-feature.md) |
| Bug Fix | Find, fix, and verify a bug | 5 | [bug-fix.md](bug-fix.md) |
| Code Migration | Migrate between frameworks or versions | 6 | [code-migration.md](code-migration.md) |
| PR Review Cycle | Review, iterate, and approve a PR | 5 | [pr-review-cycle.md](pr-review-cycle.md) |
| Project Setup | Configure Claude Code for a new project | 5 | [project-setup.md](project-setup.md) |

---

## How to Use Workflows

Workflows are reference guides, not scripts. Use them by:

1. **Reading the workflow** for your current task
2. **Following the steps** in order, adapting to your project
3. **Using the suggested recipes** at each step (commands, subagents, etc.)
4. **Skipping steps** that don't apply to your situation

### Workflow Notation

Each workflow uses this format:

- **Step title** — what to do
- **Mode** — which Claude Code mode to use (Plan, Code, or auto)
- **Recipes** — which commands, subagents, or tools to use
- **Example prompts** — copy-paste prompts to get started

---

## Combining Workflows

Workflows can be chained. Common combinations:

| Situation | Workflow Chain |
|-----------|---------------|
| New project, first feature | Project Setup -> New Feature |
| Bug reported in production | Bug Fix -> PR Review Cycle |
| Framework upgrade | Code Migration -> PR Review Cycle |
| New feature with review | New Feature -> PR Review Cycle |

---

## Tips

- Workflows are guidelines, not rigid scripts — adapt them to your project
- Use Plan mode for analysis and strategy, Code mode for implementation
- Delegate specialized work to subagents (test runner, code reviewer, etc.)
- Run hooks automatically instead of remembering manual steps
- Review each step's output before moving to the next
