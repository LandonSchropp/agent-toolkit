---
description: Use when closing a herdr workspace. Merges the workspace's completed, reviewed branch into the default branch, confirms origin is in sync, then removes the worktree and closes the workspace.
disable-model-invocation: true
---

# Close Workspace

This skill destroys a checkout, so every step must succeed first. If the merge cannot complete — uncommitted or unreviewed changes, a conflict, or a diverged or unpushed default branch — **STOP** and leave the workspace intact.

`herdr worktree remove` refuses only a dirty working tree. It does not check for unpushed commits, unmerged branches, or stashes, so every one of those checks belongs to this skill.

## Process

Herdr injects `$HERDR_WORKSPACE_ID` into every managed pane. If it is empty you are not inside a herdr workspace — **STOP**.

1. **Identify the workspace.** Run `herdr workspace get "$HERDR_WORKSPACE_ID"` and read `result.workspace.worktree`. When it is absent, or `is_linked_worktree` is `false`, this is a plain workspace on the main checkout: skip to step 4. When it is present with `is_linked_worktree` set to `true`, this is a herdr-managed worktree; take the checkout from `worktree.checkout_path` and continue.

2. **Merge the branch.** Read the branch with `git -C <checkout_path> rev-parse --abbrev-ref HEAD`; herdr injects no variable for it. Skip this step when that branch is already the default branch. Otherwise, **REQUIRED:** use the `git-merge-into-main` skill. It enforces the committed-and-reviewed preconditions, rebases onto the default branch, fast-forwards, pushes, and deletes the branch. **STOP** if it cannot complete the merge.

3. **Verify origin is in sync.** From the default branch's worktree, `git fetch`, then confirm the local default branch equals `origin/<default>`. **STOP** if they diverge or anything is unpushed. Once the worktree is removed, any commits left in it are gone.

4. **Close the workspace.** Run this as the final action:

   ```bash
   ./scripts/close-workspace.sh
   ```

   The script removes the worktree when the workspace owns a herdr-managed one and closes the workspace outright when it does not, so there is no variant to choose. It never passes `--force`, which exists to discard dirty and untracked files — precisely the state that must stop the close instead. If it reports `dirty_worktree_requires_force`, **STOP** and resolve the working tree.

   Expect the workspace to terminate; do not run further commands.

## Rationalizations

| Thought                                        | Reality                                                                                        |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| "I'll close the workspace, then merge later"   | There is no detached worker. The panes die with the workspace and the checkout goes with them. |
| "The merge bailed, but I'll close anyway"      | If `git-merge-into-main` could not finish, STOP. Never close a workspace with unmerged work.   |
| "`remove` would refuse if anything was unsafe" | It only refuses a dirty tree. Unpushed commits are destroyed without warning.                  |
| "It's dirty, so I'll add `--force`"            | `--force` permanently deletes those files. Resolve the working tree instead.                   |
| "I'll pick the close command myself"           | The script already picks it from the workspace. Just run the script.                           |
| "The branch looks merged, skip the verify"     | Confirm the local default equals origin BEFORE closing.                                        |
| "I'm on the default branch, so skip it all"    | Skip only the merge. Still verify the push, then close.                                        |
