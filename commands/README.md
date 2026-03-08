# Claude Code Custom Commands

Custom commands extend Claude Code with reusable, project-specific workflows. They appear in the `/` slash-command menu and can be invoked by any team member who clones the repo.

## What Are Commands?

A command is a Markdown file with YAML frontmatter that lives in `.claude/commands/`. When you type `/` in Claude Code, your custom commands appear alongside the built-in ones. Each command file tells Claude:

- **Which model** to use (`haiku` for fast/cheap tasks, `sonnet` for balanced tasks, `opus` for complex reasoning)
- **Which tools** are allowed (file I/O, bash, web fetch, etc.)
- **What instructions** to follow when the command is invoked

## Installation

Copy any command file into your project's `.claude/commands/` directory:

```bash
# From your project root
mkdir -p .claude/commands

# Copy a single command
cp path/to/claude-code-recipes/commands/code-review.md .claude/commands/

# Or copy all commands at once
cp path/to/claude-code-recipes/commands/*.md .claude/commands/
# (Remove the README.md from .claude/commands/ afterward — it is not a command)
```

Then open Claude Code in your project. Type `/` and you will see your commands listed.

## Frontmatter Reference

```yaml
---
model: sonnet              # haiku | sonnet | opus
description: One-liner     # shown in the /command picker
allowed-tools: []          # optional — restrict tool access
---
```

| Field           | Required | Description                                                                 |
|-----------------|----------|-----------------------------------------------------------------------------|
| `model`         | No       | Which Claude model to use. Defaults to your session model if omitted.       |
| `description`   | Yes      | Short description displayed in the slash-command list.                      |
| `allowed-tools` | No       | Array of tool names. Omit to allow all tools.                               |

## Command Recipes

| # | Command | Model | File | Description |
|---|---------|-------|------|-------------|
| 1 | `/code-review` | sonnet | [code-review.md](code-review.md) | Review staged changes for bugs, security issues, and style violations |
| 2 | `/pr-description` | haiku | [pr-description.md](pr-description.md) | Generate a PR title and description from the current branch diff |
| 3 | `/commit-message` | haiku | [commit-message.md](commit-message.md) | Generate a conventional commit message from staged changes |
| 4 | `/refactor` | sonnet | [refactor.md](refactor.md) | Plan and execute a refactoring with confirmation and tests |
| 5 | `/test-gen` | sonnet | [test-gen.md](test-gen.md) | Generate comprehensive tests for a specified file |
| 6 | `/doc-gen` | haiku | [doc-gen.md](doc-gen.md) | Generate documentation — JSDoc, docstrings, README, or API docs |
| 7 | `/debug` | opus | [debug.md](debug.md) | Systematic debugging: reproduce, isolate, fix, verify, prevent |
| 8 | `/migrate` | opus | [migrate.md](migrate.md) | Migrate between framework versions or languages step by step |
| 9 | `/security-audit` | sonnet | [security-audit.md](security-audit.md) | Scan for OWASP Top 10 vulnerabilities and exposed secrets |
| 10 | `/performance-audit` | sonnet | [performance-audit.md](performance-audit.md) | Find performance bottlenecks across the stack |
| 11 | `/api-gen` | sonnet | [api-gen.md](api-gen.md) | Generate REST API endpoints with validation and tests |
| 12 | `/component-gen` | sonnet | [component-gen.md](component-gen.md) | Generate React/Vue components with types, a11y, and tests |

## Tips

- **Start with haiku** for fast, low-cost tasks (commit messages, PR descriptions). Upgrade to sonnet or opus only when reasoning depth is needed.
- **Use `allowed-tools`** to restrict commands that should not execute code (e.g., a review command that should only read files).
- **Parameterize with `$ARGUMENTS`** — when a user types `/command some text`, the `some text` part is available as `$ARGUMENTS` in your instructions.
- **Combine commands with hooks** — pair a `/commit-message` command with a pre-commit hook for a fully automated workflow.
