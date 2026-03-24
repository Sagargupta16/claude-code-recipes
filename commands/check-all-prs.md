# /check-all-prs

Check all your open PRs across GitHub repos.

## Command File

Save as `.claude/commands/check-all-prs.md`:

```markdown
Check all my open PRs across GitHub.

1. Run: gh search prs "author:@me is:open" --json repository,title,number,url,createdAt
2. For each PR, check:
   - CI status: gh api repos/{owner}/{repo}/pulls/{num} --jq '.mergeable_state'
   - New comments: gh api repos/{owner}/{repo}/issues/{num}/comments --jq '.[-1].user.login, .[-1].body'
   - How far behind: gh api repos/{owner}/{repo}/pulls/{num} --jq '.mergeable'
3. Summarize in a table: Repo | PR# | Title | CI | Reviews | Action Needed
4. Flag any PRs that need rebasing or have new review comments
```

## Usage

```
/check-all-prs
```

## Notes

- Uses `gh` CLI (must be authenticated)
- Works across all repos, not just the current one
- Pairs well with a STATUS.md file for tracking
