---
model: haiku
description: Generate a PR title and description from the current branch diff against main
allowed-tools:
  - Bash
  - Read
  - Grep
---

Generate a pull request title and description by analyzing the current branch's changes against the base branch.

## Step 1 — Determine the Base Branch

Run `git remote show origin` or inspect common defaults to determine the base branch. Try `main` first, then `master`, then `develop`. Use whichever exists on the remote.

## Step 2 — Gather Context

Run these commands to understand the full scope of changes:

1. `git log --oneline <base>..HEAD` — list all commits on this branch
2. `git diff <base>...HEAD --stat` — file-level summary of changes
3. `git diff <base>...HEAD` — full diff for detailed analysis

Also check if there is a `.github/PULL_REQUEST_TEMPLATE.md` or similar template file. If one exists, use its structure instead of the default format below.

## Step 3 — Analyze the Changes

Read through the diff and commit history to understand:
- **What** changed (files, functions, components)
- **Why** it changed (bug fix, new feature, refactor, chore)
- **How** it changed (approach, patterns, dependencies added/removed)

If commit messages reference issue numbers (e.g., `#123`, `JIRA-456`), include them.

## Step 4 — Generate the PR Title

Write a concise PR title (under 72 characters) following this format:
- `feat: add user avatar upload` (new feature)
- `fix: resolve race condition in payment processing` (bug fix)
- `refactor: extract auth middleware into shared module` (refactor)
- `chore: upgrade React from 18 to 19` (maintenance)
- `docs: add API authentication guide` (documentation)

Use the conventional commit prefix that best matches the changes.

## Step 5 — Generate the PR Description

Output the PR description in this format:

```markdown
## Summary

One to three sentences describing the high-level purpose of this PR.
Reference any related issues: Closes #123, Relates to #456.

## Changes

- Bullet list of specific, meaningful changes
- Group related changes together
- Mention new dependencies, config changes, or migrations
- Note any breaking changes with a **BREAKING:** prefix

## Test Plan

- [ ] Describe how to verify the changes work
- [ ] List any manual testing steps
- [ ] Note which automated tests cover the changes
- [ ] Call out areas that need extra review attention
```

## Output

Present the title and description clearly so the user can copy them. Format the title on its own line, then the full description body. Do not wrap the output in an outer code fence — present it as raw Markdown the user can paste directly into their PR.
