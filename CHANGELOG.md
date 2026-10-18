# Changelog

## [1.3.0] - 2026-10-18

### Added

- Plugin marketplace: `.claude-plugin/marketplace.json` ships the recipes as five plugins (`recipe-commands`, `recipe-agents`, `recipe-skills`, `recipe-hooks`, `recipe-guards`), installed with `/plugin marketplace add Sagargupta16/claude-code-recipes`. Each plugin's source is one recipe directory and lists its files by name. A root-level source was tried first and dropped: the `--debug-file` load log showed every plugin also scanning the root `skills/` folder. With the per-directory layout the log shows 15 commands, 9 agents and 5 skills loaded, and no README
- `scripts/build_marketplace.py` generates the marketplace from the files on disk and takes its version from this changelog. `validate-recipes.sh` fails when the committed file is stale
- Hooks: `block-dangerous-commands.sh`, a `PreToolUse` Bash guard against recursive `rm` on `/`, `~` or a system directory, `mkfs`, `dd` onto a device, the fork bomb, recursive `chmod` on `/`, `git push --force` without a lease, deleting `main`, `curl | sh`, and `DROP` / `TRUNCATE` sent to a SQL client. It splits on `;`, `&&`, `||` and `|` first, so `rm -rf build && ls /` is allowed. It strips the `\r` that native Windows `jq` leaves on every line of a multi-line command, which would otherwise let `rm -rf /` on a non-final line through. It replaces the one-line `PreToolUse_block_dangerous_commands` example, which grepped the whole command string: it let `rm -fr /` and `rm -rf ~` through, and blocked `rm -rf /tmp/build-cache` and a commit message that mentions `DROP TABLE`
- Hooks: `secret-scan.sh`, a `PreToolUse` Edit / Write / NotebookEdit hook that blocks writing an AWS, GitHub, Slack, Stripe, Google, Anthropic or OpenAI key, or a PEM private key, before it reaches the disk. The block message names the rule, never the value. It matches with a here-string, not a pipe into `grep -q`: under `pipefail` the pipe reported a miss on any write bigger than the pipe buffer, and a 315 KB write with a key on line 1 got through
- `scripts/test-hooks.sh`: 77 behavior checks that replay hook payloads and assert exit codes and stderr, with linters, test runners and notifiers stubbed on `PATH`. It fails on the 1.1.0 `notification.sh` (the injection) and `pre-push-test.sh` (pytest exit 5). It also runs the plugin hook commands as written in the marketplace
- CI: the hook tests run on Ubuntu, macOS and Windows, and a new job runs `claude plugin validate --strict` on the marketplace
- `validate-recipes.sh` checks that every hook script the settings example runs exists
- `scripts/probe_postgres_mcp.py`: sends the read-only escape payloads to a real Postgres through the PostgreSQL MCP recipe and reports whether the table survived
- `TROUBLESHOOTING.md`: a section for plugins that install but seem empty (namespaced names, and why `claude plugin details` shows 0 commands)

### Changed

- MCP: `postgres.json` now runs Postgres MCP Pro (`uvx postgres-mcp --access-mode=restricted`) instead of the archived `@modelcontextprotocol/server-postgres`. Restricted mode parses each statement first: the probe saw it refuse all 5 write payloads, including `COMMIT; DROP TABLE users;`, and the table kept its row, while the unrestricted control run dropped the table. The config pins `mcp<2`, because postgres-mcp 0.3.0 crashes on import under mcp 2.x. It needs Linux or macOS (or WSL), since its `pglast` dependency has no Windows wheel
- Hooks: the two guard hooks exit 1 with a visible notice when `jq` is missing, instead of passing every command in silence
- Recipe count is 49 (7 hooks)

## [1.2.0] - 2026-10-18

### Fixed

- Hooks: `notification.sh` no longer splices the payload message into AppleScript and PowerShell source. A message with a quote broke the notification, and on Windows a crafted one (MCP elicitation prompts carry server-supplied text) ran arbitrary PowerShell. osascript now takes the text as argv, PowerShell reads it from the environment, and `WSLENV` carries it across from WSL
- Hooks: `pre-push-test.sh` treats pytest exit code 5 (no tests collected) as a skip. A Python project with a `pyproject.toml` and no tests yet had every push blocked as a test failure
- MCP: `memory.json` defaulted `MEMORY_FILE_PATH` to the relative `.claude/memory.json`, which the server resolves against its own package directory, so under `npx` the graph landed in the npx cache instead of the project. The default is now `~/.claude/memory.jsonl`, and the comment explains how to get a per-project graph
- MCP: `postgres.json` claimed queries run read-only. The published 0.6.2 build lets `COMMIT; <write>` escape the read-only transaction and the fix was never released, so the security notes now say so, link the write-up, and make a `SELECT`-only database user the guard
- MCP: `postgres.json` listed `list_tables`, `describe_table`, and `list_schemas`, which the server does not have. It exposes one `query` tool and a schema resource per table. The connection-string default moved into `args`, the only place the server reads it, and the false "or individual PG* variables" and `?schema=public` lines are gone
- MCP: `filesystem.json` tool list now matches the published server (`read_text_file`, `read_media_file`, `list_directory_with_sizes`, and `read_file` marked deprecated)
- Docs: the README catalog called the Memory server key-value storage; it is a knowledge graph

