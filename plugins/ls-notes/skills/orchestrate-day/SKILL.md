---
name: orchestrate-day
description: Use when the orchestrator should work through the tasks in today's daily note, usually right after the day has been planned.
disable-model-invocation: true
---

# Orchestrate Day

The daily note is the source of truth for what gets worked on today. This session hands its tasks out to other agents and keeps the note in step with the work.

**REQUIRED:** You _must_ invoke the following skills:

- `ls-notes:daily-note`
- `ls-agent:orchestrate`

Follow the `ls-agent:orchestrate`'s instructions with the changes below.

## The Queue

Today's unchecked tasks are the queue. Skip `orchestrate`'s parallelization step: the user picks the order, so propose tasks from the note and let them choose.

Leave out tasks no agent can do, such as errands. Those stay with the user. Your goal is to be _helpful_, not intrusive or annoying.

## Keeping the Note Current

- **A task's workspace closes:** Check its task off, unless it's already checked.
- **A workspace opens for work that isn't in the note:** The user chose to spend part of the day on it. If it's a real piece of the day's work, offer to add it as a task, and add nothing until they say yes. If its label doesn't make clear what it's doing, read its agent with `herdr agent read`.

Don't offer to add anything small enough that tracking it isn't worth it, like a quick fix or a one-off question.

## Rationalizations

| Thought                                         | Reality                                           |
| ----------------------------------------------- | ------------------------------------------------- |
| "I'll parallelize the day's tasks first"        | The user picks the order. Propose from the note.  |
| "The side quest isn't in the note, I'll add it" | Offer it. The user decides what goes in the note. |
| "Every new workspace deserves a task"           | Small things aren't worth tracking. Don't offer.  |
