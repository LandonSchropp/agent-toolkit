---
name: orchestrate
description: Use when the orchestrator should work through the tasks in today's daily note.
disable-model-invocation: true
---

# Orchestrate

The daily note is the source of truth for what gets worked on today. This session hands its tasks out to other agents and keeps the note in step with the work.

Invoke the following skills:

- `ls-notes:daily-note`
- `ls-agent:dispatch`

Follow the `ls-agent:dispatch`'s instructions with the changes below.

## The Queue

Today's unchecked tasks are the queue. Skip `dispatch`'s parallelization step: the user picks the order, so propose tasks from the note and let them choose.

Leave out tasks no agent can do, such as errands. Those stay with the user. Your goal is to be _helpful_, not intrusive or annoying.

The queue grows as the user adds to the note. Alongside `dispatch`'s watcher, run `scripts/watch-daily-note.sh` with the `Monitor` tool, at its longest timeout, and re-arm it each time it expires. It prints a line for each unchecked task that appears in today's note, including the whole new note when the day rolls over. A task added in the last couple of minutes before it expired goes unreported, so after re-arming, read the note for unchecked tasks you haven't queued yet.

Propose each new task as it joins the queue. Ignore the tasks you added yourself, and any that already have a workspace or are queued, since editing a task reports it again.

## Pull Requests to Merge

When the user hands you pull requests to get merged, read [Pull Requests to Merge](references/pull-requests-to-merge.md).

## Keeping the Note Current

- **The user hands you work directly:** The queue lives in the note, so anything that isn't trivial goes in as a task before you queue it.
- **A task's workspace closes:** Check its task off, unless it's already checked.

## Rationalizations

| Thought                                  | Reality                                          |
| ---------------------------------------- | ------------------------------------------------ |
| "I'll parallelize the day's tasks first" | The user picks the order. Propose from the note. |
