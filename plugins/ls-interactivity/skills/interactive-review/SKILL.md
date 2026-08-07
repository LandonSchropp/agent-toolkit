---
description: Use when a skill needs the user to interactively review code changes in revdiff mid-workflow — working changes, staged changes, or a specific commit — then read their annotations back. Takes a review mode.
user-invocable: false
---

# Interactive Review

Run `scripts/interactive-review.sh <mode> [<sha>]` in the background. It opens revdiff in a new herdr tab named `review`, blocks until the tab closes, and prints the user's annotations to stdout, empty if they left none. The modes are `working`, `staged`, and `commit <sha>`; run `scripts/interactive-review.sh --help` for details.

For `working` and `staged` mode, the script's own exit code is the approve/deny decision: 0 if the user approved when prompted after closing revdiff, 1 if they denied (or closed the tab without answering). This is the only signal that matters — don't ask the user separately whether to commit or re-review. On approval, proceed to commit. On denial, address the annotations and invoke this skill again; do not attempt the commit in between, since the commit hook still blocks it either way. `commit` mode has nothing to approve and always exits 0.

## Choosing Working vs. Staged Mode

`working` mode reviews every uncommitted change in the worktree, including untracked files — not just the change under review. Before invoking the script, run `git status`. If the worktree has uncommitted changes unrelated to the commit being built, `working` mode would mix them into the review. In that case, stage only the files belonging to this commit (`git add <files>`) and invoke `staged` mode instead, so the review shows just the intended change.

## Handling a Stale Review

Before opening a review, check whether a `review` herdr tab is already open in the current workspace. It's always a leftover from an earlier review that didn't close — e.g. its background process was killed before cleanup ran — since only one review runs at a time in a workspace.

Close it automatically, without asking the user first, then open the new review normally. **REQUIRED:** Use the `herdr` skill for the close mechanics.

One addition specific to this skill: if a background `interactive-review.sh` process for that tab is still running, kill that process instead of closing the tab directly — its own cleanup closes the tab.
