---
description: Use when merging a single GitHub pull request. Handles pre-flight checks, waits for CI, and executes the merge with the repo's default method or merge queue.
---

# Merge Pull Request

Pass `--pull-request-url <url>` to each script. Use a 5-minute tool timeout when running the polling scripts. If a script times out, check for any issues, then re-run it — repeat up to 5 times before giving up.

## Process

1. **Wait until ready:** Run `scripts/wait-for-pull-request-to-be-ready.sh`. Waits for CI to complete and verifies all static conditions (not draft, no conflicts, reviews approved). Exits immediately on any permanent blocker — stop and surface the error to the user.

2. **Merge:** Run `scripts/merge-pull-request.sh`. Detects whether the target branch uses a merge queue — if so, adds the pull request to the queue without a strategy flag. Otherwise detects the repo's allowed methods (squash > merge commit > rebase) and merges with `--delete-branch`.

3. **Confirm:** Run `scripts/wait-for-pull-request-to-be-merged.sh`. Polls until the pull request state is `MERGED`. Required when a merge queue is involved since the merge completes asynchronously.

## Rationalizations

| Thought                                                          | Reality                                                                       |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| "CI is almost done, I'll skip wait-for-pull-request-to-be-ready" | Use the script. It handles the wait.                                          |
| "The pull request is blocked on approvals, I'll use `--admin`"   | Admin bypass is a user decision, not the skill's. Surface the block and stop. |
