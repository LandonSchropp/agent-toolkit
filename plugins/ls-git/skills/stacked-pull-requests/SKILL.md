---
name: stacked-pull-requests
description: Use when working with a stack of GitHub pull requests — creating branches, keeping the stack in sync, or merging in order. Covers Git Town setup, PR targeting, rebasing, and landing the stack.
---

# Stacked Pull Requests

Uses Git Town to manage parent/child branch relationships. **REQUIRED:** Run `git town help` for the full command list, or `git town <command> --help` for documentation on a specific command.

## Creating a Stack

1. Create the first branch off main: `git town hack <branch-name>`.
2. From that branch, create each subsequent child: `git town append <next-branch-name>`. (`append` always creates off the current branch; `hack` always creates off main.)
3. Create a PR for each branch targeting its parent branch (not main). GitHub shows only that branch's changes to reviewers.
4. Note in each PR description that it's part of a stack and link to the related PRs.
5. Verify the stack is wired correctly: run `scripts/list-pull-request-tree.rb --branch <any-branch>` and confirm all PRs appear in the expected order.

## Keeping the Stack in Sync

When upstream changes or a parent branch is updated, run `git town sync --stack` to sync every branch in the stack. If conflicts arise:

1. Resolve them in the conflicted branch.
2. Stage the resolved files.
3. Run `git town continue`.
4. Push when done.

## Merging

Merge oldest ancestor first. **REQUIRED:** Confirm the full merge order with the user before merging anything.

1. **Discover the tree:** Run `scripts/list-pull-request-tree.rb --branch <name>`. Pass any branch in the tree — the script walks up to the oldest ancestor and down through all descendants.

2. **For each PR in order:**

   a. **Retarget the next PR** (if one exists): Run `scripts/retarget-pull-request-to-default-branch.sh --pull-request-url <next-url>`. When merging via the CLI, GitHub does not auto-retarget dependent PRs — it closes them instead (cli/cli#1168). Retargeting manually before each merge prevents this.

   b. **Merge the current PR:** **REQUIRED:** Use the `ls:merge-pull-request` skill.

   c. **Sync the remaining stack:** Run `git town sync --stack` from any remaining branch. Git Town will detect the merged branch is gone and rebase the next branch onto main.

   On repos that squash-merge, verify the child branch has no duplicate commits from the just-merged branch. If duplicates are present, strip them with `git rebase --onto main <last-commit-of-merged-branch> <child-branch>`, then push with `--force-with-lease`.

## Rationalizations

| Thought                                       | Reality                                                                                                             |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| "I'll use `git town hack` for child branches" | `hack` creates branches off main. Use `git town append` from the parent branch instead.                             |
| "I'll create PRs targeting main"              | PRs must target their parent branch so reviewers see only that branch's changes.                                    |
| "I'll skip retargeting — GitHub handles it"   | GitHub does not auto-retarget when merging via CLI — it closes the next PR instead (cli/cli#1168). Always retarget. |
| "I'll skip syncing after a merge"             | The next PR's branch will be stale. Always sync after each merge.                                                   |
| "I'll merge all at once"                      | Each PR must land on the default branch before the next is rebased onto it.                                         |
