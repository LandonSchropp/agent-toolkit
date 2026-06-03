---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day) and personal/work tasks for today's daily note.
---

# Plan Morning

Interactive walkthrough of the morning sections of today's daily note. Resolves any leftover tasks on recent daily notes, forwards the recent notes' forwardable tasks into today's note, captures Gratitude (3 items), Better Day (3 items), Personal tasks, then triggers `ls-slack:slack-tasks` to populate the Work subsection.

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

## Task Review Format

Use this format whenever presenting tasks for user review:

- Number each task sequentially in a flat numbered list, showing its current status marker inline: `1. [<] Task description`
- Strip wikilinks: `[[Target|Display]]` → `Display`, `[[Target]]` → `Target`. Leave standard markdown links intact.
- End with this legend line: ``Legend: `x` complete, `i`/`t` incomplete, `>` forward, `<` schedule, `-` cancel, `/` partial, `d` delete``

Markers:

- `x` (Complete): A task that was completed.
- `i`/`t` (Incomplete): A task that should be reset to unchecked.
- `>` (Forward): A task that was intended to be completed but was not. It should carry over to the next day.
- `<` (Schedule): A rolling task that keeps moving forward each day until it's completed.
- `-` (Cancel): A task that was cancelled and will not be completed.
- `/` (Partial): A task that was started but not finished. It should be carried to the next day.
- `d` (Delete): A task that should be completely removed.

**CRITICAL — `i`/`t` and `d` are structural operations, not marker characters.** Do NOT write `- [d]`, `- [i]`, or `- [t]` in the file. Instead:

- `i` or `t`: Replace the entire marker with `- [ ]` (resets the task to unchecked).
- `d`: Remove the line entirely from the file.

Example:

```
1. [ ] Update the README.md
2. [<] Read Chapter 3 of The Pragmatic Programmer
3. [ ] Post a [status update](https://example.com) for my current project

Legend: `x` complete, `>` forward, `<` schedule, `-` cancel, `d` delete, `/` partial.
```

Wait for the user's response (e.g., `1. x, 3. -`), then apply markers per the instructions in the current step.

## Step 1: Resolve Incomplete Tasks From Recent Daily Notes

Find recent daily notes before today that still contain `- [ ]` or `- [/]` items (filenames in `Daily Notes/YYYY-MM/` sort by `YYYY-MM-DD` prefix). On a Monday this is typically the prior Friday; after a longer gap it may span several days.

Walk through these daily notes oldest-first, **one day per message**. For each day:

- Open with `## [Weekday, Day Month Year]` as the header (e.g., `## Thursday, May 7 2026`).
- Write each subsection that has `- [ ]` or `- [/]` items as a `###` header (e.g., `### Personal`, `### Work`). Numbering is continuous across subsections — do not restart at 1.
- Present items using the **Task Review Format** above. Include `[/]` (in-progress) tasks — the user may have finished them and should mark them `x` before the forwarder runs.

Just set the marker in the file. The forward-tasks script in Step 2 handles `>`, `<`, and `/` automatically.

Then move on to the next day.

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

Present all Personal tasks from today's note using the **Task Review Format**, and ask if there's anything else to add in the same message. Apply any marker changes and append new items as `- [ ]` lines.

## Step 7: Forwarded Work Tasks

Present all Work tasks currently in today's note using the **Task Review Format**.

## Step 8: Work Tasks From Slack

**REQUIRED:** Read [Slack Tasks](references/slack-tasks.md) and follow its steps to fetch candidates. Then present them using the **Task Review Format**, adding `n` as an option to skip a task entirely. If any candidates were flagged with a potential Linear issue link, include those as yes/no questions after the numbered list. Write approved tasks to the Work subsection.

## Step 9: Additional Work Tasks

Ask: "Anything else to add?" Append new items as `- [ ]` lines.

For each new task added, search Linear for matching issues in the user's teams. If a match is found, link to the Linear issue URL. If multiple candidates exist, ask which one matches.

## Step 10: Daily Improvement Focus

If today's note contains a `- [ ] Daily improvement` task, ask: "What's your focus for daily improvement today?" Rewrite that task line as `- [ ] Daily improvement: <their answer>`. If the task is absent or already filled in, skip this step.

## Step 11: Standup

If the `oyster-team-ai:standup` skill is installed, read the previous workday's daily note and collect its completed (`[x]`) Work tasks — these become the basis for the standup's "yesterday" section. Ask: "Do you want to include yesterday in your standup?" If the user says no, pass that to the standup skill so it can skip the Yesterday section.

When invoking the standup skill, filter today's Work tasks down to primary focus areas only. Skip trivial tasks: PR reviews, sending messages, responding to threads, quick admin actions, or anything short-lived that doesn't represent meaningful progress to share with the team. Pass only the filtered list as today's todos.
