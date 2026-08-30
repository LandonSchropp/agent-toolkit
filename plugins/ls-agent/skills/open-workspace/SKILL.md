---
description: Use when a task needs its own checkout of a project — delegating work to another agent, or starting a branch that should run alongside the current one — and a herdr workspace has to be opened for it.
---

# Open Workspace

Opens a project's Git worktree as a herdr workspace and waits until its agent is ready.

```bash
scripts/open-workspace.sh --project <name> --worktree <branch>
```

It prints the workspace ID, the handle for prompting that agent.

Name the project as `herdr-project list` does. The branch does not need to exist.

## Two Workspaces Open

`herdr-project open --worktree` opens the project's main workspace as well as the worktree's. The script returns the worktree's agent, never the main one. Leave the main workspace alone: closing it is the user's call, not a cleanup step.

## Closing

The agent working in the workspace closes it, from inside. Don't invoke `ls-agent:close-workspace` from here: it closes whatever `$HERDR_WORKSPACE_ID` points at, which is your own workspace, not the one you just opened. `herdr-project close --worktree` is no better — it destroys the checkout without checking the work is merged and pushed, and leaves the branch behind.

## Rationalizations

| Thought                                          | Reality                                                                        |
| ------------------------------------------------ | ------------------------------------------------------------------------------ |
| "I'll call `herdr-project open` directly"        | Then you have no workspace id, and the agent may not be ready. Use the script. |
| "The agent is up as soon as the command returns" | It reports `unknown` until its TUI settles and rejects prompts until then.     |
| "Two workspaces opened, I should close one"      | Expected. The main workspace is the user's, not litter.                        |
| "I'll find the workspace by its checkout path"   | herdr slugifies the branch into that path. The script asks Git instead.        |
