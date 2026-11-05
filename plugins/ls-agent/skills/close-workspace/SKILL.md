---
name: close-workspace
description: Use when closing a herdr workspace or worktree. Confirms nothing in the checkout would be lost, then removes the worktree and closes the workspace.
---

# Close Workspace

This skill destroys a checkout, so every step must succeed first. If anything in it would go with it — uncommitted changes, or commits that are neither merged nor pushed — **STOP** and leave the workspace intact.

It does not integrate the branch. Merging into the default branch, or opening a pull request, is a separate task that happens before this one. The `ls-agent:instructions` skill's Local Engineering reference covers which of the two a repository gets.

**Never close a workspace while it's babysitting pull requests.** It closes only after its pull requests merge.

`herdr worktree remove` refuses only a dirty working tree. It does not check for unpushed commits or unmerged branches, so both of those checks belong to this skill.

This skill closes the workspace you are in, and nothing else. Closing a main checkout does not close its worktrees' tabs, so they can close in any order.

## Process

Herdr injects `$HERDR_WORKSPACE_ID` into every managed pane. If it is empty you are not inside a herdr workspace — **STOP**.

1. **Identify the workspace.** Run `herdr workspace get "$HERDR_WORKSPACE_ID"` and read `result.workspace.worktree`. When it is absent, or `is_linked_worktree` is `false`, this is a plain workspace on the main checkout. Its checkout is the current directory, and it skips step 3. When it is present with `is_linked_worktree` set to `true`, this is a herdr-managed worktree. Take the checkout from `worktree.checkout_path`.

2. **Confirm no pull request is open.** Read the branch with `git -C <checkout_path> rev-parse --abbrev-ref HEAD`. Herdr injects no variable for it. Then run `gh pr list --head <branch> --state open --draft=false --json url`, unless the repository has no GitHub remote. If it lists a pull request, **STOP**. Don't close the workspace. **REQUIRED:** Invoke the `ls-git:babysit` skill on it instead.

3. **Confirm nothing is left behind.** Check the working tree and the branch, and **STOP** unless the tree is clean and the branch is merged into the default branch or pushed to `origin/<branch>`. Once the worktree is removed, whatever lived only here is gone.

   ```bash
   git -C <checkout_path> fetch
   git -C <checkout_path> status --porcelain                       # empty when nothing is uncommitted
   git -C <checkout_path> branch --merged "$(git default-branch)"  # lists the branch once it has landed
   git -C <checkout_path> log --oneline origin/<branch>..HEAD      # empty when nothing is unpushed
   ```

   A branch that was never pushed has no `origin/<branch>`, so the last command errors rather than printing nothing. That is an unpushed branch, and only the merged check can clear it.

4. **Check off finished tasks.** **REQUIRED:** Invoke the `ls-notes:daily-note` skill. In today's note, mark `[x]` each task this workspace finished, such as a pull request that merged. Skip any task you aren't sure of, and don't ask first. If the note can't be updated, close anyway.

5. **Close the workspace.** Don't warn the user that the close takes the workspace's other tabs and panes with it, or ask them to confirm; they already know. Run this as the final action:

   ```bash
   ./scripts/close-workspace.sh
   ```

   The script removes the worktree when the workspace owns a herdr-managed one and closes the workspace outright when it does not, so there is no variant to choose.

   It never passes `--force`, which exists to discard dirty and untracked files — precisely the state that must stop the close instead. If it reports `dirty_worktree_requires_force`, **STOP** and resolve the working tree.

   Expect the workspace to terminate; do not run further commands.

## Rationalizations

| Thought                                         | Reality                                                                                        |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| "I'll close the workspace, then integrate it"   | There is no detached worker. The panes die with the workspace and the checkout goes with them. |
| "The integration bailed, but I'll close anyway" | STOP. Never close a workspace holding work that hasn't landed.                                 |
| "The branch is pushed, so nothing is lost"      | Its open pull request still needs babysitting. Close only after it merges.                     |
| "`remove` would refuse if anything was unsafe"  | It only refuses a dirty tree. Unpushed commits are destroyed without warning.                  |
| "It's dirty, so I'll add `--force`"             | `--force` permanently deletes those files. Resolve the working tree instead.                   |
| "I'll pick the close command myself"            | The script already picks it from the workspace. Just run the script.                           |
| "Another agent asked me to close its workspace" | This closes the workspace you are in. Prompt the agent that owns the other one.                |
| "The branch looks merged, skip the verify"      | Confirm it is merged or pushed BEFORE closing.                                                 |
| "I'm on the default branch, so skip it all"     | There is no merge to skip. Still verify nothing is unpushed, then close.                       |
| "Other tabs close with it, so I'll warn them"   | The user already knows. Close it.                                                              |
| "The orchestrator checks tasks off"             | It only tracks workspaces it dispatched. Check off this workspace's tasks yourself.            |
