---
description: Use when a finished, reviewed branch is committed and needs to be merged into the default branch in a repo that integrates directly to `main` (not via pull request).
---

# Merge Into Main

Merges a finished branch into the default branch (e.g. `main`) by rebasing it on top, then fast-forwarding. For personal repos that integrate directly to `main` rather than through pull requests.

This skill does no reviewing and creates no commits. It does not manage worktrees.

## Process

1. **Check preconditions:** The branch must be committed with no unstaged files. It must also be reviewed by the user (not the same as a pull request review). Stop if either is missing.

2. **Rebase onto the default branch:** Find the default branch with `git default-branch`, then rebase the branch onto it. Always rebase, even for a trivial branch. Resolve any conflicts before continuing — do not `--skip` or force past them.

3. **Fast-forward and push:** Advance the default branch to the rebased branch with a fast-forward only (no merge commit), then push. If the default branch is checked out in another worktree, run the update from that worktree's directory — Git refuses to move a branch that is checked out elsewhere.

```bash
default_branch=$(git default-branch)

git rebase "$default_branch"
git -C <default-branch-worktree> merge --ff-only <branch>
git -C <default-branch-worktree> push origin "$default_branch"
```

## Rationalizations

| Thought                                            | Reality                                                                    |
| -------------------------------------------------- | -------------------------------------------------------------------------- |
| "The branch is simple, I'll skip the rebase"       | Always rebase onto the default branch first, so the fast-forward is clean. |
| "The rebase conflicted, I'll `--skip` or force"    | Resolve the conflict properly. Never discard commits to get past it.       |
| "I'll just merge it, a merge commit is fine"       | Fast-forward only. This skill keeps history linear.                        |
| "`main` won't move, I'll update it from here"      | If it's checked out in another worktree, update it from that worktree.     |
| "There are uncommitted changes, I'll merge anyway" | The branch must be committed and reviewed first. Stop.                     |
