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

Once the user has no more tasks to add, **REQUIRED:** use the `ls-agent:close-workspace` skill to close this workspace.
