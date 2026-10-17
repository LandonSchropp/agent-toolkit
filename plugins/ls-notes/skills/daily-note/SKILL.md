---
name: daily-note
description: Use when the user mentions a daily note, asks to add a task to today's daily todos, or reads or writes any file under ~/Notes/Daily Notes/. Covers location, section structure, and what each section is used for.
---

# Daily Note

**REQUIRED:** Invoke the `ls-notes:note` skill first. Vault structure, conventions, icons, templates, and obsidian CLI guidance there all apply to daily notes.

## Location

`Daily Notes/YYYY/YYYY-MM/YYYY-MM-DD - Daily Note.md` (e.g., `Daily Notes/2026/2026-05/2026-05-09 - Daily Note.md`).

With the `obsidian` CLI, read or append to today's note with `obsidian daily:read`, `obsidian daily:append`, and `obsidian daily:prepend` — these resolve today's date automatically.

## Ensure Today's Note Exists

When this skill is invoked with the `obsidian` CLI available, run `obsidian daily:read`. It returns today's note content and creates the file from the daily-note template as a side effect if it does not already exist. Idempotent — running it twice does not produce a duplicate.

Skip this step only if the user is asking about a past or future daily note rather than today's.

**Precondition:** Obsidian must be running. CLI commands dispatch to the running app via IPC; with no app open, they hang. Check via `pgrep -fl 'Obsidian.app/Contents/MacOS/Obsidian'` and ask the user to launch Obsidian if needed.

Without the CLI, build the path from today's date in the user's time zone (Pacific), not the server's, and read the note there. If the note doesn't exist, create it from `Templates/Periodic/Daily Note.md`. Its Templater code doesn't run outside the app, so resolve it by hand as the `ls-notes:note` skill's template guidance describes, and never leave raw `<% %>` code in the note.

## Task Item Formatting

When adding or reviewing tasks in the daily note, follow these link conventions:

- **Inline links:** Embed links directly in the item text by linking the relevant noun or phrase. Never use a standalone `([link](url))` tag — the link should flow naturally with the sentence. For example: `- [ ] Update my [Providing Context doc](https://...) based on the comments` not `- [ ] Update my Providing Context doc ([link](https://...)) based on comments`.
- **Slack threads:** If a task has an associated Slack thread, append `([thread](url))` at the end of the item. For example: `- [ ] Draft the vibe code policy ([thread](https://example.slack.com/archives/...))`.

If you notice existing items that don't follow these conventions, proactively suggest corrections.

## Sections

The daily note is filled in from `Templates/Periodic/Daily Note.md`. Each note has the following top-level sections, in order:

- **Tasks:** Checklist of things to do today, broken into:
  - **Personal:** Personal tasks for the day.
  - **Work** (weekdays only)**:** Work tasks for the day.
  - **Chores** (Sundays only)**:** Recurring weekly chores.
  - **Quarterly** (first Sunday of the quarter)**:** Recurring quarterly chores.
- **Habits:** Daily habit tracking, broken into Steps, Calories, Sleep Log and Identity Vote. Filling these in belongs to the `ls-health` skills, not this one.
- **Morning:** Morning journaling, broken into:
  - **Gratitude:** Three things the user is grateful for.
  - **Better Day:** Three things that would make today great.
  - **Daily Affirmation:** A short, encouraging affirmation for the day, written as prose.
- **Evening:** Evening reflection, broken into:
  - **Highlights of the Day:** Notable moments from the day.
- **Journal:** Free-form journal prose for the day.
- **Thoughts:** Stray observations and ideas captured during the day.
