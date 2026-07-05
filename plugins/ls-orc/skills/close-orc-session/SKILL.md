---
description: Use when closing an orc session. Merges the session's completed, reviewed branch into the default branch, confirms origin is in sync, then deletes the orc worktree and tmux session.
disable-model-invocation: true
---

# Close Orc Session

Closes an orc session: merges the branch into the default branch, verifies everything is pushed, then deletes the session's worktree and tmux session. The capstone once the work is committed and reviewed.

This skill deletes a worktree, so every step must succeed first. If the merge cannot complete — uncommitted or unreviewed changes, a conflict, or a diverged or unpushed default branch — **STOP** and leave the session intact.

## Process

Every orc session exports its project and session into the shell as `$ORC_PROJECT` and `$ORC_SESSION`. The steps below use those variables directly; if either is empty you are not inside an orc session — **STOP**.

1. **Merge the branch.** Skip this step if `$ORC_SESSION` is `main` — there is no feature branch to merge. Otherwise, **REQUIRED:** use the `git-merge-into-main` skill. It enforces the committed-and-reviewed preconditions, rebases onto the default branch, fast-forwards, pushes, and deletes the branch; it is idempotent when the branch is already merged. **STOP** if it cannot complete the merge — do not delete the session.

2. **Verify origin is in sync.** From the default branch's worktree, `git fetch`, then confirm the local default branch equals `origin/<default>`. **STOP** if they diverge or anything is unpushed — resolve it first. Once the session is deleted, its worktree and any commits left in it are gone.

3. **Delete the session.** Run the deletion as the final action:

   ```bash
   orc delete "$ORC_PROJECT" "$ORC_SESSION"
   ```

   You are inside the session being deleted, so orc hands the teardown to a detached worker that kills the tmux session and removes the worktree after this pane dies. Expect the session to terminate; do not run further commands.

## Rationalizations

| Thought                                         | Reality                                                                                          |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| "I'll delete the session, then merge later"     | Merge and verify the push FIRST. `orc delete` destroys the worktree and its commits.             |
| "The merge bailed, but I'll delete anyway"      | If `git-merge-into-main` could not finish, STOP. Never delete a session with unmerged work.      |
| "`orc delete` on the current session is unsafe" | orc spawns a detached worker for exactly this. It is safe and intended.                          |
| "The branch looks merged, skip the verify"      | Confirm the local default equals origin BEFORE deleting. Unpushed commits die with the worktree. |
| "I'm on main, skip the merge and delete"        | Skip the merge step, but still verify the push and delete the session.                           |
| "I'll cd out and delete from elsewhere"         | Run `orc delete` from the session; the detached worker handles the teardown.                     |
