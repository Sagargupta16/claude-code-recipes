# Claude Code Recipes — Cheatsheet

> One-page quick reference. For full docs, see the [README](README.md).

---

## Commands

Copy to `.claude/commands/` and invoke with `/command-name`.

```bash
mkdir -p .claude/commands
cp commands/code-review.md .claude/commands/
```

| Command | What It Does |
|---------|-------------|
| `/code-review` | Review staged changes for bugs, style, security |
| `/pr-description` | Generate PR title + description from branch diff |
| `/commit-message` | Generate conventional commit message |
| `/refactor` | Plan and execute a refactoring safely |
| `/test-gen` | Generate tests for a file or function |
| `/doc-gen` | Generate documentation for code |
| `/debug` | Systematic debugging workflow |
| `/migrate` | Migrate between framework versions or languages |
| `/security-audit` | Scan for OWASP Top 10 vulnerabilities |
| `/performance-audit` | Find performance bottlenecks |
| `/api-gen` | Generate REST endpoints from a spec |
| `/component-gen` | Generate React/Vue components |

---

## Subagents

Copy to `.claude/agents/` for specialized delegation.

```bash
mkdir -p .claude/agents
cp subagents/researcher.md .claude/agents/
```

| Agent | Specialty |
|-------|----------|
| Researcher | Explore codebase, find patterns, report |
| Test Runner | Run tests, fix failures, report results |
| Code Reviewer | Thorough review: bugs, style, security, perf |
| Frontend Dev | React/Vue/CSS specialist |
| Backend Dev | API, database, auth specialist |
| DevOps Engineer | CI/CD, Docker, cloud infrastructure |
| Security Analyst | Vulnerability detection, remediation |
| Tech Writer | Documentation, README, API docs |
| Database Architect | Schema design, migrations, queries |

---

## Hooks

Copy to `.claude/hooks/` and configure in `.claude/settings.json`.

```bash
mkdir -p .claude/hooks
cp hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

| Hook | Event | Purpose |
|------|-------|---------|
| `pre-commit-lint.sh` | Before commit | Lint staged files, block on errors |
| `post-edit-format.sh` | After file edit | Auto-format edited files |
| `pre-push-test.sh` | Before push | Run tests, block on failures |
| `notification.sh` | Task complete | Desktop notification |

Settings config: see [settings-hook-examples.json](hooks/settings-hook-examples.json)

---

## Skills

Copy to `.claude/skills/` for convention knowledge.

```bash
mkdir -p .claude/skills
cp -r skills/react-patterns .claude/skills/
```

| Skill | Domain |
|-------|--------|
| `react-patterns/` | Components, hooks, state, performance, a11y |
| `api-design/` | REST conventions, status codes, pagination |
| `git-workflow/` | Branch naming, commits, PRs, merge strategy |
| `testing-strategy/` | Test types, structure, mocking, coverage |
| `typescript-strict/` | Strict config, type patterns, error handling |

---

## MCP Configs

Add to `.mcp.json` in your project root.

```bash
# Create .mcp.json and merge configs from mcp-configs/*.json
```

| Server | Service |
|--------|---------|
| `github` | GitHub issues, PRs, repos |
| `filesystem` | Enhanced file operations |
| `postgres` | PostgreSQL database queries |
| `memory` | Persistent knowledge graph |
| `context7` | Library documentation lookup |

---

## Workflows

Reference guides for end-to-end development scenarios.

| Workflow | Scenario |
|----------|----------|
| [New Feature](workflows/new-feature.md) | Plan -> implement -> test -> PR |
| [Bug Fix](workflows/bug-fix.md) | Reproduce -> isolate -> fix -> test -> commit |
| [Code Migration](workflows/code-migration.md) | Audit -> plan -> migrate -> test -> validate |
| [PR Review](workflows/pr-review-cycle.md) | Review -> request changes -> iterate -> approve |
| [Project Setup](workflows/project-setup.md) | CLAUDE.md -> commands -> hooks -> MCP -> skills |

---

## CLAUDE.md Templates

Copy to your project root as `CLAUDE.md`.

| Template | Best For |
|----------|----------|
| [Starter](claude-md/starter.md) | Solo projects, ~40 lines |
| [Team Project](claude-md/team-project.md) | Team conventions, ~100 lines |
| [Monorepo](claude-md/monorepo.md) | Multi-package workspaces, ~80 lines |

---

## Quick Install — Everything at Once

```bash
# Clone the recipes
git clone https://github.com/Sagargupta16/claude-code-recipes.git /tmp/recipes

# Commands
mkdir -p .claude/commands
cp /tmp/recipes/commands/*.md .claude/commands/

# Subagents
mkdir -p .claude/agents
cp /tmp/recipes/subagents/*.md .claude/agents/

# Skills
mkdir -p .claude/skills
cp -r /tmp/recipes/skills/react-patterns .claude/skills/
cp -r /tmp/recipes/skills/api-design .claude/skills/
cp -r /tmp/recipes/skills/git-workflow .claude/skills/
cp -r /tmp/recipes/skills/testing-strategy .claude/skills/
cp -r /tmp/recipes/skills/typescript-strict .claude/skills/

# Hooks
mkdir -p .claude/hooks
cp /tmp/recipes/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh

# CLAUDE.md (pick one template)
cp /tmp/recipes/claude-md/starter.md CLAUDE.md

# Clean up
rm -rf /tmp/recipes
```
