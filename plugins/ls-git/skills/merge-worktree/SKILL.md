---
description: Use when a finished worktree's branch has been reviewed and committed and needs to land. Rebases onto the latest default branch, then either fast-forwards it into the default branch (personal direct-to-main repos) or pushes it for a pull request (shared feature-branch repos).
---

# Merge Worktree

Lands the branch of a linked worktree once the work is reviewed and committed. Two modes:

- **direct-to-main**: rebase onto the default branch and fast-forward it into the default branch. For personal repos that work off `main`.
- **feature-branch**: rebase onto the default branch and push the branch for a pull request. For shared repos that never merge straight to `main`.

This skill assumes the work is already committed and reviewed — it does no reviewing and creates no commits.

## Process

1. **Check preconditions:** Confirm the work is committed and has been reviewed. Stop if either is missing — do not merge unreviewed work.

2. **Recommend and confirm the mode:** Run `scripts/recommend-merge-mode.sh`. It inspects default-branch protection and repository ownership and prints a recommended mode with reasoning. Use it to decide which mode is likely right, then ask the user in plain language — for example, "Want me to merge this straight into `main`, or push the branch and open a pull request?" Do not surface the internal mode names (`direct-to-main` / `feature-branch`) to the user. The recommendation is a suggestion — the user decides.

3. **Land the branch:**

   **direct-to-main:** Run `scripts/merge-into-main.sh` (no arguments — it detects the branch, default branch, and remote). It rebases the branch onto the latest default branch, fast-forwards the default branch from its own worktree, and pushes. If the rebase hits conflicts, the script stops — resolve them, finish the rebase, then re-run.

   **feature-branch:** Run `scripts/push-feature-branch.sh` (no arguments — it detects the branch, default branch, and remote). It rebases the branch onto the latest default branch and pushes it (with `--force-with-lease`) ready for a pull request. If the branch is already shared with teammates, confirm before running — the rebase rewrites its history. To then merge the pull request, use the `merge-pull-request` skill.

4. **Offer cleanup (must be the final step):** Once the branch has landed in either mode, offer to run `orc delete <project> <session>` to remove the linked worktree and its tmux session. `orc delete` does not delete the branch, so a pushed feature branch is preserved and stays available from the main worktree for its pull request. Determine the project and session from the current tmux session name — orc names it `<project>/<session>`, so run `tmux display-message -p '#{session_name}'` and split on the first slash.

   NEVER run `orc delete` automatically. Only run it after the user explicitly approves, and only as the very last action. It deletes the session this agent is running in, so running it ends the session and kills the agent — nothing after it will execute. If the user declines or does not answer, stop and leave the worktree in place.

## Rationalizations

| Thought                                                  | Reality                                                                                                                        |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| "I'll just merge into main without asking"               | The mode is the user's call. Always confirm before landing.                                                                    |
| "`main` isn't protected, so direct-to-main on this repo" | Ownership matters too. A shared repo can have an unprotected default. Confirm.                                                 |
| "The branch is simple, I'll skip the rebase"             | Always rebase onto the latest default so the fast-forward is clean.                                                            |
| "The rebase conflicted, I'll force or `--skip`"          | Stop and surface the conflict. The user resolves it.                                                                           |
| "There are uncommitted changes, I'll merge anyway"       | Work must be committed and reviewed first. The script refuses a dirty tree.                                                    |
| "Rebasing a shared feature branch is fine"               | The rebase rewrites history. Confirm with the user before rebasing a branch teammates use.                                     |
| "I'll run `orc delete` to tidy up"                       | Never auto-run it. It deletes the current session and kills the agent. Offer; run only on explicit approval, as the last step. |
