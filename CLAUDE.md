# Claude Code Recipes — Project Config

## Project

This is a recipe collection repository for Claude Code. It contains copy-paste commands, subagents, hooks, skills, MCP configs, workflows, and CLAUDE.md templates. There is no application code — only Markdown files, shell scripts, and JSON configs.

## Structure

```
commands/          # Slash commands (.md) for .claude/commands/
subagents/         # Agent definitions (.md) for .claude/agents/
hooks/             # Shell scripts (.sh) and settings examples for hooks
skills/            # SKILL.md files organized in subdirectories
mcp-configs/       # MCP server configuration (.json) for .mcp.json
workflows/         # End-to-end workflow guides (.md)
claude-md/         # CLAUDE.md templates for different project types
```

## Conventions

- Every recipe must work out of the box — no setup beyond copying the file
- Markdown files use standard GitHub-Flavored Markdown
- Shell scripts use `#!/usr/bin/env bash` and `set -euo pipefail`
- JSON files include `_comment` fields for documentation
- Each directory has a README.md index explaining its contents
- File names use kebab-case: `code-review.md`, `pre-commit-lint.sh`
- Skills use `SKILL.md` (uppercase) inside a kebab-case directory

## Writing Style

- Be specific and actionable — concrete rules over vague principles
- Include examples (good and bad) in skills and commands
- Keep recipes self-contained — don't require reading other files
- Use imperative mood in instructions: "Run the tests" not "You should run the tests"
- No emojis in file content

## Do NOT

- Add application code — this is a recipe collection, not a framework
- Create deeply nested directory structures — keep it flat
- Write recipes that require specific API keys or paid services to function
- Include project-specific conventions — recipes must be generic
