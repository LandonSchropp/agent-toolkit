---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day) and personal/work tasks for today's daily note.
---

# Plan Morning

Interactive walkthrough of the morning sections of today's daily note. Resolves any leftover tasks from the previous daily note, creates today's note (triggering task-forwarder), captures Gratitude (3 items), Better Day (3 items), Personal tasks, then triggers `ls-slack:slack-tasks` to populate the Work subsection.

**REQUIRED:** Invoke the `ls-notes:note` skill first for vault context.

## Step 1: Resolve Incomplete Tasks From Recent Daily Notes

Find recent daily notes before today that still contain `- [ ]` items (filenames in `Daily Notes/YYYY-MM/` sort by `YYYY-MM-DD` prefix). On a Monday this is typically the prior Friday; after a longer gap it may span several days.

Walk through these daily notes oldest-first, **one day per message**. For each day:

- Open the message with the full weekday and date as an `##` header: `## Thursday, May 7 2026`.
- For each daily-note subsection that has `- [ ]` items, write the subsection name as an `###` header (e.g., `### Personal`, `### Work`).
- List the `- [ ]` items under each `###` header as a numbered list. **Numbering is continuous across all `###` subsections** for the day — do not restart at 1 in each subsection.
- Strip Obsidian wikilink syntax when presenting tasks: `[[Target|Display]]` → `Display`, `[[Target]]` → `Target`. Leave standard markdown links (`[text](url)`) intact.
- End the message with this single legend line: ``Legend: `x` complete, `>` forward, `<` schedule, `-` cancel, `/` in-progress.``

Marker semantics:

- `x`: Mark complete.
- `>`: Forwarded. The task should have been done that day but wasn't. Task-forwarder will bring it into today's note and leave it on the prior note as a historical record.
- `<`: Scheduled. Rolling task. Task-forwarder will remove it from the prior note and bring it into today's note. Continues to roll forward each day until completed.
- `-`: Cancel.
- `/`: In progress. Stays on the prior note; does not block task-forwarder.

Wait for the user's response — they will give a marker per numbered item (e.g., `1. x, 2. >, 3. -`). Apply each choice by rewriting the marker in the source file. Then move on to the next day.

**All `- [ ]` items must be resolved before Step 2**, otherwise task-forwarder produces a cleanup warning instead of forwarding.

## Step 2: Create Today's Note

**REQUIRED:** Invoke the `ls-notes:daily-note` skill. It creates today's note from the template; task-forwarder then automatically forwards any `[>]` items from the previous note.

## Step 3: Gratitude

If the Gratitude slots are empty, ask: "What are three things you're grateful for this morning?" Wait for the response, then write the three items in place of the empty `1. `, `2. `, `3. ` slots.

## Step 4: Better Day

If the Better Day slots are empty, ask: "What three things would make today great?" Wait, then write the three items into the empty slots.

## Step 5: Personal Tasks

Ask: "What personal tasks do you have today?" Append each item the user names as a `- [ ]` line under any existing Personal tasks. If they have nothing to add, leave the section as-is.

## Step 6: Work Tasks From Slack

**REQUIRED:** Invoke the `ls-slack:slack-tasks` skill to populate the Work subsection.

## Step 7: Additional Work Tasks

After `slack-tasks` finishes, ask: "Anything else you're planning to work on today outside of Slack?" Append each item the user names as a `- [ ]` line under the existing Work tasks. If they have nothing to add, leave the section as-is.

For each task the user adds, search Linear for matching issues in the user's teams (use `list_issues` with team and project filters). If a matching issue is found, link the task to that Linear issue URL directly (since this task has no Slack conversation). If multiple candidates exist, ask the user which one matches.
