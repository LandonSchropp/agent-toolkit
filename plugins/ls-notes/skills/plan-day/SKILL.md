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

**Never edit a daily note while the `plan-day` tab is open.** `plan-day` refuses to write any note that changed after it read it, so an edit made mid-session throws away everything the user planned in that note. This covers every daily note, not just today's, and every edit, even a one-character typo fix the user asked for. Tell the user each edit is queued, hold it until the tab closes, then apply it along with the comments.

The one exception is a session the user hasn't started. `plan-day` saves a draft to `${XDG_STATE_HOME:-$HOME/.local/state}/plan-day/draft.json` the first time the user turns a page or clicks a tab. While that file doesn't exist, close the tab (**REQUIRED:** follow the `ls-interactivity:interactive-command` skill's rules for closing a tab), do what the user asked, then open `plan-day` again as above. Once the draft exists, queue the edit, even if the user has gone back to the first page: a reopened session resumes from the draft and still skips the edited note.

## Comments

Each comment is an instruction about its task. Carry out every one, editing the notes directly; ask the user only when a comment is ambiguous or needs a decision from them.

## More Tasks

Once every comment is carried out, ask the user whether there are any other tasks they'd like to add to today's daily note, and add them.

Once the user has no more tasks to add, **REQUIRED:** use the `ls-agent:close-workspace` skill to close this workspace.
