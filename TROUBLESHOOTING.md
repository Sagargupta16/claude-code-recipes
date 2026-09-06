# Troubleshooting

> A recipe is installed and nothing happens. Start here.

Almost every Claude Code config failure is **silent**. A hook whose matcher never matches, a subagent with an unrecognized frontmatter key, a skill with no description: none of these produce an error. The file loads, or is skipped, and the feature just does not exist. That is why this page is organized by symptom rather than by feature.

The single most useful command when something is quiet:

```bash
claude --debug
```

Most "why did nothing happen" answers are in that log and nowhere else.

---

## My hook never fires

Check these in order.

**1. Is the config three levels deep?** The shape is event, then matcher group, then a `hooks` array of handlers. A flat `{"matcher": ..., "command": ...}` object is valid JSON and fires never.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/pre-commit-lint.sh" }
        ]
      }
    ]
  }
}
```

**2. Does the matcher name a real tool?** On tool events the matcher matches the **tool name**, not a git subcommand or an event of your own invention. `Bash`, `Edit|Write`, `Read`, `mcp__.*` are matchers. `git_commit`, `file_edit`, `create_file`, `delete_file` are not, and neither is lowercase `bash`: a matcher made only of letters is compared as an exact string, so `bash` does not equal `Bash`.

To narrow a Bash hook down to one command, use the per-handler `if` field with permission-rule syntax:

```json
{ "type": "command", "if": "Bash(git commit *)", "command": "..." }
```

One rule per `if`. There is no `&&` or list syntax.

**3. Does every handler have a `type`?** `type` is required. Without it the handler is not a handler.

**4. Are you expecting a `CLAUDE_*` variable that does not exist?** There is no `$CLAUDE_TOOL_NAME` and no `$CLAUDE_FILE_PATH`. Event data arrives as JSON on stdin:

```bash
PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command // empty')
```

A hook inherits your environment, so `$PATH` and the rest are there. What Claude Code adds on top is `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA`, `CLAUDE_EFFORT`, `CLAUDE_CODE_REMOTE`, `CLAUDE_CODE_BRIDGE_SESSION_ID`, and `CLAUDE_PLUGIN_OPTION_<KEY>` for plugin options. None of them describe the event.

**5. Test it by hand with a realistic payload.** `echo '{}'` proves nothing, because an empty payload takes the early-exit path in most scripts:

```bash
echo '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"src/index.ts"}}' \
  | bash .claude/hooks/post-edit-format.sh
```

See [hooks/README.md](hooks/README.md) and [hooks/settings-hook-examples.json](hooks/settings-hook-examples.json).

---

## My hook runs but does not block anything

Your script is exiting 1. **Exit 2 is the only exit code that blocks.** Any other non-zero code is a non-blocking error: the action goes ahead and the transcript shows a hook error notice with the first line of your stderr.

```bash
if [[ $ERRORS -ne 0 ]]; then
  echo "Commit blocked" >&2
  exit 2
fi
```

Two further things worth knowing:

- The blocking message comes from **stderr**, so print the reason there, not to stdout.
- `PostToolUse` cannot block. The tool has already run. Exit 2 there only shows your stderr to Claude.

---

## My subagent is ignored, or edits files it should not

**Missing `description`.** `name` and `description` are both required. A file with a `name` and no `description` is skipped, and the reason is only written to the debug log.

**Frontmatter not on line 1.** The opening `---` must be the very first line. Anything above it and Claude Code reads the file as documentation with no fields.

**`allowed-tools` instead of `tools`.** This is the one that bites hardest, because it fails in the dangerous direction. `allowed-tools` is slash-command frontmatter. In a subagent file it is an unrecognized key, so it is ignored, so the agent inherits **every** tool -- including `Edit` and `Write`. An agent whose own description says "read-only and never modifies files" will happily modify files.

```yaml
# Wrong: silently inherits Edit and Write
allowed-tools:
  - Read
  - Glob
  - Grep

