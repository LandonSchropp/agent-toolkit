---
description: Use when a skill needs to open a project as a new herdr workspace via herdr-project, or close a herdr tab it no longer needs. Covers herdr-project open's --worktree and --prompt flags, and finding a tab by label to close it.
user-invocable: false
---

# Herdr

**REQUIRED:** This is the canonical skill for herdr operations. Any skill that opens a new workspace or closes a tab must invoke this skill first, rather than calling `herdr`/`herdr-project` directly from memory.

## Opening a New Workspace

`herdr-project` opens one of your configured projects as a new herdr workspace, laying out that project's tabs:

```bash
herdr-project open <project> [--worktree <branch>] [--prompt <text>]
```

- Without `--worktree`, it opens the project's main workspace — this fails if that workspace is already open.
- With `--worktree <branch>`, it creates a new Git worktree on `<branch>` and opens that instead, so the same project can run in several workspaces at once.
- With `--prompt <text>`, it hands `<text>` to the project's agent tab through the `AGENT_PROMPT` environment variable, so the new agent starts already working instead of sitting idle.

Run `herdr-project --help` for the full reference.

## Listing Projects

Run `herdr-project list` for each configured project's name and path, as an aligned table at a terminal and tab-separated lines when piped. Run `herdr-project list --json` instead for the same projects as a JSON array, each with its tabs. Neither form says which workspaces or worktrees are open — `herdr workspace list` and `herdr worktree list` cover that.

## Closing a Tab

Find the tab by label, scoped to the workspace since labels aren't unique across workspaces, then close it if found:

```bash
tab_id=$(herdr tab list --workspace "$HERDR_WORKSPACE_ID" | jq -r --arg label "<label>" '.result.tabs[] | select(.label == $label) | .tab_id')
[[ -n "$tab_id" ]] && herdr tab close "$tab_id"
```

If the tab was opened by a script that traps termination signals to close its own tab on exit, end that script instead of closing the tab directly — its own cleanup handles closing the tab. Run such scripts with the Bash tool's `run_in_background` and stop yours with `TaskStop` on the task id it returns.

- **Never background a script with `&`.** `run_in_background` gives you a task id to stop it by and tells you when it finishes. `&` gives you neither.
- **Never hunt for a script's process.** `pkill -f`, `killall`, and `ps | grep | xargs kill` match every workspace and agent session on the machine, killing other sessions' tabs and the user's editors along with yours. A filter that looks scoped, like `grep "name review"`, is the worst: that label is identical in every workspace.

A leftover tab from an earlier session has no task id. Close that one by tab id, scoped to `$HERDR_WORKSPACE_ID` as above.

## Closing a Workspace

To close an entire workspace — e.g. tearing down a finished worktree — use the `ls-agent:close-workspace` skill instead; it also merges the branch and checks it's safe to remove.
