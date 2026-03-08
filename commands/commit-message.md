---
model: haiku
description: Generate a conventional commit message from staged changes
allowed-tools:
  - Bash
---

Generate a well-structured conventional commit message from the currently staged git changes.

## Step 1 — Get the Staged Diff

Run `git diff --cached` to see what is staged. Also run `git diff --cached --stat` for a file summary.

If nothing is staged, inform the user: "No changes are staged. Run `git add` first, then invoke this command again." Then stop.

## Step 2 — Determine the Commit Type

Analyze the diff to select the most appropriate type:

| Type       | When to Use                                                  |
|------------|--------------------------------------------------------------|
| `feat`     | A new feature or user-facing capability                      |
| `fix`      | A bug fix                                                    |
| `refactor` | Code restructuring with no behavior change                   |
| `perf`     | A performance improvement                                    |
| `test`     | Adding or updating tests only                                |
| `docs`     | Documentation-only changes                                   |
| `style`    | Formatting, whitespace, semicolons — no logic change         |
| `chore`    | Build scripts, CI config, dependency bumps, tooling          |
| `ci`       | CI/CD pipeline changes                                       |
| `build`    | Build system or external dependency changes                  |
| `revert`   | Reverting a previous commit                                  |

If the diff spans multiple types, choose the dominant one. If it is truly mixed, prefer `feat` > `fix` > `refactor` > `chore`.

## Step 3 — Determine the Scope

Identify a short scope in parentheses that indicates the area of the codebase:
- Module or package name: `feat(auth):`, `fix(payments):`
- Component name: `refactor(Button):`
- Layer: `test(api):`, `docs(readme):`

Omit the scope only if the change is truly project-wide.

## Step 4 — Write the Subject Line

Format: `type(scope): imperative description`

Rules:
- Use imperative mood ("add", not "added" or "adds")
- Do not capitalize the first word after the colon
- Do not end with a period
- Keep it under 72 characters
- Be specific — "fix null check" is too vague; "fix null dereference in user lookup when email is missing" is good

## Step 5 — Write the Body (if needed)

Add a body separated by a blank line if the change is non-trivial. The body should explain:
- **Why** the change was made (not just what changed — the diff shows that)
- Any non-obvious decisions or trade-offs
- Breaking changes prefixed with `BREAKING CHANGE:`

## Step 6 — Check for Issue References

If the diff or branch name contains issue numbers, append a footer:
```
Closes #123
```

## Step 7 — Present the Result

Output the commit message inside a single code block so the user can copy it. Also provide the ready-to-run command:

```bash
git commit -m "type(scope): subject line" -m "Optional body paragraph"
```

If the user provided `$ARGUMENTS` containing "apply" or "run", execute the `git commit` command directly instead of just displaying it.
