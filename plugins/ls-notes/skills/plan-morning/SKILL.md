---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day) and personal/work tasks for today's daily note.
---

# Plan Morning

Interactive walkthrough of the morning sections of today's daily note. Captures Gratitude (3 items), Better Day (3 items), Personal tasks, then triggers `ls-slack:slack-tasks` to populate the Work subsection.

**REQUIRED:** Invoke the `ls-notes:daily-note` skill first. It ensures today's note exists and documents the section structure.

## Step 1: Gratitude

If the Gratitude slots are empty, ask: "What are three things you're grateful for this morning?" Wait for the response, then write the three items in place of the empty `1. `, `2. `, `3. ` slots.

## Step 2: Better Day

If the Better Day slots are empty, ask: "What three things would make today great?" Wait, then write the three items into the empty slots.

## Step 3: Personal Tasks

Ask: "What personal tasks do you have today?" Append each item the user names as a `- [ ]` line under any existing Personal tasks. If they have nothing to add, leave the section as-is.

## Step 4: Work Tasks

**REQUIRED:** Invoke the `ls-slack:slack-tasks` skill to populate the Work subsection.

## Step 5: Wrap Up

End with a one-sentence summary: which sections were filled and how many work tasks `slack-tasks` added.
