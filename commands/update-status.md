---
model: sonnet
description: Refresh a STATUS.md dashboard with live GitHub data on PRs, CI, and security alerts
allowed-tools:
  - Bash(gh *)
  - Read
  - Edit
  - Write
---

Refresh `STATUS.md` in the repo root with live data from GitHub.

If `STATUS.md` does not exist, create it using the section layout below. If it does exist, read it first and preserve its existing structure, headings, and any hand-written notes. Replace only the data.

Repos to cover: the ones already named in `STATUS.md`. If the file is new, use `gh repo list --no-archived --source --limit 200 --json name,pushedAt` and cover the 10 most recently pushed.

## Step 1 -- Gather

**Profile stats:**

```bash
gh api user --jq '{login, followers, public_repos}'
gh repo list --limit 200 --json stargazerCount --jq '[.[].stargazerCount] | add'
```

**Contribution stats for the last year:**

```bash
gh api graphql -f query='{ viewer { contributionsCollection {
  totalCommitContributions
  totalPullRequestContributions
  totalPullRequestReviewContributions
  totalIssueContributions
} } }'
```

**Open PRs authored by me:**

```bash
gh search prs "author:@me is:open" --json repository,title,number,url,createdAt
```

For each one, add CI and merge state:

```bash
gh pr checks {number} --repo {owner}/{repo}
gh api repos/{owner}/{repo}/pulls/{number} --jq '{mergeable, mergeable_state, draft}'
```

**CI health per tracked repo:**

```bash
gh run list --repo {owner}/{repo} --limit 1 --json conclusion,name,createdAt
```

**Open security alerts per tracked repo:**

```bash
gh api repos/{owner}/{repo}/dependabot/alerts --jq '[.[] | select(.state=="open")] | length'
```

## Step 2 -- Write

Update these sections:

- **Profile** -- followers, public repo count, total stars
- **Contributions** -- commits, PRs, reviews, issues over the last year
- **Open PRs** -- table of repo, PR number, title, CI, review state, action needed
- **CI Health** -- table of repo, latest run conclusion, run date
- **Security Alerts** -- table of repo and open alert count, or "none open"
- **Action Items** -- the shortlist that needs a human, ordered by urgency
- **Last updated** -- today's date in `YYYY-MM-DD` form

Rules for the write:

- Use absolute `YYYY-MM-DD` dates, never "yesterday" or "last week"
- Do not delete a section you have no data for. Write "no data (check skipped: 403)" instead
- Do not invent a number. If an API call fails, say which one and leave the previous value with a note
- Do not commit or push. Leave the change in the working tree for review
