---
description: Use when uncommitted changes are ready for the user's approval. Runs a fresh review before asking the user to approve a commit.
---

# Pre-Review

You wrote this diff, so you are the worst available reviewer of it. Hand it to a subagent that reads it cold.

Run this before asking the user to approve a commit. Copilot already shows the user changed files, so this skill is only the agent's own pre-approval check.

**REQUIRED:** Launch one `general-purpose` subagent with the Agent tool, with `run_in_background: false`. Do not read `references/checks.md` yourself. Give the subagent this prompt, with `<absolute path>` resolved against this skill's directory:

> Review only the uncommitted changes under review: `git diff --cached` if the next commit's changes are staged, otherwise `git diff` plus every untracked file `git status` lists. Do not review already-committed branch changes. Read `<absolute path>/references/checks.md` and apply it. Report findings; change nothing.

Fix everything it turns up. When it flags more than one logical change, narrow the working set to the first commit's files here rather than presenting all of them: **REQUIRED:** Invoke the `ls-git:git-atomic-commit` skill. Then ask the user for commit approval, and state in one line what you fixed and anything you deliberately left alone.

## Rationalizations

| Thought                                      | Reality                                                     |
| -------------------------------------------- | ----------------------------------------------------------- |
| "The diff is small, I'll check it myself"    | You already read it once and missed it. Dispatch the agent. |
| "I know what's in it, I just wrote it"       | That's the problem the subagent exists to fix.              |
| "I'll run it in the background and present"  | Findings after the user reviews are worthless. Block on it. |
| "I'll let the subagent fix what it finds"    | It reports; you fix. Its edits never got reviewed.          |
| "The checks are loaded, I can just run them" | Loading the rubric is not the point. Fresh eyes are.        |
| "Dispatching costs a round trip"             | Cheaper than the round trip through the user.               |
| "Splitting means committing, so I'll ask"    | Narrowing to one commit's files is not committing.          |
