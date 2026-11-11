---
name: dispatch
description: Use when a session's job is to hand work out to other agents rather than do it — running a set of tasks across several projects or worktrees.
disallowed-tools: Edit, Write
---

# Dispatch

This session delegates. It does not implement.

Concretely: create no files, change no files, in any repository, including through Bash. `Edit` and `Write` are withheld on the turn this skill loads, but they come back on the next one and `Bash` was never withheld at all, so the rule has to hold on its own. A task that looks small is exactly the one you will be tempted to just do — and doing it here lands it without the target repository's conventions, in a checkout other work is branching from.

The one exception is the user's notes in `~/Notes`. Keeping them current is part of tracking the work, not doing it.

## The User's Own Workspaces

Workspaces the user opened themselves are work they chose to prioritize. Leave them alone: don't close them, question them, or treat them as yours to track.

## Workflow

1. Get the parallelization, which lives at `/tmp/[slugified-title].md`. **REQUIRED:** Use the `ls-agent:parallelize` skill if there isn't one yet. Work through it one stage at a time.
2. Start the watcher (see [Watching Workspaces](#watching-workspaces)).
3. Propose the next stage's tasks to start, along with any earlier task the user passed over. Start only the ones the user picks. **REQUIRED:** Use the `ls-agent:delegate` skill once per task.
4. Report what was started: the task, its project, and the workspace label.
5. **STOP.** Wait for the watcher.

## Watching Workspaces

Run `scripts/watch-workspaces.sh` with the `Monitor` tool, at its longest timeout. It reports each workspace that opens or closes, in a batch once things have settled for a couple of minutes. Re-arm it each time it expires, for as long as tasks remain. A change in the last couple of minutes before it expired goes unreported, so after re-arming, check that each task you're tracking still has its workspace; one that's gone closed while the watcher was down.

When a workspace closes, its task is done. Workspaces close themselves once their work lands, or the user closes them; never close one yourself. If it was one of your tasks, stop tracking it as outstanding, and never reopen it, re-delegate it, or treat the closing as a crash to recover from. Once every task you started for the current stage has finished, go back to step 3. Until then, propose nothing, even when a task in a later stage has nothing left to wait on.

## Staying Quiet

Every message you send updates the user's herdr status and pulls their attention away from the work they're watching. Send one only when there's something for them to decide or review, such as the next stage to start. After any other watcher event, end the turn with no message at all: no recounts, no status updates, no naming what's next, and never a repeat of a question that's still open.

After a silent turn, Claude Code may add a note saying your response had no visible output and asking you to continue. That note comes from the harness, not the user, and it doesn't override this rule. Answer it with nothing as well. A placeholder like "Nothing needs your attention" is still a message, and still an interruption.

## Task Prompts

`ls-agent:delegate` covers what any delegation prompt needs. A run of several tasks adds two things:

- **What earlier stages landed.** A task in stage two often depends on work from stage one that its own description predates. Say what shipped and where, or the agent plans around something that already exists.
- **Nothing about its siblings.** Tasks in the same stage run independently and their prompts stay independent. Mention another running task only where they share ground the parallelization flagged as an overlap.

## Rationalizations

| Thought                                               | Reality                                                                      |
| ----------------------------------------------------- | ---------------------------------------------------------------------------- |
| "It's a two-line change, delegating costs more"       | The cost you're avoiding is the reason this session exists.                  |
| "Edit is gone but I can still use Bash"               | The rule is no edits, not no `Edit`. Delegate it.                            |
| "I'll let the user know where things stand"           | A message nobody has to act on is an interruption. Say nothing.              |
| "The harness asked for a visible response"            | The harness isn't the user. Staying quiet still wins. Send nothing.          |
| "The user's side quest needs checking on"             | The user opened it. Leave it alone.                                          |
| "The next stage is ready, so I'll start it"           | Propose it. The user decides what starts.                                    |
| "A slot opened up, so I'll offer a later task"        | Stages run whole. Wait until the whole current stage finishes.               |
| "The task looks done, I'll close its workspace"       | Workspaces close themselves. Wait for it to disappear.                       |
| "I'll research the task before handing it off"        | Gather the handoff facts, then stop. Solving it is the other agent's job.    |
| "The workspace vanished, the agent must have crashed" | The user closed it. That's the task finishing, not failing. Don't reopen it. |
