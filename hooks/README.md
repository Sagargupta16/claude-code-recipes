# Hooks

> Event-triggered scripts that run automatically during Claude Code sessions.

Hooks let you automate repetitive tasks -- linting before commits, formatting after edits, running tests before pushes, and sending notifications when work is done. They run as shell scripts triggered by specific events in your Claude Code workflow.

---

## How Hooks Work

Claude Code hooks are configured in `.claude/settings.json` (project-level) or `~/.claude/settings.json` (global). The config has three levels of nesting:

1. **Event**: when the hook fires (`PreToolUse`, `PostToolUse`, `Notification`, `Stop`, etc.)
2. **Matcher group**: a filter for when it fires. On tool events the matcher matches the **tool name**, not a git subcommand: `Bash`, `Edit|Write`, `mcp__.*`. A value made only of letters, digits, `_`, `-`, spaces, `,` and `|` is compared as an exact string (or a list of exact strings), so `bash` matches nothing and `Bash` matches the Bash tool. Anything with another character is treated as an unanchored regular expression. Omit the matcher, or use `*`, to match every occurrence of the event.
3. **Handler array**: one or more handlers under a `hooks` key. Every handler needs a `type`; `"command"` runs a shell command. Add `if` with permission-rule syntax (`Bash(git commit *)`, `Edit(*.ts)`) to narrow a handler further.

When the event fires and the matcher matches, Claude Code runs your handler. Blocking is by **exit code 2**, not by any non-zero code: see [Exit Codes](#exit-codes) below.

---

## Available Hooks

| Hook | Event | Matcher | What It Does | File |
|------|-------|---------|-------------|------|
| Pre-commit Lint | `PreToolUse` | `Bash` + `if: Bash(git commit *)` | Runs linter, blocks commit on errors | [pre-commit-lint.sh](pre-commit-lint.sh) |
| Post-edit Format | `PostToolUse` | `Edit\|Write` | Auto-formats files after Claude edits | [post-edit-format.sh](post-edit-format.sh) |
| Pre-push Test | `PreToolUse` | `Bash` + `if: Bash(git push *)` | Runs test suite, blocks push on failures | [pre-push-test.sh](pre-push-test.sh) |
| Notification | `Notification` | (none) | Desktop notification when tasks complete | [notification.sh](notification.sh) |
| Dangerous Command Guard | `PreToolUse` | `Bash` | Blocks `rm -rf /` and `~`, `mkfs`, `dd` onto a disk, `git push --force` without a lease, `curl \| sh`, and `DROP` / `TRUNCATE` sent to a SQL client | [block-dangerous-commands.sh](block-dangerous-commands.sh) |
| Secret Scan | `PreToolUse` | `Edit\|Write\|NotebookEdit` | Blocks an edit that would write an AWS, GitHub, Slack, Stripe, Google, Anthropic or OpenAI key, or a private key, to disk | [secret-scan.sh](secret-scan.sh) |
| Settings Example | -- | -- | Complete settings.json with all hooks | [settings-hook-examples.json](settings-hook-examples.json) |

All of them except the settings example also install as two plugins, `recipe-hooks` (lint, format, test, notify) and `recipe-guards` (the two security hooks). See [Install as plugins](../README.md#install-as-plugins).

### The two guard hooks

`block-dangerous-commands.sh` splits a command on `;`, `&&`, `||` and `|` before judging it, so `rm -rf build && ls /` is two harmless commands, not one `rm` aimed at `/`. It only treats `DROP TABLE` as dangerous when a SQL client (`psql`, `mysql`, `sqlite3`, ...) is on the line, so a commit message that mentions it is not blocked. It is a seatbelt against a model mistake, not a sandbox: pair it with `permissions.deny` rules for anything that must never run.

`secret-scan.sh` reads the text the tool is about to write (`content` on Write, `new_string` on Edit, `new_source` on NotebookEdit) and runs before the file changes, so a key never reaches the disk or a later commit. Its block message names the rule and the file but never the matched value, because stderr goes back into the conversation. The AWS documentation key `AKIAIOSFODNN7EXAMPLE` is allowed.

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
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git commit *)",
            "command": "bash .claude/hooks/pre-commit-lint.sh"
          }
        ]
      }
    ]
  }
}
```

### 3. Verify

Trigger the event (e.g., ask Claude to commit) and confirm the hook runs. If nothing happens, run `claude --debug` and check the debug log: a hook whose matcher never matches fails silently. See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md#my-hook-never-fires).

---

## Writing Custom Hooks

Hook scripts get everything about the event from the **JSON payload on stdin**. There is no `$CLAUDE_TOOL_NAME` and no `$CLAUDE_FILE_PATH`; read `.tool_name` and `.tool_input.file_path` from stdin instead.

### Payload fields

| Field | Description |
|-------|-------------|
| `.hook_event_name` | The event that fired (`PreToolUse`, `PostToolUse`, ...) |
| `.tool_name` | Name of the tool being used (`Bash`, `Edit`, `Write`, ...) |
| `.tool_input.file_path` | Path to the affected file, on `Edit` / `Write` |
| `.tool_input.command` | The command string, on `Bash` |
| `.cwd` | Directory the session is working in |
| `.session_id` | Identifier for the current session |

### Environment variables

A hook process inherits the parent environment, apart from the `OTEL_*` exporter variables Claude Code strips from every subprocess it spawns. On top of that, Claude Code sets:

| Variable | Description |
|----------|-------------|
| `$CLAUDE_PROJECT_DIR` | Project root where the session started |
| `$CLAUDE_PLUGIN_ROOT` | Plugin install directory (plugin hooks only) |
| `$CLAUDE_PLUGIN_DATA` | Plugin data directory that survives updates (plugin hooks only) |
| `$CLAUDE_EFFORT` | Effort level of the current session |
| `$CLAUDE_CODE_REMOTE` | `"true"` in remote web environments, unset in the local CLI |
| `$CLAUDE_CODE_BRIDGE_SESSION_ID` | Remote Control session ID, when one is connected |
| `$CLAUDE_PLUGIN_OPTION_<KEY>` | Value of a plugin option, e.g. `$CLAUDE_PLUGIN_OPTION_WEBHOOK_URL` for a `webhook_url` option |

None of them carry the event. That data is on stdin.

### Exit Codes

- **Exit 0**: success, the action proceeds
- **Exit 2**: blocking error. On `PreToolUse` this blocks the tool call; the message shown is your stderr
- **Any other non-zero**: non-blocking error. The action **still proceeds** and the transcript shows a hook error notice with the first line of stderr

Exit 2 is the only code that blocks on its own. If a hook is meant to enforce a policy, it must `exit 2`.

### Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read event payload from stdin
PAYLOAD=$(cat)

# Extract fields from the JSON payload
TOOL_NAME=$(echo "$PAYLOAD" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

# Your logic here
echo "Hook triggered for: $TOOL_NAME on $FILE_PATH"

# Exit 0 to allow, exit 2 to block
exit 0
```

