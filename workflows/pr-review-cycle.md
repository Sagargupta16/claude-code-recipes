# Workflow: PR Review Cycle

> PR review workflow: review, request changes, author fixes, re-review, and approve.

This workflow covers both sides — **reviewing someone else's PR** and **responding to review feedback on your own PR**.

---

## Overview

| Phase | Role | Mode | Recipes Used | Time |
|-------|------|------|-------------|------|
| 1. Initial Review | Reviewer | Plan | `/code-review`, code-reviewer subagent | 10-20 min |
| 2. Request Changes | Reviewer | — | — | 5 min |
| 3. Address Feedback | Author | Code | — | 10-60 min |
| 4. Re-review | Reviewer | Plan | — | 5-10 min |
| 5. Approve & Merge | Reviewer | — | — | 2 min |

---

## Step 1: Initial Review

**Role**: Reviewer
**Mode**: Plan

Start by understanding what the PR does, then review the code systematically.

**Prompt — automated review**:
```
Review the PR at [URL or branch name]. Check the diff and analyze:

1. **Correctness**: Does the code do what the PR description says?
2. **Bugs**: Any logic errors, off-by-one, null handling, race conditions?
3. **Security**: Input validation, auth checks, data exposure, injection?
4. **Performance**: N+1 queries, unnecessary re-renders, missing indexes?
5. **Style**: Naming conventions, code organization, consistency?
6. **Tests**: Are changes tested? Are edge cases covered?
7. **Documentation**: Are public APIs documented? README updated if needed?

For each issue found, specify:
- File and line number
- Severity (blocker / suggestion / nit)
- What's wrong and how to fix it
```

**Or use the code-reviewer subagent for a deeper review**:
```
Use the code-reviewer subagent to review all changes on the branch
[branch-name] compared to main. Produce a detailed review report.
```

**Review checklist**:
- [ ] PR description is clear and complete
- [ ] Changes match the PR description (no scope creep)
- [ ] No unrelated changes mixed in
- [ ] Tests exist for new/changed behavior
- [ ] No secrets, credentials, or sensitive data
- [ ] Error handling is complete
- [ ] Breaking changes are documented

---

## Step 2: Request Changes

**Role**: Reviewer

Organize your feedback and post it on the PR.

**Prompt**:
```
Based on the review findings, draft GitHub PR review comments:

1. Start with a summary comment (overall assessment)
2. Group issues by severity:
   - Blockers: Must fix before merge
   - Suggestions: Should fix, but not blocking
   - Nits: Style preferences, take it or leave it
3. For each issue, provide:
   - The specific line/file reference
   - What's wrong (be specific)
   - A suggested fix (code snippet if helpful)
4. End with what's done well (positive feedback)
```

**Tips for good reviews**:
- Be specific — "this could be null on line 42" not "handle errors better"
- Explain *why* — "this causes N+1 queries because..." not just "fix this"
- Suggest, don't demand — "consider using X" not "you must use X"
- Acknowledge good work — reviews shouldn't only be negative
- Separate blockers from nits — make it clear what must change

---

## Step 3: Address Feedback

**Role**: Author
**Mode**: Code

Respond to each review comment systematically.

**Prompt**:
```
Here are the review comments on my PR:

[paste comments or provide PR URL]

For each comment:
1. If it's a valid issue — fix it
2. If I disagree — explain why in a reply (don't just dismiss it)
3. If it's a nit — fix it (it's faster than debating)

After fixing everything, summarize what was changed.
```

**For larger feedback rounds**:
```
Address all review feedback on this PR. Group the changes:
1. Fix all blocker issues first
2. Then suggestions
3. Then nits

For each fix, make a separate commit with a clear message like:
  fix(review): handle null user in getProfile
  fix(review): add validation for email format
```

**Tips for authors**:
- Don't take feedback personally — it's about the code
- Respond to every comment — even if just "Done" or "Good catch"
- Ask questions if feedback is unclear
- Push fixes as new commits (don't force-push during review)
- Re-request review when ready

---

## Step 4: Re-review

**Role**: Reviewer
**Mode**: Plan

Check that all feedback was addressed correctly.

**Prompt**:
```
Re-review the PR. Check that:
1. All blocker issues are resolved
2. Fixes are correct (not just papering over the issue)
3. No new issues introduced by the fixes
4. All review comments are addressed (responded to or fixed)
```

**Quick re-review**:
```
Look at only the new commits since my last review (the fix commits).
Verify each addresses the feedback correctly.
```

---

## Step 5: Approve and Merge

**Role**: Reviewer

Once all issues are resolved, approve and merge.

**Prompt** (if using Claude to manage the merge):
```
The PR is approved. Squash merge it to main with this commit message:

[type]([scope]): [description from PR title]

[Brief summary from PR description]
```

**Merge checklist**:
- [ ] All blocker comments resolved
- [ ] CI passes (tests, lint, build)
- [ ] Branch is up to date with main
- [ ] At least one approval
- [ ] No unresolved conversations

---

## Review Standards by Change Type

| Change Type | Review Focus | Required Reviewers |
|-------------|-------------|:------------------:|
| Bug fix | Root cause, regression test | 1 |
| New feature | Design, tests, edge cases | 1-2 |
| Refactoring | Behavior preservation, tests pass | 1 |
| Security fix | Threat model, fix completeness | 2 |
| Database migration | Reversibility, data integrity | 2 |
| Config / infra | Rollback plan, environment parity | 1 |
| Documentation | Accuracy, completeness | 1 |

---

## Common Review Shortcuts

```bash
# View PR diff in terminal
gh pr diff 123

# Check out PR locally for testing
gh pr checkout 123

# Approve PR
gh pr review 123 --approve --body "LGTM"

# Request changes
gh pr review 123 --request-changes --body "See comments"

# Merge PR (squash)
gh pr merge 123 --squash --delete-branch
```

---

## Anti-patterns

- **Rubber stamp reviews** — clicking "Approve" without reading the code
- **Bikeshedding** — spending review time on naming debates instead of logic
- **Review pile-up** — letting PRs sit for days; review within 24 hours
- **Mega PRs** — hard to review well; ask the author to split if over 400 lines
- **Personal attacks** — review the code, not the person
- **Blocking on nits** — only block for real issues, not style preferences
