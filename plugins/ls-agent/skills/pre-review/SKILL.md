---
description: Use when a commit's changes are finished and about to be presented for review. Runs the checks that catch the objections the user would otherwise raise, before they spend time reviewing.
---

# Pre-Review

You wrote this diff, so you are the worst available reviewer of it. Hand it to a subagent that reads it cold.

**REQUIRED:** Launch one `general-purpose` subagent with the Agent tool, with `run_in_background: false`. Do not read `references/checks.md` yourself. Give the subagent this prompt, with `<absolute path>` resolved against this skill's directory:

> Review the changes under review: `git diff --cached` if anything is staged, otherwise `git diff HEAD` plus every untracked file `git status` lists. Read `<absolute path>/references/checks.md` and apply it. Report findings; change nothing.

Fix everything it turns up. When it flags more than one logical change, narrow the working set to the first commit's files here rather than presenting all of them: **REQUIRED:** Invoke the `ls-git:git-atomic-commit` skill. Then continue to the interactive review, and state in one line what you fixed and anything you deliberately left alone.

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
