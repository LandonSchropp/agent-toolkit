---
description: Use when uncommitted changes are ready for the user's approval. Runs a fresh review before asking the user to approve a commit.
---

# Pre-Review

You wrote this diff, so review it with fresh eyes before asking the user to approve a commit.

Run this before asking the user to approve a commit. Copilot already shows the user changed files, so this skill is only the agent's own pre-approval check.

Read `references/checks.md` and apply it to only the uncommitted changes under review: `git diff --cached` if the next commit's changes are staged, otherwise `git diff` plus every untracked file `git status` lists. Do not review already-committed branch changes. Report findings and change nothing.

Fix everything it turns up. When it flags more than one logical change, narrow the working set to the first commit's files here rather than presenting all of them: **REQUIRED:** Invoke the `ls-git:git-atomic-commit` skill. Then ask the user for commit approval, and state in one line what you fixed and anything you deliberately left alone.

## Rationalizations

| Thought                                      | Reality                                                     |
| -------------------------------------------- | ----------------------------------------------------------- |
| "The diff is small, I'll check it myself"    | You already read it once and missed it. Dispatch the agent. |
| "I know what's in it, I just wrote it"       | Fresh review catches assumptions the author overlooks.     |
| "I'll run it in the background and present"  | Findings after the user reviews are worthless. Block on it. |
| "I'll let another process fix what it finds" | Review findings first, then make the fixes yourself.       |
| "The checks are loaded, I can just run them" | Loading the rubric is not the point. Fresh eyes are.        |
| "Dispatching costs a round trip"             | Cheaper than the round trip through the user.               |
| "Splitting means committing, so I'll ask"    | Narrowing to one commit's files is not committing.          |
