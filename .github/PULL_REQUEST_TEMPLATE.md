<!--
Thanks for contributing. Keep this structure: it is the one CONTRIBUTING.md asks for.
Delete any section that genuinely does not apply.
-->

## What

<!-- Which recipe are you adding or changing? Name the files. -->

## Why

<!-- What problem does it solve, or what does it improve? -->

## Testing

<!--
How did you verify it? Be concrete: the command you ran and what you saw.
"Looks right" is not testing. For a hook, paste the payload you fed it.
-->

## Checklist

- [ ] `bash scripts/validate-recipes.sh` passes locally
- [ ] The recipe works out of the box, with no setup beyond copying the file
- [ ] File names use kebab-case
- [ ] Markdown renders correctly on GitHub
- [ ] Shell scripts pass `shellcheck -S style`
- [ ] JSON files are valid (no trailing commas, proper escaping)
- [ ] No paid service or personal API key is required to use it
- [ ] Examples are generic, not tied to one project
- [ ] Indexes updated: the category `README.md`, the root `README.md` catalog, and `cheatsheet.md`
- [ ] No em dash or en dash anywhere (this repo writes `--` and `-`)
- [ ] No emojis

## Recipe-specific

<!-- Only fill in the row that matches what you changed. -->

- **Command**: frontmatter opens on line 1 with a `description`; the body is the prompt itself, not instructions to save a file
- **Subagent**: `name` + `description` + `tools` (a comma-separated string, never `allowed-tools`)
- **Skill**: frontmatter opens on line 1 with a `description` that says when to apply the skill
- **Hook**: nested `event -> matcher -> hooks` config, matcher names a real tool, `exit 2` to block
- **MCP config**: `_comment` block with a working `Docs:` URL, secrets via `${VAR}`, `type` set when there is a `url`, and `npm view <pkg> deprecated` came back empty
