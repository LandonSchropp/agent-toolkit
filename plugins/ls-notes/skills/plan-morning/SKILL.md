---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day) and personal/work tasks for today's daily note.
---

# Plan Morning

Interactive walkthrough of the morning sections of today's daily note. Resolves any leftover tasks on recent daily notes, forwards the recent notes' forwardable tasks into today's note, captures Gratitude (3 items), Better Day (3 items), Personal tasks, then triggers `ls-slack:slack-tasks` to populate the Work subsection.

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

## Step 1: Resolve Incomplete Tasks From Recent Daily Notes

Find recent daily notes before today that still contain `- [ ]` items (filenames in `Daily Notes/YYYY-MM/` sort by `YYYY-MM-DD` prefix). On a Monday this is typically the prior Friday; after a longer gap it may span several days.

Walk through these daily notes oldest-first, **one day per message**. For each day:

- Open the message with the full weekday and date as an `##` header: `## Thursday, May 7 2026`.
- For each daily-note subsection that has `- [ ]` items, write the subsection name as an `###` header (e.g., `### Personal`, `### Work`).
- List the `- [ ]` items under each `###` header as a numbered list. **Numbering is continuous across all `###` subsections** for the day — do not restart at 1 in each subsection.
- Strip Obsidian wikilink syntax when presenting tasks: `[[Target|Display]]` → `Display`, `[[Target]]` → `Target`. Leave standard markdown links (`[text](url)`) intact.
- End the message with this single legend line: ``Legend: `x` complete, `>` forward, `<` schedule, `-` cancel, `d` delete, `/` partial.``

Marker semantics:

- `x`: Mark complete.
- `>`: Forwarded. The task should have been done that day but wasn't. The forward-tasks script will bring it into today's note as a fresh to-do and leave the `>` record on the prior note.
- `<`: Scheduled. Rolling task. The script will remove it from the prior note and bring it into today's note keeping its `<` marker, so it keeps rolling each day until completed.
- `-`: Cancel. Rewrites `- [ ]` to `- [-]`, keeping a record.
- `d`: Delete. Removes the task line entirely from the file.
- `/`: Partially completed. The script will bring it into today's note as a fresh to-do, leaving the `/` record on the prior note.

Wait for the user's response — they will give a marker per numbered item (e.g., `1. x, 2. >, 3. -`). Apply each choice by rewriting the marker in the source file. Then move on to the next day.

## Step 2: Forward Tasks

Run the forward-tasks script at `scripts/forward-tasks.rb`. It creates today's note from the template (if it doesn't yet exist) and pulls every `>`, `<`, and `/` from the recent prior notes into today's note under the matching subheader, removing scheduled tasks from their source.

If the script exits non-zero, it will list the prior notes that still contain unresolved `- [ ]` items. Walk back through each listed note as in Step 1 to help the user mark every remaining `[ ]`, then rerun the script. Repeat until the script exits 0.

## Step 3: Read Today's Daily Note

Run `obsidian daily:read` to load today's note content for the remaining steps.

## Step 4: Gratitude

If the Gratitude slots are empty, ask: "What are three things you're grateful for this morning?" Wait for the response, then write the three items in place of the empty `1. `, `2. `, `3. ` slots.

## Step 5: Better Day

If the Better Day slots are empty, ask: "What three things would make today great?" Wait, then write the three items into the empty slots.

## Step 6: Personal Tasks

Ask: "What personal tasks do you have today?" Append each item the user names as a `- [ ]` line under any existing Personal tasks. If they have nothing to add, leave the section as-is.

## Step 7: Work Tasks From Slack

**REQUIRED:** Invoke the `ls-slack:slack-tasks` skill to populate the Work subsection.

## Step 8: Additional Work Tasks

After `slack-tasks` finishes, ask: "Anything else you're planning to work on today outside of Slack?" Append each item the user names as a `- [ ]` line under the existing Work tasks. If they have nothing to add, leave the section as-is.

For each task the user adds, search Linear for matching issues in the user's teams (use `list_issues` with team and project filters). If a matching issue is found, link the task to that Linear issue URL directly (since this task has no Slack conversation). If multiple candidates exist, ask the user which one matches.

## Step 9: Daily Improvement Focus

If today's note contains a `- [ ] Daily improvement` task, ask: "What's your focus for daily improvement today?" Rewrite that task line as `- [ ] Daily improvement: <their answer>`. If the task is absent or already filled in, skip this step.

## Step 10: Standup

If the `oyster-team-ai:standup` skill is installed, invoke it. Before doing so, read the previous workday's note and note the completed (`[x]`) Work tasks — these inform yesterday's section. Today's Work tasks inform the today section.

## Step 10: Standup

If the `oyster-team-ai:standup` skill is installed, invoke it. Treat all tasks in today's Work section as today's todos.