---

## Tips

- Keep hooks **fast** -- they run synchronously and block Claude's workflow
- Use `set -euo pipefail` to catch errors early
- Stdout from a hook that exits 0 goes to the debug log, not the transcript. Run `claude --debug` to see it
- A hook that blocks must put the reason on **stderr**, diagnostics included. `pre-commit-lint.sh` and `pre-push-test.sh` do it with one `exec 1>&2` at the top, so the linter output lands next to the verdict instead of in the debug log
- Test hooks manually before adding them, feeding a realistic payload rather than `{}`:
  `echo '{"tool_name":"Edit","tool_input":{"file_path":"src/index.ts"}}' | bash .claude/hooks/your-hook.sh`
- Hooks run from the project root directory

---

## How These Hooks Are Tested

[scripts/test-hooks.sh](../scripts/test-hooks.sh) replays payloads in the shape Claude Code sends on stdin against every script here, and asserts the exit code and the stderr text Claude would see. CI runs it on Ubuntu, macOS (bash 3.2) and Windows (Git Bash).

The linters, test runners and notifiers a hook calls are replaced by stubs on `PATH`, so a case can force "ruff found errors" or "pytest collected no tests" without installing either. Each stub records its arguments, which is how the notification case proves a hostile message reached `notify-send`, `osascript` or PowerShell as data rather than as script source. The suite also runs the plugin hook commands from `.claude-plugin/marketplace.json` exactly as written, with `CLAUDE_PLUGIN_ROOT` set, so a wrong path in a plugin entry fails too.

```bash
bash scripts/test-hooks.sh
```

Put back the pre-fix `notification.sh` or `pre-push-test.sh` from 1.1.0 and the suite fails on the injection case and the pytest exit 5 case.
