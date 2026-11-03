---
name: merge-pull-request
description: Use when merging a single GitHub pull request. Handles pre-flight checks, waits for CI, and executes the merge with the repo's default method or merge queue.
---

# Merge Pull Request

This skill runs inside herdr and merges a pull request opened from this workspace's branch. Pass `--pull-request-url <url>` to each script.

## Process

1. **Wait until ready:** Run `herdr-pull-request-status watch --workspace "$HERDR_WORKSPACE_ID"` with the `Monitor` tool, at its longest timeout, and re-arm it each time it expires. Wait for the pull request's line to show `ready to merge`. `waiting for CI` and `in merge queue` resolve on their own. Any other status is a blocker, such as `CI failed`, `changes requested` or `waiting for review`, so stop and surface it to the user. Never call `herdr-pull-request-status add` here, since it attaches the pull request to this workspace's sidebar.

2. **Merge:** Run `scripts/merge-pull-request.sh`. Detects whether the target branch uses a merge queue — if so, adds the pull request to the queue without a strategy flag. Otherwise detects the repo's allowed methods (rebase > squash > merge commit) and merges with `--delete-branch`.

3. **Confirm:** Run `scripts/wait-for-pull-request-to-be-merged.sh`. Polls until the pull request state is `MERGED`, and fails if it leaves the merge queue without merging. Required when a merge queue is involved since the merge completes asynchronously; run it in the background so the user can keep working, and if it fails, find out why from the pull request's checks and tell the user.

## Rationalizations

| Thought                                                        | Reality                                                                       |
| -------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| "CI is almost done, I'll skip the wait"                        | Wait for `ready to merge`. `watch` handles the wait.                          |
| "The pull request is blocked on approvals, I'll use `--admin`" | Admin bypass is a user decision, not the skill's. Surface the block and stop. |
