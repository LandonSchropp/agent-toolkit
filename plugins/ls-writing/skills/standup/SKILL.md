---
name: standup
description: Use when the user wants to write their standup update.
---

# Standup

Draft the user's reply to their team's standup thread from their daily notes.

1. **REQUIRED:** Invoke the `ls-notes:daily-note` skill. Read today's note and the previous weekday's note. On a Monday, the previous weekday is Friday.
2. Build Yesterday from the previous weekday's Work tasks marked `[x]` or `[/]`, and Today from today's Work tasks. Today's note may not have its carried-forward tasks yet, so also include the previous weekday's Work tasks marked `[>]`, `[/]` or `[<]` that today's note doesn't list. Personal tasks never go in the standup.
3. Rewrite each task as a short phrase, in the past tense under Yesterday and the "-ing" form under Today. Summarize a task's subtasks into its one line.
4. When a task has a Linear issue, end its line with the issue ID in parentheses, linked to the issue, as in `([ABC-123](https://linear.app/...))`.
5. Ask the user for the blockers and live-time items, since the daily notes don't record them.
6. **REQUIRED:** Invoke the `ls-writing:slack-message` skill to show the draft and copy it.

The reply answers the thread's three questions:

```markdown
1. WYD
   1. Yesterday
      1. Removed the checkout feature flag ([ABC-123](https://linear.app/...))
   2. Today
      1. Prepping the [<Project Name>](https://...) kickoff
2. <Blockers>
3. <Live-time requests>
```

## Rationalizations

| Thought                                   | Reality                                                         |
| ----------------------------------------- | --------------------------------------------------------------- |
| "Yesterday means the day before today"    | It means the previous weekday. On a Monday, read Friday's note. |
| "A personal task shows what I got done"   | The standup is for work. Leave personal tasks out.              |
| "I can guess the blockers from the notes" | The notes don't record them. Ask the user.                      |
