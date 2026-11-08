---
name: open-workspace
description: Use when a task needs its own checkout of a project — delegating work to another agent, or starting a branch that should run alongside the current one — and a herdr workspace has to be opened for it.
---

# Open Workspace

Opens a project's Git worktree as a herdr workspace and waits until its agent is ready.

```bash
scripts/open-workspace.sh --project <name> --branch <branch> --label <label>
```

It prints the workspace ID, the handle for prompting that agent. The branch does not need to exist.

Use this script in place of `herdr-project open`. **REQUIRED:** Invoke the `herdr-project` skill for the project names and for the main workspace that opens beside the worktree's. The script returns the worktree's agent, never the main one.

## Labeling the Workspace

The label is what the herdr sidebar shows, and it truncates past sixteen characters. The branch name is usually too long for that, so give the workspace a shorter label of its own; the script rejects one that doesn't fit.

Name the task in two or three hyphenated words. Drop everything the branch carries for Git's sake rather than the reader's, starting with the Linear issue key: `abc-123-collapse-duplicate-sessions` is a fine branch and a useless label, where `collapse-dupes` reads at a glance.

## Interrupted Opens

When the user stops the script before it prints a workspace ID, the workspace may already be open with an idle agent and no prompt. Deal with whatever the user interrupted for first. Then run `herdr worktree list --cwd <project path>` and look for the branch. If it has an open workspace, tell the user once, naming the workspace by its label, and ask whether to send the prompt or close it. Do neither on your own, because the user stopped the open on purpose.

## Closing

The agent working in the workspace closes it, from inside, never the agent that opened it. Don't invoke `ls-agent:close-workspace` from here. It closes whatever `$HERDR_WORKSPACE_ID` points at, which is your own workspace, not the one you just opened.

## Rationalizations

| Thought                                          | Reality                                                                                                       |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| "I'll call `herdr-project open` directly"        | Then you have no workspace id, and the agent may not be ready. Use the script.                                |
| "The agent is up as soon as the command returns" | It reports `unknown` until its TUI settles and rejects prompts until then.                                    |
| "I'll find the workspace by its checkout path"   | herdr slugifies the branch into that path. The script matches `herdr worktree list`'s `branch` field instead. |
| "I'll pass the branch name as the label"         | The sidebar truncates it mid-word. Give the task a short name of its own.                                     |
| "The call was rejected, so nothing opened"       | The workspace can open before the script is stopped. Check for the branch and tell the user.                  |
