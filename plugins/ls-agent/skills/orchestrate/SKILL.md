---
name: orchestrate
description: Use when a session's job is to hand work out to other agents rather than do it — running a set of tasks across several projects or worktrees, a few at a time.
disallowed-tools: Edit, Write
---

# Orchestrate

This session delegates. It does not implement.

Concretely: create no files, change no files, in any repository, including through Bash. `Edit` and `Write` are withheld on the turn this skill loads, but they come back on the next one and `Bash` was never withheld at all, so the rule has to hold on its own. A task that looks small is exactly the one you will be tempted to just do — and doing it here lands it without the target repository's conventions, in a checkout other work is branching from.

The one exception is the user's notes in `~/Notes`. Keeping them current is part of tracking the work, not doing it.

## Active Tasks

The user can keep track of three tasks at once. Past that, there's a risk of them getting overwhelmed and losing track. Never start a new task while three or more are active.

To count the active tasks, count the workspaces in `herdr workspace list`, leaving out:

- **This session's own workspace:** The orchestrator isn't a task the user tracks.
- **`plan-day`:** Planning, not work.
- **Parked workspaces:** Any workspace whose label ends in `park` or `parked`.

Workspaces the user opened themselves are active tasks too. They chose to prioritize that work, so leave them alone: don't close them, question them, or treat them as yours to track.

When three tasks are active, name the task that's next and wait. Patience is the job here.

## Workflow

1. Get the parallelization, which lives at `/tmp/[slugified-title].md`. **REQUIRED:** Use the `ls-agent:parallelize` skill if there isn't one yet. A task is ready once every task it waits on has finished and fewer than three tasks are active.
2. Start the watcher (see [Watching Workspaces](#watching-workspaces)).
3. Propose the ready tasks to start, in stage order, without going past three active tasks. Start only the ones the user picks. **REQUIRED:** Use the `ls-agent:delegate` skill once per task.
4. Report what was started: the task, its project, and the workspace label.
5. **STOP.** Wait for the watcher.

## Watching Workspaces

Run `scripts/watch-workspaces.sh` with the `Monitor` tool, at its longest timeout. It prints a line whenever a workspace opens or closes. Re-arm it each time it expires, for as long as tasks remain.

When a workspace closes, its task is done. Workspaces close themselves once their work lands, or the user closes them; never close one yourself. If it was one of your tasks, stop tracking it as outstanding, and never reopen it, re-delegate it, or treat the closing as a crash to recover from. Then go back to step 3.

When a workspace opens, recount the active tasks. Say nothing unless that changes what you'd propose next.

## Task Prompts

`ls-agent:delegate` covers what any delegation prompt needs. A run of several tasks adds two things:

- **What earlier stages landed.** A task in stage two often depends on work from stage one that its own description predates. Say what shipped and where, or the agent plans around something that already exists.
- **Nothing about its siblings.** Tasks in the same stage run independently and their prompts stay independent. Mention another running task only where they share ground the parallelization flagged as an overlap.

## Rationalizations

| Thought                                               | Reality                                                                      |
| ----------------------------------------------------- | ---------------------------------------------------------------------------- |
| "It's a two-line change, delegating costs more"       | The cost you're avoiding is the reason this session exists.                  |
| "Edit is gone but I can still use Bash"               | The rule is no edits, not no `Edit`. Delegate it.                            |
| "A fourth task is ready, the user can handle it"      | Three is the limit. Name it as next and wait.                                |
| "The user's own side quests aren't my tasks"          | They're still active tasks. Count them.                                      |
| "There's room, so I'll start the next task"           | Propose it. The user decides what starts.                                    |
| "The task looks done, I'll close its workspace"       | Workspaces close themselves. Wait for it to disappear.                       |
| "I'll research the task before handing it off"        | Gather the handoff facts, then stop. Solving it is the other agent's job.    |
| "The workspace vanished, the agent must have crashed" | The user closed it. That's the task finishing, not failing. Don't reopen it. |