### Added

- README "Where Each Recipe Plugs In" section: a Mermaid diagram of which recipe type fires at which point of a session, and a table of when each one loads

## [1.1.0] - 2026-10-10

### Fixed

- Hooks: rewrote every hook config to the real `settings.json` schema (event -> matcher group -> handler array with a required `type`). The previous flat `{"matcher", "command"}` shape parsed as valid JSON and could never fire
- Hooks: matchers now name real tools (`Bash`, `Edit|Write`) instead of `git_commit`, `git_push`, and `file_edit|create_file`, with per-handler `if` rules for git subcommand filtering
- Hooks: `pre-commit-lint.sh` and `pre-push-test.sh` now `exit 2`, the only code that blocks a `PreToolUse` action. They exited 1 while printing "blocked", and let the commit and push through
- Hooks: both blocking hooks send everything they and their tools print to stderr. The linter and test output went to stdout, which only reaches the debug log, so "fix the issues above" pointed at nothing Claude could see
- Hooks: `pre-push-test.sh` resolves an installed Jest or Vitest by walking up to `node_modules/.bin`, and skips with a message when the runner is not installed rather than blocking the push as a test failure. It also hands `--ci` to Jest instead of to npm, which was expanding it to `--cidr`
- Hooks: `post-edit-format.sh` reads the edited path from `.tool_input.file_path` instead of a `$CLAUDE_FILE_PATH` variable that does not exist. It previously exited early on every invocation without formatting anything
- Hooks: corrected the exit-code table and the environment-variable table in `hooks/README.md`
- Subagents: replaced `allowed-tools` with `tools` in all 9 recipes. `allowed-tools` is not a subagent field, so the three read-only agents were inheriting `Edit` and `Write` despite their descriptions. Added `disallowedTools: Write, Edit` to those three
- Commands: rewrote `audit-repos`, `check-all-prs`, and `update-status` as installable command files. They were wrapper docs whose body told Claude to save a file, and the bulk-install snippet copied them verbatim
- Commands: `commands/README.md` had `allowed-tools` backwards. It pre-approves tools for the invoking turn; `disallowed-tools` is what restricts
- MCP: replaced the deprecated `@modelcontextprotocol/server-github` package with GitHub's own remote server at `https://api.githubcopilot.com/mcp/`
- MCP: flagged `postgres.json` as upstream-deprecated and repointed its 404 docs link at the archived source
- MCP: corrected the scope table. User-scope servers live in `~/.claude.json`, not `~/.claude/settings.json`, which holds MCP controls only
- Skills: added the required frontmatter to the `SKILL.md` templates in `skills/README.md` and `CONTRIBUTING.md`, which still showed the pre-frontmatter format the shipped skills stopped using
- Workflows: renamed "Code mode" to `default`, which is the real permission mode name
- Docs: `$schema` in the settings example now points at the published schema on schemastore instead of a 404, and the hooks doc link follows the move to `code.claude.com`
- Docs: aligned the documented size limits with the content that ships (skills 350 lines, CLAUDE.md templates 250) and corrected the template line counts
- Docs: `skills/README.md` bulk copy now removes the directory README, matching `commands/` and `subagents/`
- Docs: removed the claims that could not be sourced. The hook environment list is no longer presented as exhaustive (a hook inherits the parent environment, and `CLAUDE_PLUGIN_OPTION_<KEY>` was missing), settings files holding an `mcpServers` block no longer claim a specific failure mode, the skill-location rule no longer asserts one directory deep, and the GitHub MCP optional-toolset list is complete
- Style: finished the em dash sweep across the 41 files the earlier passes missed, and the two British spellings that came with the new prose

### Added

- `.github/workflows/ci.yml`: recipe validation, `shellcheck`, and a link check on push, pull request, and weekly
- `scripts/validate-recipes.sh`: asserts command, subagent, and skill frontmatter, the nested hook schema, JSON validity, banned dash characters, that every link back into this repo points at a file that exists, and that the advertised recipe counts match the files on disk
- `TROUBLESHOOTING.md`: symptom-first guide for the silent failures, one section per "installed it and nothing happened"
- `.github/PULL_REQUEST_TEMPLATE.md`, issue forms for a recipe request and a broken recipe, and `CODEOWNERS`
- `.gitattributes` with `*.sh text eol=lf`, so a Windows clone no longer checks the hook scripts out with CRLF and break them when copied to a Linux or macOS project
- Expanded the README "Related" section into a table of the sibling repos

### Earlier, already on main and never logged

- Add 3 command recipes: `/check-all-prs`, `/audit-repos`, `/update-status`
- Add required frontmatter to the 5 skill files
- Add a shared Renovate preset
- Fix the bulk-install snippets to create the `.claude` subdirectories and skip the directory READMEs
- Correct the recipe count to 47

## [1.0.0] - 2026-03-16

- Add .gitignore and update LICENSE year

## [0.1.0] - 2026-03-08

- Initial release: 50+ Claude Code recipes
- Commands, subagents, hooks, skills, and MCP configs
