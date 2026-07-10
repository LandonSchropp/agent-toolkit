---
description: Use when a skill needs the user to interactively review code changes in revdiff mid-workflow — working changes, staged changes, or a specific commit — then read their annotations back. Takes a review mode.
user-invocable: false
---

# Interactive Review

Run `scripts/interactive-review.sh <mode> [<sha>]` in the background. It opens revdiff in a new tmux window named `review`, blocks until the window closes, and prints the user's annotations to stdout, empty if they left none. The modes are `working`, `staged`, and `commit <sha>`; run `scripts/interactive-review.sh --help` for details.

## Handling an Existing Review

Before opening a review, check whether a `review` tmux window is already open in the current
session. Scope the check to the current session — orc runs many sessions on one shared tmux
server, so listing windows across all of them (`-a`) reports a sibling session's review window as
your own:

```bash
tmux list-windows -F '#{window_name}' | grep -qx 'review' && echo "running" || echo "none"
```

If one is running, ask the user: "A review window is already open. Close it and open a new one?"

- If yes: kill the background `interactive-review.sh` process — its cleanup closes the window automatically. Then start a new review normally.
- If no: abort.
