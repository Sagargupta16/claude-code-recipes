# Workflow: Project Setup

> Set up Claude Code for a new project: create CLAUDE.md, add commands, configure hooks, and add MCP servers.

Run this workflow once when you start using Claude Code on a project. It takes about 15 minutes and dramatically improves Claude's effectiveness.

---

## Overview

| Phase | What You Set Up | Time |
|-------|----------------|------|
| 1. CLAUDE.md | Project context and conventions | 5 min |
| 2. Commands | Reusable slash commands | 3 min |
| 3. Hooks | Automated linting, formatting, testing | 3 min |
| 4. MCP Servers | External tool integrations | 2 min |
| 5. Skills | Convention knowledge modules | 2 min |

---

## Step 1: Create CLAUDE.md

The `CLAUDE.md` file is your project's instruction manual for Claude. It tells Claude about your tech stack, conventions, and how to work in your codebase.

**Prompt**:
```
Analyze this project and help me create a CLAUDE.md file. Examine:
1. The tech stack (languages, frameworks, major dependencies)
2. Project structure (how code is organized)
3. Build and test commands
4. Existing conventions (naming, patterns, architecture)
5. CI/CD setup

Then generate a CLAUDE.md that captures all of this.
```

**Or start from a template**:

| Template | Best For | Link |
|----------|----------|------|
| Starter | Solo projects, quick setup | [starter.md](../claude-md/starter.md) |
| Team Project | Team conventions, CI/CD | [team-project.md](../claude-md/team-project.md) |
| Monorepo | Multi-package workspaces | [monorepo.md](../claude-md/monorepo.md) |

```bash
# Copy a template and customize it
cp claude-code-recipes/claude-md/starter.md CLAUDE.md
```

**Placement**:
- `CLAUDE.md` in the repo root — loaded for every session
- `some-dir/CLAUDE.md` — loaded when working in that directory

---

## Step 2: Add Commands

Commands are reusable prompts you invoke with `/command-name`. Copy the ones relevant to your workflow.

**Prompt**:
```
Set up Claude Code commands for this project. I want:
- /code-review — review staged changes
- /test-gen — generate tests for a file
- /commit-message — generate commit messages
- /pr-description — generate PR descriptions

Copy the command files and verify they work.
```

**Manual setup**:
```bash
# Create the commands directory
mkdir -p .claude/commands

# Copy commands you want
cp claude-code-recipes/commands/code-review.md .claude/commands/
cp claude-code-recipes/commands/test-gen.md .claude/commands/
cp claude-code-recipes/commands/commit-message.md .claude/commands/
cp claude-code-recipes/commands/pr-description.md .claude/commands/
```

**Recommended starter commands**:

| Command | Why It's Essential |
|---------|-------------------|
| `/code-review` | Catch bugs before committing |
| `/commit-message` | Consistent commit messages |
| `/test-gen` | Fast test generation |
| `/pr-description` | Save time on PR write-ups |

---

## Step 3: Configure Hooks

Hooks automate quality checks — linting before commits, formatting after edits, testing before pushes.

**Prompt**:
```
Set up Claude Code hooks for this project:
1. Pre-commit: run the linter on staged files
2. Post-edit: auto-format files after Claude edits them
3. Pre-push: run the test suite before pushing

Detect which linter, formatter, and test runner this project uses,
then configure the hooks in .claude/settings.json.
```

**Manual setup**:
```bash
# Copy hook scripts
mkdir -p .claude/hooks
cp claude-code-recipes/hooks/pre-commit-lint.sh .claude/hooks/
cp claude-code-recipes/hooks/post-edit-format.sh .claude/hooks/
cp claude-code-recipes/hooks/pre-push-test.sh .claude/hooks/
cp claude-code-recipes/hooks/notification.sh .claude/hooks/
chmod +x .claude/hooks/*.sh

# Create settings.json with hook config
# (see hooks/settings-hook-examples.json for the full config)
```

Then add hook configuration to `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "git_commit",
        "command": "bash .claude/hooks/pre-commit-lint.sh"
      },
      {
        "matcher": "git_push",
        "command": "bash .claude/hooks/pre-push-test.sh"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "file_edit|create_file",
        "command": "bash .claude/hooks/post-edit-format.sh"
      }
    ],
    "Notification": [
      {
        "command": "bash .claude/hooks/notification.sh"
      }
    ]
  }
}
```

---

## Step 4: Add MCP Servers

MCP servers give Claude access to external tools — GitHub, databases, documentation.

**Prompt**:
```
Set up MCP servers for this project. I want:
- GitHub integration (for issues and PRs)
- Memory (for persistent context across sessions)
- [Context7 / PostgreSQL / other based on your stack]

Create the .mcp.json configuration file.
```

**Manual setup**:
```bash
# Create .mcp.json in the project root
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
EOF
```

**Which servers to add**:

| Server | Add If You... |
|--------|---------------|
| GitHub | Use GitHub for code hosting |
| Memory | Want Claude to remember context across sessions |
| PostgreSQL | Have a database Claude should query |
| Context7 | Work with libraries Claude needs docs for |
| Filesystem | Need enhanced file operations |

---

## Step 5: Add Skills

Skills teach Claude your team's conventions without repeating them every session.

**Prompt**:
```
Set up skills for this project based on our tech stack:
- If we use React: add the react-patterns skill
- If we use TypeScript: add the typescript-strict skill
- Add the testing-strategy skill
- Add the git-workflow skill
```

**Manual setup**:
```bash
# Copy relevant skills
mkdir -p .claude/skills
cp -r claude-code-recipes/skills/git-workflow .claude/skills/
cp -r claude-code-recipes/skills/testing-strategy .claude/skills/

# Add tech-specific skills
cp -r claude-code-recipes/skills/react-patterns .claude/skills/       # if React
cp -r claude-code-recipes/skills/typescript-strict .claude/skills/    # if TypeScript
cp -r claude-code-recipes/skills/api-design .claude/skills/           # if building APIs
```

---

## Final Structure

After setup, your project should have:

```
project-root/
  CLAUDE.md                          # Project context
  .mcp.json                          # MCP server configs
  .claude/
    settings.json                    # Hook configurations
    commands/
      code-review.md
      commit-message.md
      test-gen.md
      pr-description.md
    hooks/
      pre-commit-lint.sh
      post-edit-format.sh
      pre-push-test.sh
      notification.sh
    skills/
      git-workflow/SKILL.md
      testing-strategy/SKILL.md
      react-patterns/SKILL.md        # if applicable
      typescript-strict/SKILL.md     # if applicable
```

---

## Verification

Test that everything works:

```
1. Ask Claude to make a small edit -> post-edit format hook should run
2. Ask Claude to commit -> pre-commit lint hook should run
3. Run /code-review -> command should work
4. Run /test-gen on a file -> command should generate tests
5. Check that Claude knows your conventions (ask about your stack)
```

---

## Checklist

- [ ] CLAUDE.md created with accurate project info
- [ ] Essential commands copied to `.claude/commands/`
- [ ] Hooks configured in `.claude/settings.json`
- [ ] MCP servers added to `.mcp.json`
- [ ] Skills added for your tech stack
- [ ] All hook scripts are executable (`chmod +x`)
- [ ] `.mcp.json` is in `.gitignore` (if it contains secrets)
- [ ] Everything verified with a quick test
