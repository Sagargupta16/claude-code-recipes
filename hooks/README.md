# Hooks

> Event-triggered scripts that run automatically during Claude Code sessions.

Hooks let you automate repetitive tasks — linting before commits, formatting after edits, running tests before pushes, and sending notifications when work is done. They run as shell scripts triggered by specific events in your Claude Code workflow.

---

## How Hooks Work

Claude Code hooks are configured in `.claude/settings.json` (project-level) or `~/.claude/settings.json` (global). Each hook has:

- **Event**: When the hook fires (`PreToolUse`, `PostToolUse`, `Notification`, etc.)
- **Matcher**: Optional filter for which tool triggers it (e.g., only on `git_commit`)
- **Command**: The shell command or script to run

When the event fires and the matcher matches, Claude Code executes your script. If the script exits with a non-zero code, the triggering action is blocked (for "pre" hooks).

---

## Available Hooks

| Hook | Event | What It Does | File |
|------|-------|-------------|------|
| Pre-commit Lint | `PreToolUse` (git commit) | Runs linter, blocks commit on errors | [pre-commit-lint.sh](pre-commit-lint.sh) |
| Post-edit Format | `PostToolUse` (file edit) | Auto-formats files after Claude edits | [post-edit-format.sh](post-edit-format.sh) |
| Pre-push Test | `PreToolUse` (git push) | Runs test suite, blocks push on failures | [pre-push-test.sh](pre-push-test.sh) |
| Notification | `Notification` | Desktop notification when tasks complete | [notification.sh](notification.sh) |
| Settings Example | -- | Complete settings.json with all hooks | [settings-hook-examples.json](settings-hook-examples.json) |

---

## Installation

### 1. Copy the hook scripts

```bash
# Copy all hook scripts to your project
mkdir -p .claude/hooks
cp claude-code-recipes/hooks/*.sh .claude/hooks/
chmod +x .claude/hooks/*.sh
```

### 2. Configure settings.json

Add hook definitions to `.claude/settings.json`. See [settings-hook-examples.json](settings-hook-examples.json) for the full configuration, or copy the relevant section:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "git_commit",
        "command": ".claude/hooks/pre-commit-lint.sh"
      }
    ]
  }
}
```

### 3. Verify

Trigger the event (e.g., ask Claude to commit) and confirm the hook runs.

---

## Writing Custom Hooks

Hook scripts receive context via environment variables and stdin:

| Variable | Description |
|----------|-------------|
| `$CLAUDE_TOOL_NAME` | Name of the tool being used |
| `$CLAUDE_FILE_PATH` | Path to the affected file (if applicable) |
| `$CLAUDE_PROJECT_DIR` | Root directory of the project |
| `stdin` | JSON payload with full event details |

### Exit Codes

- **Exit 0**: Hook passed, action proceeds
- **Exit 1**: Hook failed, action is blocked (for "pre" hooks)
- **Exit 2**: Hook encountered a warning (action proceeds, message shown)

### Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read event payload from stdin
PAYLOAD=$(cat)

# Extract fields from the JSON payload
TOOL_NAME=$(echo "$PAYLOAD" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.file_path // empty')

# Your logic here
echo "Hook triggered for: $TOOL_NAME on $FILE_PATH"

# Exit 0 to allow, exit 1 to block
exit 0
```

---

## Tips

- Keep hooks **fast** — they run synchronously and block Claude's workflow
- Use `set -euo pipefail` to catch errors early
- Log output goes to the Claude Code console for debugging
- Test hooks manually before adding them: `echo '{}' | bash .claude/hooks/your-hook.sh`
- Hooks run from the project root directory
