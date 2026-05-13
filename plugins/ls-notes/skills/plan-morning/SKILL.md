---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day) and personal/work tasks for today's daily note.
---

# Plan Morning

Interactive walkthrough of the morning sections of today's daily note. Resolves any leftover tasks from the previous daily note, creates today's note (triggering task-forwarder), captures Gratitude (3 items), Better Day (3 items), Personal tasks, then triggers `ls-slack:slack-tasks` to populate the Work subsection.

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions. **YOU MUST skip the "Ensure Today's Note Exists" step — do NOT run `obsidian daily:read` or open today's note in any way.** Creating today's note triggers task-forwarder. If you create it before Step 1 is complete, every task the user marks `>` or `<` is silently lost — task-forwarder already ran and will not run again.

## Rationalizations

| Thought                                                   | Reality                                                                                                             |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| "I'll read today's note to see what's in it"              | Reading via `obsidian daily:read` creates the note as a side effect. task-forwarder runs. Forwarded tasks are lost. |
| "The daily-note skill says to ensure today's note exists" | That step is explicitly skipped here. The order is non-negotiable.                                                  |
| "I'll just check if today's note already exists"          | Doesn't matter. Do not create it until Step 2.                                                                      |
| "task-forwarder already ran from a previous session"      | Still do not create the note early. Follow the steps in order.                                                      |

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
- `>`: Forwarded. The task should have been done that day but wasn't. Task-forwarder will bring it into today's note and leave it on the prior note as a historical record.
- `<`: Scheduled. Rolling task. Task-forwarder will remove it from the prior note and bring it into today's note. Continues to roll forward each day until completed.
- `-`: Cancel. Rewrites `- [ ]` to `- [-]`, keeping a record.
- `d`: Delete. Removes the task line entirely from the file.
- `/`: Partially completed. Stays on the prior note; does not block task-forwarder.

Wait for the user's response — they will give a marker per numbered item (e.g., `1. x, 2. >, 3. -`). Apply each choice by rewriting the marker in the source file. Then move on to the next day.

## Step 2: Create Today's Note

**All prior tasks must be resolved before this step.** Run `obsidian daily:read`. This creates today's note from the template, triggering task-forwarder to pick up every `>` and `<` marker applied in Step 1.

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

## Step 8: Daily Improvement Focus

If today's note contains a `- [ ] Daily improvement` task, ask: "What's your focus for daily improvement today?" Rewrite that task line as `- [ ] Daily improvement: <their answer>`. If the task is absent or already filled in, skip this step.
