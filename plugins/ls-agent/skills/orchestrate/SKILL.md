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

## Writing a Delegation Prompt

The receiving agent has none of this conversation and cannot ask you anything. A prompt that says "turn what we just did into a skill" is worthless to it.

Each prompt states, in the task's own terms:

- What the task is, in full. Where it came from a Linear issue, include the issue and its description rather than the title.
- What already happened that the agent needs to know, and where — repository, files, commits.
- What you have and have not already changed yourself, so it doesn't redo or undo work.
- That it should follow its own repository's conventions and review process rather than anything inferred from your prompt.

Pass the task through as the user gave it. Don't reinterpret it, improve it, or decide it needs less than it asks for.

## Rationalizations

| Thought                                         | Reality                                                                   |
| ----------------------------------------------- | ------------------------------------------------------------------------- |
| "It's a two-line change, delegating costs more" | The cost you're avoiding is the reason this session exists.               |
| "Edit is gone but I can still use Bash"         | The rule is no edits, not no `Edit`. Delegate it.                         |
| "I'll start the next stage, it looks done"      | You don't know it landed. The user says when.                             |
| "I'll tighten up the task before sending it"    | Send it as given. Rewriting it loses what the user actually asked.        |
| "I'll research the task before handing it off"  | Gather the handoff facts, then stop. Solving it is the other agent's job. |
