---
description: Use when merging a stack of GitHub pull requests in order. Discovers the stack from the current branch, confirms with the user, then handles retargeting, merging, and branch syncing autonomously.
---

# Merge Stacked Pull Requests

Merges an ordered stack of pull requests one at a time. For each pull request, retargets the next one to the default branch before merging, then syncs the local branch stack via git-town. Uses the `ls:merge-pull-request` skill for each individual merge.

Pass `--pull-request-url <url>` to each script. Use a 5-minute tool timeout on polling scripts — if a script times out, check for issues and re-run up to 5 times.

## Process

1. **Discover the tree:** Run `scripts/list-pull-request-tree.rb --branch <name>` from the repository. Pass any branch in the tree — the script walks up to the oldest ancestor and down through all descendants.

2. **Confirm with the user:** Show the ordered list and ask: "These pull requests will be merged in this order. Would you like to proceed?" Wait for approval before merging anything.

3. **For each pull request in order:**

   a. **Retarget the next pull request** (if one exists): Run `scripts/retarget-pull-request-to-default-branch.sh --pull-request-url <next-url>`. This prevents GitHub from auto-closing it when the current pull request's head branch is deleted on merge.

   b. **Merge the current pull request:** **REQUIRED:** Use the `ls:merge-pull-request` skill, passing the current pull request URL.

   c. **Sync the branch stack:** Run `git town sync` to rebase the remaining branches onto the updated default branch. If conflicts arise, resolve them and push before continuing.

## Rationalizations

| Thought                                                   | Reality                                                                                           |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| "I'll skip retargeting — GitHub handles it automatically" | GitHub's auto-retarget is broken. Skipping it auto-closes the next pull request. Always retarget. |
| "I'll skip git town sync"                                 | The next pull request's branch will be stale. Sync after every merge.                             |
| "I'll merge all at once"                                  | Each pull request must land on the default branch before the next is rebased onto it.             |
