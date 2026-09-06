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
# (Remove the README.md from .claude/commands/ afterward -- it is not a command)
```

Then open Claude Code in your project. Type `/` and you will see your commands listed.

## Frontmatter Reference

```yaml
---
model: sonnet                 # haiku | sonnet | opus
description: One-liner        # shown in the /command picker
argument-hint: [file-path]    # shown during autocomplete
allowed-tools:                # pre-approves these for the invoking turn
  - Bash(git status *)
  - Read
disallowed-tools:             # actually removes tools from the pool
  - WebFetch
---
```

| Field              | Required | Description                                                                                          |
|--------------------|----------|------------------------------------------------------------------------------------------------------|
| `description`      | Yes      | Short description displayed in the slash-command list. Required by this repo; Claude Code falls back to the first paragraph of the body if you omit it. |
| `model`            | No       | Which Claude model to use. Defaults to your session model if omitted. Optional in Claude Code, but every recipe in this repo sets one so the index tables can list it. |
| `argument-hint`    | No       | Autocomplete hint for expected arguments, e.g. `[issue-number]` or `[file] [format]`.                |
| `arguments`        | No       | Named positional arguments, for `$name` substitution in the body.                                    |
| `allowed-tools`    | No       | Tools Claude may use **without asking permission** during the turn that invokes the command. This does not restrict anything: every other tool stays callable, and the grant clears on your next message. |
| `disallowed-tools` | No       | Tools **removed** from Claude's pool while the command is active. This is the field that restricts.   |
| `effort`           | No       | `low`, `medium`, `high`, `xhigh`, or `max` for this command.                                          |
| `context`          | No       | Set to `fork` to run the command in a forked subagent context.                                        |
| `agent`            | No       | Which subagent type to use when `context: fork` is set.                                              |

> The opening `---` must be the file's **first line**. Otherwise Claude Code reads the whole file, `---` markers included, as command content and ignores every field above.

Both tool fields accept a YAML list (as above), or a space- or comma-separated string. Entries can be bare tool names (`Read`, `Grep`) or permission rules that narrow a tool to specific commands: `Bash(git add *)`, `Bash(gh *)`, `Bash(npm run test *)`.

## Command Recipes

| # | Command | Model | File | Description |
|---|---------|-------|------|-------------|
| 1 | `/code-review` | sonnet | [code-review.md](code-review.md) | Review staged changes for bugs, security issues, and style violations |
| 2 | `/pr-description` | haiku | [pr-description.md](pr-description.md) | Generate a PR title and description from the current branch diff |
| 3 | `/commit-message` | haiku | [commit-message.md](commit-message.md) | Generate a conventional commit message from staged changes |
| 4 | `/refactor` | sonnet | [refactor.md](refactor.md) | Plan and execute a refactoring with confirmation and tests |
| 5 | `/test-gen` | sonnet | [test-gen.md](test-gen.md) | Generate comprehensive tests for a specified file |
| 6 | `/doc-gen` | haiku | [doc-gen.md](doc-gen.md) | Generate documentation -- JSDoc, docstrings, README, or API docs |
| 7 | `/debug` | opus | [debug.md](debug.md) | Systematic debugging: reproduce, isolate, fix, verify, prevent |
| 8 | `/migrate` | opus | [migrate.md](migrate.md) | Migrate between framework versions or languages step by step |
| 9 | `/security-audit` | sonnet | [security-audit.md](security-audit.md) | Scan for OWASP Top 10 vulnerabilities and exposed secrets |
| 10 | `/performance-audit` | sonnet | [performance-audit.md](performance-audit.md) | Find performance bottlenecks across the stack |
| 11 | `/api-gen` | sonnet | [api-gen.md](api-gen.md) | Generate REST API endpoints with validation and tests |
| 12 | `/component-gen` | sonnet | [component-gen.md](component-gen.md) | Generate React/Vue components with types, a11y, and tests |
| 13 | `/check-all-prs` | haiku | [check-all-prs.md](check-all-prs.md) | Check all your open PRs across GitHub repos |
| 14 | `/audit-repos` | sonnet | [audit-repos.md](audit-repos.md) | Audit all repos for health, hygiene, and security issues |
| 15 | `/update-status` | sonnet | [update-status.md](update-status.md) | Refresh a STATUS.md dashboard with live GitHub data |

### GitHub commands: prerequisites

`/check-all-prs`, `/audit-repos`, and `/update-status` shell out to the `gh` CLI, so they need [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth login`). All three are read-only against GitHub: they never push, comment, or merge. `/update-status` writes `STATUS.md` in your repo root and leaves the change uncommitted for review.

- `/audit-repos` covers public repos by default; pass an argument to include private ones. Expect it to take a couple of minutes across a large account, since it makes several API calls per repo. Change its `model` to `haiku` if you would rather trade depth for cost on a routine sweep.
- `/update-status` is aimed at multi-repo workspaces where a single dashboard file tracks everything. Run it at the start of a session.
- `/check-all-prs` pairs with `/update-status`: run the check for the live picture, then fold the result into `STATUS.md`.

## Tips

- **Start with haiku** for fast, low-cost tasks (commit messages, PR descriptions). Upgrade to sonnet or opus only when reasoning depth is needed.
- **Use `disallowed-tools`, not `allowed-tools`, to restrict** a command that should not execute code. `allowed-tools` only pre-approves tools so Claude stops asking; it never takes a tool away. A review command with `allowed-tools: Read` can still run Bash.
- **Use `allowed-tools` with narrow rules** to kill permission prompts for the commands you run constantly: `Bash(git diff *)` on a review command, `Bash(gh *)` on a PR command.
- **Parameterize with `$ARGUMENTS`** -- when a user types `/command some text`, the `some text` part is available as `$ARGUMENTS` in your instructions.
- **Combine commands with hooks** -- pair a `/commit-message` command with a pre-commit hook for a fully automated workflow.
