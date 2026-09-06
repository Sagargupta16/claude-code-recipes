# Changelog

## [Unreleased]

No tag or release exists after 1.0.0, so everything below is unreleased.

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
