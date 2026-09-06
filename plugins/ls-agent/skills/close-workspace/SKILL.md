---
name: close-workspace
description: Use when closing a herdr workspace or worktree. Confirms nothing in the checkout would be lost, then removes the worktree and closes the workspace.
---

# Close Workspace

This skill destroys a checkout, so every step must succeed first. If anything in it would go with it — uncommitted changes, or commits that are neither merged nor pushed — **STOP** and leave the workspace intact.

It does not integrate the branch. Merging into the default branch, or opening a pull request, is a separate task that happens before this one; the `ls-agent:instructions` skill's reviews reference covers which of the two a repository gets.

`herdr worktree remove` refuses only a dirty working tree. It does not check for unpushed commits or unmerged branches, so both of those checks belong to this skill.

This skill closes the workspace you are in, and nothing else. Closing a main checkout closes the tabs of every worktree branched from it, and those tabs only come back by hand, so the worktrees go first and the main checkout last.

## Process

Herdr injects `$HERDR_WORKSPACE_ID` into every managed pane. If it is empty you are not inside a herdr workspace — **STOP**.

1. **Identify the workspace.** Run `herdr workspace get "$HERDR_WORKSPACE_ID"` and read `result.workspace.worktree`. When it is absent, or `is_linked_worktree` is `false`, this is a plain workspace on the main checkout: skip to step 3. When it is present with `is_linked_worktree` set to `true`, this is a herdr-managed worktree; take the checkout from `worktree.checkout_path` and continue.

2. **Confirm nothing is left behind.** Read the branch with `git -C <checkout_path> rev-parse --abbrev-ref HEAD`; herdr injects no variable for it. Then check the working tree and the branch, and **STOP** unless the tree is clean and the branch is merged into the default branch or pushed to `origin/<branch>`. Once the worktree is removed, whatever lived only here is gone.

   ```bash
   git -C <checkout_path> fetch
   git -C <checkout_path> status --porcelain                       # empty when nothing is uncommitted
   git -C <checkout_path> branch --merged "$(git default-branch)"  # lists the branch once it has landed
   git -C <checkout_path> log --oneline origin/<branch>..HEAD      # empty when nothing is unpushed
   ```

   A branch that was never pushed has no `origin/<branch>`, so the last command errors rather than printing nothing. That is an unpushed branch, and only the merged check can clear it.

3. **Close the workspace.** Run this as the final action:

   ```bash
   ./scripts/close-workspace.sh
   ```

   The script removes the worktree when the workspace owns a herdr-managed one and closes the workspace outright when it does not, so there is no variant to choose. It refuses to close a main checkout whose worktrees are still open, and lists them — **STOP** and close those first.

   It never passes `--force`, which exists to discard dirty and untracked files — precisely the state that must stop the close instead. If it reports `dirty_worktree_requires_force`, **STOP** and resolve the working tree.

   Expect the workspace to terminate; do not run further commands.

## Rationalizations

| Thought                                         | Reality                                                                                        |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| "I'll close the workspace, then integrate it"   | There is no detached worker. The panes die with the workspace and the checkout goes with them. |
| "The integration bailed, but I'll close anyway" | STOP. Never close a workspace holding work that hasn't landed.                                 |
| "`remove` would refuse if anything was unsafe"  | It only refuses a dirty tree. Unpushed commits are destroyed without warning.                  |
| "It's dirty, so I'll add `--force`"             | `--force` permanently deletes those files. Resolve the working tree instead.                   |
| "I'll pick the close command myself"            | The script already picks it from the workspace. Just run the script.                           |
| "Another agent asked me to close its workspace" | This closes the workspace you are in. Prompt the agent that owns the other one.                |
| "I'll close the main checkout, it's finished"   | Its worktrees' tabs close with it, and restoring them is manual. Close the worktrees first.    |
| "The branch looks merged, skip the verify"      | Confirm it is merged or pushed BEFORE closing.                                                 |
| "I'm on the default branch, so skip it all"     | There is no merge to skip. Still verify nothing is unpushed, then close.                       |
