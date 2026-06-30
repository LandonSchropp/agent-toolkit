---
description: Use when a skill needs the user to interactively review code changes in revdiff mid-workflow — working changes, staged changes, or a specific commit — then read their annotations back. Takes a review mode.
user-invocable: false
---

# Interactive Review

**REQUIRED:** Use the `interactive-command` skill, running `scripts/review.sh <mode> [<sha>] --output <file>` with `review` as the window name.

Create an empty scratch file first and pass it as `--output`. When the window closes, `<file>` holds the user's review annotations — read it back and continue. The modes are `working`, `staged`, and `commit <sha>`; run `scripts/review.sh --help` for details.

## Handling an Existing Review

Before opening a review, check whether a `review` tmux window is already open:

```bash
tmux list-windows -a -F '#{window_name}' | grep -qx 'review' && echo "running" || echo "none"
```

If one is running, ask the user: "A review window is already open. Close it and open a new one?"

- If yes: kill the background `interactive-command.sh` process — its EXIT trap will close the window automatically. Then start a new review normally.
- If no: abort.