# Right
tools: Read, Glob, Grep
disallowedTools: Write, Edit
```

Note the format: `tools` and `disallowedTools` take a **comma-separated string**, not a YAML list. (The `--agents` JSON form is the exception and uses an array.)

**Name contains a colon.** `:` is reserved for plugin-scoped identifiers such as `my-plugin:reviewer`. Claude Code does not load a file whose `name` contains one, and writes an error to the debug log. Keep names to lowercase letters and hyphens.

See [subagents/README.md](subagents/README.md).

---

## My skill never loads

**No `description`.** This is what Claude reads to decide whether the skill is relevant. Without it, Claude falls back to the first paragraph of the body, which is usually a heading and a one-liner that says nothing about *when* to apply the skill. Write the description as "what it covers plus when to use it".

**Frontmatter not on line 1.** Same rule as everywhere else: put anything above the opening `---` and the whole file, markers included, is treated as content.

**`paths` too narrow.** If you set `paths`, the skill auto-loads only while working on matching files. Drop the field to let it trigger on any task.

**Wrong location or filename.** A project skill is `.claude/skills/<skill-name>/SKILL.md`, and the directory name is what becomes the command name.

**The skill is in a nested `.claude/skills/`.** Skills below your starting directory do not load at startup. They load the first time Claude reads or edits a file in the subdirectory that contains them, so until then they are absent from autocomplete and cannot be invoked by name. Run `/add-dir <subdirectory>` to load them up front.

**A stray `README.md` in `.claude/skills/`.** Copying `skills/*` from this repo drags the directory index in with it. Run `rm -f .claude/skills/README.md` afterwards.

See [skills/README.md](skills/README.md).

---

## My slash command does nothing, or is not in the menu

**Frontmatter not on line 1.** Same rule again. If the `---` is not first, the fields are body text and `description` never reaches the picker.

**The body is documentation instead of a prompt.** The file *is* the command: its body is the prompt Claude runs. If the body says "save this file as `.claude/commands/x.md`" and wraps the real prompt in a nested code fence, then invoking the command tells Claude to go save a file. Strip the wrapper.

**You expected `allowed-tools` to sandbox it.** It does not. `allowed-tools` **pre-approves** tools so Claude stops asking for permission during the invoking turn, and the grant clears on your next message. It removes nothing: a command with `allowed-tools: Read` can still run Bash. Use `disallowed-tools` to actually take a tool away.

**Wrong directory.** Project commands live in `.claude/commands/`, not `.claude/command/` and not `.claude/agents/`.

See [commands/README.md](commands/README.md).

---

## My MCP server does not connect

**A `url` with no `type`.** Claude Code reads an entry that has no `type` as a stdio server, skips it, and reports `has a "url" but no "type"`. Add `"type": "http"` (or `"sse"` / `"ws"`).

**Wrong file for the scope.** Server definitions never live in a settings file. `~/.claude/settings.json` holds MCP *controls* only (`enabledMcpjsonServers`, `disabledMcpjsonServers`, `enableAllProjectMcpServers`). Put the definition in one of the three files below.

| Scope | File |
|-------|------|
| Local | `~/.claude.json`, nested under the project path |
| Project | `.mcp.json` in the project root |
| User | `~/.claude.json`, at the top level |

Easiest fix is to let the CLI write it: `claude mcp add --transport http <name> --scope user <url>`.

**An unset `${VAR}`.** A missing environment variable does not stop the config from loading. Claude Code warns in `claude mcp list` and `/mcp`, leaves the literal `${VAR}` in place, and the server then fails at connect time. Either export the variable or give it a default: `${VAR:-fallback}`.

**A deprecated package.** `npx -y @scope/server-x` happily installs a package that is no longer maintained. Check with `npm view @scope/server-x deprecated` before trusting it.

**Same server defined twice.** Definitions are not merged across scopes; the highest-precedence one wins outright. Order is local, project, user, plugin, then claude.ai connectors.

Diagnose with:

```bash
claude mcp list
```

then `/mcp` inside a session, and confirm the server shows `connected`. A bad token shows `failed` with the HTTP status, usually 401.

See [mcp-configs/README.md](mcp-configs/README.md).

---

## How do I check a recipe actually works before I trust it?

Run the repo's own validator. It checks command and subagent and skill frontmatter, the hook JSON schema, JSON validity, and that the advertised recipe counts match the files on disk:

```bash
bash scripts/validate-recipes.sh
```

It runs on every push and pull request via [CI](.github/workflows/ci.yml), alongside shellcheck and a link check.

Beyond that, the per-feature smoke tests:

| Recipe type | How to prove it works |
|-------------|----------------------|
| Command | Type `/` and confirm it appears with your description, then run it |
| Subagent | Ask Claude to delegate to it by name; check the transcript shows the agent's tool list |
| Skill | Ask a question in the skill's domain and confirm the answer follows its rules |
| Hook | Trigger the event, then `claude --debug` if nothing visible happened |
| MCP config | `claude mcp list`, then `/mcp` and look for `connected` |

---

## Still stuck?

Open an issue with the [recipe does not work](https://github.com/Sagargupta16/claude-code-recipes/issues/new?template=recipe-not-working.yml) form. Include the recipe file, your Claude Code version (`claude --version`), and what you expected against what happened.
