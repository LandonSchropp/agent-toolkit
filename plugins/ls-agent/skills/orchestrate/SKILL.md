---
description: Use when a session's job is to hand work out to other agents rather than do it — running a set of tasks across several projects or worktrees, a stage at a time.
disable-model-invocation: true
disallowed-tools: Edit, Write
---

# Orchestrate

This session delegates. It does not implement.

Concretely: create no files, change no files, in any repository, including through Bash. `Edit` and `Write` are withheld on the turn this skill loads, but they come back on the next one and `Bash` was never withheld at all, so the rule has to hold on its own. A task that looks small is exactly the one you will be tempted to just do — and doing it here lands it without the target repository's conventions, in a checkout other work is branching from.

## Workflow

1. Get the parallelization, which lives at `/tmp/[slugified-title].md`. **REQUIRED:** Use the `ls-agent:parallelize` skill if there isn't one yet.
2. Start the first stage. **REQUIRED:** Use the `ls-agent:delegate` skill once per task in it.
3. Report what was started: the task, its project, and the workspace id.
4. **STOP.** Do not start the next stage. The user watches the work land and tells you when they are ready.
5. On their word, tear down the finished stage's workspaces — **REQUIRED:** use the `ls-agent:close-workspace` skill — then start the next stage.

## Task Prompts

`ls-agent:delegate` covers what any delegation prompt needs. A run of several tasks adds two things:

- **What earlier stages landed.** A task in stage two often depends on work from stage one that its own description predates. Say what shipped and where, or the agent plans around something that already exists.
- **Nothing about its siblings.** Tasks in the same stage run independently and their prompts stay independent. Mention another running task only where they share ground the parallelization flagged as an overlap.

## Rationalizations

| Thought                                         | Reality                                                                   |
| ----------------------------------------------- | ------------------------------------------------------------------------- |
| "It's a two-line change, delegating costs more" | The cost you're avoiding is the reason this session exists.               |
| "Edit is gone but I can still use Bash"         | The rule is no edits, not no `Edit`. Delegate it.                         |
| "I'll start the next stage, it looks done"      | You don't know it landed. The user says when.                             |
| "I'll research the task before handing it off"  | Gather the handoff facts, then stop. Solving it is the other agent's job. |
