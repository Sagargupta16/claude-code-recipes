# Contributing to Claude Code Recipes

Thank you for contributing! This guide explains how to add recipes, improve existing ones, and get your PR merged.

---

## Ways to Contribute

| Contribution | Description |
|-------------|-------------|
| **New recipe** | Add a command, subagent, skill, hook, MCP config, or workflow |
| **Improve a recipe** | Better prompts, additional edge cases, clearer instructions |
| **Fix a bug** | Recipe that doesn't work as expected |
| **Add a template** | New CLAUDE.md template for a specific use case |
| **Documentation** | Improve README files, add examples, fix typos |

---

## Adding a New Recipe

### 1. Choose the right category

| Category | Directory | File Format | Use Case |
|----------|-----------|-------------|----------|
| Command | `commands/` | `name.md` | Slash commands for Claude Code |
| Subagent | `subagents/` | `name.md` | Specialized agent definitions |
| Skill | `skills/name/` | `SKILL.md` | Convention knowledge modules |
| Hook | `hooks/` | `name.sh` | Event-triggered automation |
| MCP Config | `mcp-configs/` | `name.json` | External tool integrations |
| Workflow | `workflows/` | `name.md` | End-to-end development guides |
| Template | `claude-md/` | `name.md` | CLAUDE.md templates |

### 2. Follow the format requirements

#### Commands (`commands/*.md`)

```markdown
---
model: [haiku|sonnet|opus]
description: One-line description shown in command list
allowed-tools:
  - Bash(git diff *)
---

[System prompt for the command]

$ARGUMENTS - if the command accepts input
```

- The opening `---` must be the file's first line, or the frontmatter is read as body text
- Must specify a model (haiku for simple tasks, sonnet for complex, opus for deep analysis)
- Must include `$ARGUMENTS` if the command takes user input
- Must work without any project-specific setup
- The body is the prompt itself. Do not wrap it in a nested code fence or add "save this file as ..." instructions: the file *is* the command
- `allowed-tools` pre-approves tools so Claude stops asking. It does not restrict anything; use `disallowed-tools` for that

#### Subagents (`subagents/*.md`)

```markdown
---
name: agent-name
model: [haiku|sonnet|opus]
description: One-line description
tools: Read, Glob, Grep
disallowedTools: Write, Edit
---

# Role

[Who this agent is and what it specializes in]

# Instructions

[Step-by-step instructions for the agent]

# Output Format

[How the agent should format its response]
```

- `name` and `description` are required. A file with a `name` and no `description` is skipped, and the reason only shows under `--debug`
- The allowlist field is `tools`, a **comma-separated string**. There is no `allowed-tools` field for subagents: it is an unrecognized key, so the agent silently inherits every tool including `Edit` and `Write`
- Add `disallowedTools: Write, Edit` to any agent whose description promises it is read-only
- Must define a clear role and specialty
- Must include structured output format
- Should handle edge cases gracefully

#### Skills (`skills/name/SKILL.md`)

```markdown
---
name: skill-name
description: What this skill covers and when Claude should apply it
---

# Skill Name

> One-line description

## Rules

1. Rule with rationale
2. Rule with rationale

## Patterns

### Pattern Name
[Example code - good and bad]

## Anti-patterns
- Thing to avoid - why
```

- Must open with YAML frontmatter on line 1. `description` is what drives auto-triggering, so write it as "what it covers plus when to use it"
- Must be domain-specific (one topic per skill)
- Must include concrete examples (good and bad)
- Must explain *why*, not just *what*
- Keep under 350 lines

#### Hooks (`hooks/*.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

# Description comment block
# Supported tools: [list]
# Install: instructions
```

- Must use `#!/usr/bin/env bash` shebang
- Must use `set -euo pipefail`
- Must auto-detect tools (don't hardcode paths)
- Must exit 0 on success and **2** to block. Exit 1 does not block: the action proceeds and the transcript just shows a hook error notice
- Must read event data from the JSON payload on stdin (`.tool_name`, `.tool_input.file_path`, `.tool_input.command`), not from invented `CLAUDE_*` variables
- Must handle missing tools gracefully (skip, don't crash)

#### MCP Configs (`mcp-configs/*.json`)

```json
{
  "_comment": ["Description", "Requirements", "Install instructions", "Docs: <url>"],
  "server-name": {
    "command": "npx",
    "args": ["-y", "@scope/package"],
    "env": { ... }
  }
}
```

- Must include `_comment` with description and requirements
- Must use environment variables for secrets (never hardcode)
- Must list available tools in `tools._available`
- Remote servers need `"type": "http"` alongside `url`. An entry with a `url` and no `type` is read as a stdio server and skipped
- Must not install a package npm marks deprecated. Check with `npm view <package> deprecated` before you submit
- The `Docs:` URL must return 200

#### Workflows (`workflows/*.md`)

```markdown
# Workflow: Name

> One-line description

## Overview
[Table with phases, modes, recipes used, time estimates]

## Step N: Title
**Mode**: [`plan` | `default`]
[Instructions with example prompts]

## Checklist
- [ ] Verification items
```

- Must include an overview table
- Must specify a real permission mode for each step (`default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`). "Code mode" is not one of them
- Must reference specific recipes to use at each step
- Must end with a verification checklist

### 3. Update the index

Add your recipe to:
- The category's `README.md` file
- The root `README.md` recipe catalog table
- The `cheatsheet.md` quick reference

### 4. Test your recipe

Before submitting, verify that:

- [ ] The recipe works out of the box (no extra setup required)
- [ ] File names use kebab-case
- [ ] Markdown renders correctly on GitHub
- [ ] Shell scripts are executable and pass `shellcheck`
- [ ] JSON files are valid (no trailing commas, proper escaping)
- [ ] The recipe doesn't require paid services or specific API keys
- [ ] Examples are generic (not tied to a specific project)

---

## PR Guidelines

### Branch naming

```
feat/add-[recipe-name]-[category]
fix/[recipe-name]-[description]
docs/[description]
```

### Commit format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(commands): add database-migration command
fix(hooks): handle missing eslint in pre-commit
docs(skills): add error handling examples to typescript-strict
```

### PR description

Include:
- **What**: Which recipe you're adding or changing
- **Why**: What problem it solves or what it improves
- **Testing**: How you verified it works

### Review process

1. Open a PR against `main`
2. Ensure the recipe follows format requirements
3. A maintainer will review within a few days
4. Address any feedback
5. PR is squash-merged

---

## Style Guide

- **Language**: Write in clear, direct English
- **Mood**: Use imperative mood ("Run the tests" not "You should run the tests")
- **Formatting**: Use standard GitHub-Flavored Markdown
- **Code blocks**: Always specify the language (`typescript`, `bash`, `json`)
- **No emojis**: Keep content professional and accessible
- **Line length**: Wrap prose at ~100 characters (not enforced strictly)
- **Examples**: Always include both "good" and "bad" examples where relevant

---

## Questions?

Open an issue if you're unsure about:
- Which category a recipe belongs in
- Whether a recipe idea is in scope
- How to format something

We're happy to help!
