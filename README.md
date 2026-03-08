# Claude Code Recipes

> **50+ copy-paste recipes** for Claude Code — commands, subagents, hooks, skills, and MCP configs that work out of the box.

Stop configuring from scratch. Drop these recipes into your `.claude/` folder and start building.

---

## How to Use

1. Browse the recipe catalog below
2. Copy the file you need
3. Paste it into your project's `.claude/` directory:
   - Commands go in `.claude/commands/`
   - Subagents go in `.claude/agents/`
   - Skills go in `.claude/skills/`
   - Hooks go in `.claude/settings.json`
   - MCP configs go in `.mcp.json`
4. Use it immediately — every recipe works out of the box

---

## Recipe Catalog

### Commands (12 recipes)

Drop these into `.claude/commands/` and use them with `/command-name`.

| Recipe | What It Does | Model | Link |
|--------|-------------|:-----:|------|
| `/code-review` | Review staged changes for bugs, style, and security | sonnet | [code-review.md](commands/code-review.md) |
| `/pr-description` | Generate PR title + description from branch diff | haiku | [pr-description.md](commands/pr-description.md) |
| `/commit-message` | Generate conventional commit message | haiku | [commit-message.md](commands/commit-message.md) |
| `/refactor` | Plan and execute a refactoring with safety checks | sonnet | [refactor.md](commands/refactor.md) |
| `/test-gen` | Generate tests for a file or function | sonnet | [test-gen.md](commands/test-gen.md) |
| `/doc-gen` | Generate documentation for code | haiku | [doc-gen.md](commands/doc-gen.md) |
| `/debug` | Systematic debugging: reproduce, isolate, fix, verify | opus | [debug.md](commands/debug.md) |
| `/migrate` | Migrate between framework versions or languages | opus | [migrate.md](commands/migrate.md) |
| `/security-audit` | Scan for OWASP Top 10 vulnerabilities | sonnet | [security-audit.md](commands/security-audit.md) |
| `/performance-audit` | Find performance bottlenecks | sonnet | [performance-audit.md](commands/performance-audit.md) |
| `/api-gen` | Generate REST endpoints from a spec | sonnet | [api-gen.md](commands/api-gen.md) |
| `/component-gen` | Generate React/Vue components from description | sonnet | [component-gen.md](commands/component-gen.md) |

### Subagents (9 recipes)

Drop these into `.claude/agents/` for specialized delegation.

| Recipe | Specialty | Model | Link |
|--------|----------|:-----:|------|
| Researcher | Explore codebase, find patterns, report findings | haiku | [researcher.md](subagents/researcher.md) |
| Test Runner | Run tests, fix failures, report results | sonnet | [test-runner.md](subagents/test-runner.md) |
| Code Reviewer | Thorough review: bugs, style, security, perf | sonnet | [code-reviewer.md](subagents/code-reviewer.md) |
| Frontend Dev | React/Vue/CSS specialist | sonnet | [frontend-dev.md](subagents/frontend-dev.md) |
| Backend Dev | API, database, auth specialist | sonnet | [backend-dev.md](subagents/backend-dev.md) |
| DevOps Engineer | CI/CD, Docker, cloud infrastructure | sonnet | [devops-engineer.md](subagents/devops-engineer.md) |
| Security Analyst | Vulnerability detection and remediation | sonnet | [security-analyst.md](subagents/security-analyst.md) |
| Tech Writer | Documentation, README, API docs | haiku | [tech-writer.md](subagents/tech-writer.md) |
| Database Architect | Schema design, migrations, query optimization | sonnet | [database-architect.md](subagents/database-architect.md) |

### Hooks (5 recipes)

Event-triggered scripts for automation.

| Recipe | Trigger | What It Does | Link |
|--------|---------|-------------|------|
| Pre-commit Lint | Before `git commit` | Run linter and block if errors | [pre-commit-lint.sh](hooks/pre-commit-lint.sh) |
| Post-edit Format | After Claude edits a file | Auto-format with Prettier/Black | [post-edit-format.sh](hooks/post-edit-format.sh) |
| Pre-push Test | Before `git push` | Run test suite and block if failing | [pre-push-test.sh](hooks/pre-push-test.sh) |
| Notification | On task completion | Desktop notification when done | [notification.sh](hooks/notification.sh) |
| Settings Example | -- | Hook configuration for settings.json | [settings-hook-examples.json](hooks/settings-hook-examples.json) |

