---
model: haiku
description: Check all your open PRs across GitHub repos for CI, reviews, and merge readiness
allowed-tools:
  - Bash(gh *)
---

Check all my open pull requests across GitHub and report what needs attention.

## Step 1 -- Find the PRs

Run:

```bash
gh search prs "author:@me is:open" --json repository,title,number,url,createdAt
```

If the result is empty, say there are no open PRs and stop.

## Step 2 -- Inspect Each PR

For every PR, gather:

- **CI and merge state**: `gh api repos/{owner}/{repo}/pulls/{number} --jq '{mergeable, mergeable_state, draft}'`
- **Latest check runs**: `gh pr checks {number} --repo {owner}/{repo}` (a non-zero exit means checks are failing or still running, not an error to report as a crash)
- **Newest comment**: `gh api repos/{owner}/{repo}/issues/{number}/comments --jq '.[-1] | {user: .user.login, body: .body}'`
- **Review state**: `gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq '[.[] | .state] | unique'`

Read only. Do not push, comment, rebase, or merge anything.

## Step 3 -- Report

Output one table:

```
| Repo | PR | Title | CI | Reviews | Action Needed |
```

Then a short list of PRs that need action, most urgent first. Flag:

- **Needs rebase**: `mergeable_state` is `behind` or `dirty`
- **Failing CI**: any check run concluded as failure
- **Awaiting your reply**: newest comment is from someone else, or reviews include `CHANGES_REQUESTED`
- **Ready to merge**: `mergeable` is true, checks green, at least one `APPROVED` review
- **Stale**: open with no activity for more than 14 days

If nothing needs action, say so in one line instead of padding the report.
