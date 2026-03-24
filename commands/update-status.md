# /update-status

Refresh a STATUS.md dashboard with live GitHub data.

## Command File

Save as `.claude/commands/update-status.md`:

```markdown
Update STATUS.md with live data from GitHub.

1. Get profile stats: gh api users/{username} (followers, repos, stars)
2. Get contribution stats: gh api graphql (commits, PRs, reviews, issues)
3. Check all open PRs: gh search prs "author:{username} is:open"
4. For each open PR: check CI status, review status, merge readiness
5. Check CI health: latest workflow run for key repos
6. Check security alerts: Dependabot alerts on key repos
7. Update STATUS.md with all findings
8. Note the current date as "Last updated"
```

## Usage

```
/update-status
```

## Notes

- Designed for multi-repo workspaces
- Updates a central dashboard file
- Run at the start of each session
