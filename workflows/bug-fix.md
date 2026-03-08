# Workflow: Bug Fix

> Systematic bug fix cycle: reproduce, isolate, fix, test, and commit.

---

## Overview

| Phase | Mode | Recipes Used | Time |
|-------|------|-------------|------|
| 1. Reproduce | Plan | `/debug` | 5-15 min |
| 2. Isolate | Plan/Code | Researcher subagent | 5-10 min |
| 3. Fix | Code | — | 5-30 min |
| 4. Test | Code | `/test-gen`, test-runner subagent | 5-15 min |
| 5. Commit | Code | `/commit-message` | 2 min |

---

## Step 1: Reproduce

**Mode**: Plan

First, confirm the bug exists and understand the exact conditions that trigger it.

**Prompt**:
```
I need to fix a bug: [bug description]

Expected behavior: [what should happen]
Actual behavior: [what actually happens]
Steps to reproduce: [how to trigger it]

Analyze the codebase and help me understand:
1. Which code path is involved
2. What the input/output looks like at each step
3. Where the behavior diverges from expectations
```

**If you have error logs or stack traces**:
```
Here's the error:

[paste error/stack trace]

Trace this error back to the root cause. Identify the exact file and
line where the bug originates (not just where the error is thrown).
```

**Tips**:
- Don't jump to fixing — understand the bug first
- Reproduce it reliably before attempting a fix
- Check if the bug exists in tests (it probably doesn't, which is why it shipped)

---

## Step 2: Isolate

**Mode**: Plan or Code

Narrow down the root cause to a specific function, condition, or data path.

**Prompt**:
```
/debug
```

Or delegate investigation to the researcher subagent:

```
Use the researcher subagent to investigate this bug:
- Find all code paths that could lead to [the problematic behavior]
- Check if similar patterns exist elsewhere (same bug in other places)
- Identify the minimal change needed to fix it
```

**What to look for**:
- Off-by-one errors
- Null/undefined handling
- Race conditions or timing issues
- Incorrect type coercion
- Missing edge case handling
- Stale state or cache issues
- Incorrect assumptions about data shape

---

## Step 3: Fix

**Mode**: Code

Apply the minimal fix. Don't refactor unrelated code in the same change.

**Prompt**:
```
Fix the bug by [description of the fix based on analysis].

Requirements:
- Minimal change — only fix the bug, don't refactor
- Handle the edge case that caused it
- Make sure the fix doesn't break existing behavior
- Add a comment explaining WHY the fix is needed (if not obvious)
```

**For subtle bugs**:
```
The root cause is [explanation]. Apply the fix, then walk me through
why this change is correct and what cases it covers.
```

**Tips**:
- Prefer the smallest correct fix
- If a refactor would prevent the bug class entirely, note it for a follow-up PR
- Check if the same bug pattern exists elsewhere in the codebase

---

## Step 4: Test

**Mode**: Code

Write a test that would have caught this bug, then run the full suite.

**Prompt**:
```
Write a regression test that:
1. Reproduces the exact bug scenario (this test would have FAILED before the fix)
2. Covers the edge case that caused it
3. Tests related edge cases that might have the same root cause

Then run the full test suite to make sure nothing else broke.
```

**Recipes to use**:
- `/test-gen` — generate the regression test
- Test-runner subagent — run tests and verify everything passes

**This step is critical** — a bug fix without a regression test is incomplete. The test proves the fix works and prevents the bug from coming back.

---

## Step 5: Commit

**Mode**: Code

Create a clean commit with a clear message.

**Prompt**:
```
/commit-message
```

**Commit message format**:
```
fix(<scope>): <what was fixed>

<Why the bug happened and what the fix does>

Fixes #<issue-number>
```

**Example**:
```
fix(auth): prevent session expiry during active requests

The session timeout was calculated from login time instead of last
activity time. Active users were logged out after 30 minutes
regardless of activity. Changed to track last API request timestamp.

Fixes #456
```

---

## Checklist

Before merging the bug fix:

- [ ] Bug is reproducible (you can trigger it reliably)
- [ ] Root cause is identified (not just the symptom)
- [ ] Fix is minimal and targeted
- [ ] Regression test exists (fails without fix, passes with it)
- [ ] Full test suite passes
- [ ] No unrelated changes included
- [ ] Commit message references the issue
- [ ] Same bug pattern checked elsewhere in codebase
