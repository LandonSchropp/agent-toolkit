---
description: Use when a skill needs to open a project as a new herdr workspace via herdr-project, or close a herdr tab it no longer needs. Covers herdr-project create's --worktree and --prompt flags, and finding a tab by label to close it.
user-invocable: false
---

# Herdr

**REQUIRED:** This is the canonical skill for herdr operations. Any skill that opens a new workspace or closes a tab must invoke this skill first, rather than calling `herdr`/`herdr-project` directly from memory.

## Opening a New Workspace

`herdr-project` opens one of your configured projects as a new herdr workspace, laying out that project's tabs:

```bash
herdr-project create <project> [--worktree <branch>] [--prompt <text>]
```

- Without `--worktree`, it opens the project's main workspace — this fails if that workspace is already open.
- With `--worktree <branch>`, it creates a new Git worktree on `<branch>` and opens that instead, so the same project can run in several workspaces at once.
- With `--prompt <text>`, it hands `<text>` to the project's agent tab through the `AGENT_PROMPT` environment variable, so the new agent starts already working instead of sitting idle.

Run `herdr-project --help` for the full reference.

## Listing Projects

Run `herdr-project list` for the configured projects and their paths, one per line as `<name>\t<path>`. Run `herdr-project list --json` instead for a JSON array.

## Closing a Tab

Find the tab by label, scoped to the workspace since labels aren't unique across workspaces, then close it if found:

```bash
tab_id=$(herdr tab list --workspace "$HERDR_WORKSPACE_ID" | jq -r --arg label "<label>" '.result.tabs[] | select(.label == $label) | .tab_id')
[[ -n "$tab_id" ]] && herdr tab close "$tab_id"
```

If the tab was opened by a script that traps termination signals to close its own tab on exit (like `interactive-command.sh`), kill that background process instead of closing the tab directly — its own cleanup handles it.

## Closing a Workspace

To close an entire workspace — e.g. tearing down a finished worktree — use the `close-workspace` skill instead; it also merges the branch and checks it's safe to remove.
