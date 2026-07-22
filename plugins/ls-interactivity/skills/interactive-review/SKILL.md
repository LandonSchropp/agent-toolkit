---
description: Use when a skill needs the user to interactively review code changes in revdiff mid-workflow — working changes, staged changes, or a specific commit — then read their annotations back. Takes a review mode.
user-invocable: false
---

# Interactive Review

Run `scripts/interactive-review.sh <mode> [<sha>]` in the background. It opens revdiff in a new herdr tab named `review`, blocks until the tab closes, and prints the user's annotations to stdout, empty if they left none. The modes are `working`, `staged`, and `commit <sha>`; run `scripts/interactive-review.sh --help` for details.

For `working` and `staged` mode, the script's own exit code is the approve/deny decision: 0 if the user approved when prompted after closing revdiff, 1 if they denied (or closed the tab without answering). This is the only signal that matters — don't ask the user separately whether to commit or re-review. On approval, proceed to commit. On denial, address the annotations and invoke this skill again; do not attempt the commit in between, since the commit hook still blocks it either way. `commit` mode has nothing to approve and always exits 0.

## Handling an Existing Review

Before opening a review, check whether a `review` herdr tab is already open in the
current workspace. Scope the check to `$HERDR_WORKSPACE_ID` — other workspaces run
their own sessions, so a sibling workspace's `review` tab is not yours:

```bash
herdr tab list | jq -e --arg ws "$HERDR_WORKSPACE_ID" '.result.tabs[] | select(.label == "review" and .workspace_id == $ws)' >/dev/null && echo "running" || echo "none"
```

If one is running, ask the user: "A review tab is already open. Close it and open a new one?"

- If yes: kill the background `interactive-review.sh` process — its cleanup closes the tab automatically. If no such process is still running, close the tab directly instead. Then start a new review normally.
- If no: abort.

```bash
herdr tab close "$(herdr tab list | jq -r --arg ws "$HERDR_WORKSPACE_ID" '.result.tabs[] | select(.label == "review" and .workspace_id == $ws) | .tab_id')"
```
