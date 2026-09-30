---
name: plan-day
description: Use when the user says "plan my day" or "plan my morning", or wants to fill out morning journaling (Gratitude, Better Day, Daily Affirmation) and personal/work tasks for today's daily note.
---

# Plan Day

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

The planning happens in `plan-day`, a terminal app on the user's `PATH` that writes the results into the daily notes itself.

## Planning

**REQUIRED:** Invoke the `ls-interactivity:interactive-command` skill with `plan-day > /tmp/plan-day-<date>.md 2> /tmp/plan-day-<date>.log` as the command, where `<date>` is today's ISO date, and `plan-day` as the tab name. With its output redirected, `plan-day` draws on the terminal and prints only a summary to the file.

A non-zero exit means `plan-day` failed, and its error is in the log. When the tab closes, read the summary.

## Comments

Each comment is an instruction about its task. Carry out every one, editing the notes directly; ask the user only when a comment is ambiguous or needs a decision from them.

## More Tasks

Once every comment is carried out, ask the user whether there are any other tasks they'd like to add to today's daily note, and add them.

## Orchestration

Once the user has no more tasks to add, offer to hand today's tasks to the orchestrator. It is only an offer: send nothing until the user approves.

On approval, **REQUIRED:** use the `ls-agent:delegate` skill to send this task to the agent in the `orchestrator` workspace:

> The user just planned their day with another agent. Read today's daily note, then offer to coordinate and orchestrate its tasks. This is only an offer: ask the user which tasks to take on, and start nothing until they say so.

Keep `delegate`'s line naming where the prompt came from, but drop its "proceed on your best judgment" clause and its instruction to run `ls-agent:plan`; this task waits on the user.

If `herdr workspace list` has no workspace labeled `orchestrator`, open one instead of a new worktree, passing the prompt so it arrives once the agent starts: `herdr-project open --project orchestrate --name orchestrator --prompt '<prompt>'`.

Once the handoff is sent or declined, **REQUIRED:** use the `ls-agent:close-workspace` skill to close this workspace.