### Skills (5 recipes)

Reusable knowledge modules — drop the folder into `.claude/skills/`.

| Recipe | Domain | Link |
|--------|--------|------|
| React Patterns | Component patterns, hooks, state management | [react-patterns/](skills/react-patterns/) |
| API Design | REST conventions, status codes, pagination | [api-design/](skills/api-design/) |
| Git Workflow | Branch naming, commit format, PR conventions | [git-workflow/](skills/git-workflow/) |
| Testing Strategy | What to test, how to structure tests | [testing-strategy/](skills/testing-strategy/) |
| TypeScript Strict | Strict mode patterns, type utilities | [typescript-strict/](skills/typescript-strict/) |

### MCP Configs (5 recipes)

Model Context Protocol server configurations for `.mcp.json`.

| Recipe | What It Connects | Link |
|--------|-----------------|------|
| GitHub | Issues, PRs, repos, actions | [github.json](mcp-configs/github.json) |
| Filesystem | Enhanced file operations | [filesystem.json](mcp-configs/filesystem.json) |
| PostgreSQL | Database queries and schema | [postgres.json](mcp-configs/postgres.json) |
| Memory | Persistent key-value memory | [memory.json](mcp-configs/memory.json) |
| Context7 | Library documentation lookup | [context7.json](mcp-configs/context7.json) |

### Workflows (5 recipes)

End-to-end guides combining multiple recipes.

| Recipe | Scenario | Link |
|--------|----------|------|
| New Feature | Plan, implement, test, PR — full cycle | [new-feature.md](workflows/new-feature.md) |
| Bug Fix | Reproduce, isolate, fix, verify, commit | [bug-fix.md](workflows/bug-fix.md) |
| Code Migration | Audit, plan, migrate, test, validate | [code-migration.md](workflows/code-migration.md) |
| PR Review Cycle | Review, request changes, iterate, approve | [pr-review-cycle.md](workflows/pr-review-cycle.md) |
| Project Setup | Configure Claude Code for a new project | [project-setup.md](workflows/project-setup.md) |

### CLAUDE.md Templates (3 recipes)

Optimized project configuration templates.

| Recipe | Best For | Link |
|--------|----------|------|
| Starter | Solo projects, quick setup | [starter.md](claude-md/starter.md) |
| Team Project | Team conventions, CI/CD | [team-project.md](claude-md/team-project.md) |
| Monorepo | Multi-package workspaces | [monorepo.md](claude-md/monorepo.md) |

---

## Quick Reference

See the [cheatsheet](cheatsheet.md) for a one-page summary.

---

## Installation

### One recipe at a time

```bash
# Copy a command
cp claude-code-recipes/commands/code-review.md .claude/commands/

# Copy a subagent
cp claude-code-recipes/subagents/researcher.md .claude/agents/

# Copy a skill
cp -r claude-code-recipes/skills/react-patterns .claude/skills/
```

### All recipes at once

```bash
# Clone and copy everything
git clone https://github.com/Sagargupta16/claude-code-recipes.git /tmp/recipes
cp /tmp/recipes/commands/*.md .claude/commands/
cp /tmp/recipes/subagents/*.md .claude/agents/
cp -r /tmp/recipes/skills/* .claude/skills/
```

---

## Contributing

We welcome recipe contributions! See [CONTRIBUTING.md](CONTRIBUTING.md).

Ways to contribute:
- **Add a recipe**: Commands, subagents, skills, hooks, or MCP configs
- **Improve existing recipes**: Better prompts, additional edge cases
- **Add a workflow**: End-to-end guides for common scenarios
- **Report issues**: Recipes that don't work as expected

---

## Related

- [claude-cost-optimizer](https://github.com/Sagargupta16/claude-cost-optimizer) — Save 30-60% on Claude Code costs
- [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) — Best practices documentation

---

## License

[MIT](LICENSE) — use these recipes however you want.
