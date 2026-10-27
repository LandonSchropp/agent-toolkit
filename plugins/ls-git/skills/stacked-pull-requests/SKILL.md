---
name: stacked-pull-requests
description: Use when working with a stack of GitHub pull requests — creating branches, keeping the stack in sync, or merging them. Covers Git Town setup, PR targeting, native GitHub stacks, rebasing, and landing the stack.
---

# Stacked Pull Requests

Uses Git Town to manage parent/child branch relationships. **REQUIRED:** Run `git town help` for the full command list, or `git town <command> --help` for documentation on a specific command.

## Creating a Stack

1. Create the first branch off main: `git town hack <branch-name>`.
2. From that branch, create each subsequent child: `git town append <next-branch-name>`. (`append` always creates off the current branch; `hack` always creates off main.)
3. Create a PR for each branch targeting its parent branch (not main). GitHub shows only that branch's changes to reviewers.
4. Link the PRs into a native GitHub stack: `gh stack link <pr-number> <pr-number> ...`, bottom to top. Pass PR numbers, never branch names; `gh stack link` pushes a branch argument, and opens a PR for it if it has none. If the command fails because the repository doesn't support stacks, note in each PR description that it's part of a stack and link to the related PRs instead.
5. Verify the stack is wired correctly: run `scripts/list-pull-request-tree.rb --branch <any-branch>` and confirm all PRs appear in the expected order.

## Keeping the Stack in Sync

When upstream changes or a parent branch is updated, run `git town sync --stack` to sync every branch in the stack. If conflicts arise:

1. Resolve them in the conflicted branch.
2. Stage the resolved files.
3. Run `git town continue`.
4. Push when done.

## Merging

Merge oldest ancestor first. **REQUIRED:** Confirm the full merge order with the user before merging anything.

1. **Discover the tree:** Run `scripts/list-pull-request-tree.rb --branch <name>`. Pass any branch in the tree — the script walks up to the oldest ancestor and down through all descendants. A native stack is one linear chain, so merge a tree that forks one chain at a time.

2. **Link the stack:** Run `gh stack link <pr-number> <pr-number> ...` with the chain's PR numbers, bottom to top. This is safe on PRs that are already stacked; it adds any that are missing. If the repository doesn't support stacks, skip to [Merging Without a Native Stack](#merging-without-a-native-stack).

3. **Merge the stack:** Run `gh stack merge <top-pr-number> --yes` with `--rebase`, `--squash` or `--merge`, whichever the repository allows first in that order (`gh repo view --json rebaseMergeAllowed,squashMergeAllowed,mergeCommitAllowed`). Without a flag, it uses your last-used method. It merges every PR up to and including that one in a single all-or-nothing operation, or adds them all to the merge queue when the base branch has one. GitHub checks reviews, CI and branch protection when the merge runs; if a PR is blocked, surface the error and stop. Never bypass a block.

4. **Confirm the merge:** If the base branch has a merge queue, wait for the top PR to merge. **REQUIRED:** Follow the confirm step of the `ls-git:merge-pull-request` skill, passing the top PR's URL.

5. **Clean up:** Run `git town sync` to delete the merged local branches.

### Merging Without a Native Stack

For each PR in order:

1. **Retarget the next PR** (if one exists): Run `scripts/retarget-pull-request-to-default-branch.sh --pull-request-url <next-url>`. When merging via the CLI, GitHub does not auto-retarget dependent PRs — it closes them instead (cli/cli#1168). Retargeting manually before each merge prevents this.

2. **Merge the current PR:** **REQUIRED:** Use the `ls-git:merge-pull-request` skill.

3. **Sync the remaining stack:** Run `git town sync --stack` from any remaining branch. Git Town will detect the merged branch is gone and rebase the next branch onto main.

   On repos that squash-merge, verify the child branch has no duplicate commits from the just-merged branch. If duplicates are present, strip them with `git rebase --onto main <last-commit-of-merged-branch> <child-branch>`, then push with `--force-with-lease`.

## Rationalizations

| Thought                                       | Reality                                                                                     |
| --------------------------------------------- | ------------------------------------------------------------------------------------------- |
| "I'll use `git town hack` for child branches" | `hack` creates branches off main. Use `git town append` from the parent branch instead.     |
| "I'll create PRs targeting main"              | PRs must target their parent branch so reviewers see only that branch's changes.            |
| "I'll merge the stack one PR at a time"       | GitHub blocks retargeting a stacked PR. Land a native stack with a single `gh stack merge`. |
| "I'll skip retargeting — GitHub handles it"   | Without a native stack, GitHub closes the next PR instead (cli/cli#1168). Always retarget.  |
| "I'll skip syncing after a merge"             | Without a native stack, the next PR's branch will be stale. Always sync after each merge.   |
