---
name: engineering-assessment
description: Use when the user asks to write, draft or fill out an engineering assessment for a project.
---

# Engineering Assessment

The assessment is written with the user one section at a time, and the user reviews each section in Hunk before the next one is drafted. The research behind it, such as the PRD, code reading and Slack threads, should already be in the conversation. If it isn't, gather it before drafting.

## Setting Up

1. **REQUIRED:** Invoke the `ls-notes:note` skill, and follow its conventions for the new note.
2. Copy `~/Notes/Areas/Oyster/Engineering Assessment Template.md` to a new note named `<Project Name> Engineering Assessment.md`. Ask the user which folder it belongs in if the conversation doesn't make it clear.
3. Copy the new note into the session's scratchpad directory before the first edit. This copy is the baseline the review compares against.

## Drafting Each Section

Work through the template's sections in order. For each one:

1. Replace the section's italic prompt and placeholders, such as empty bullets and the risk table's example cells, with drafted content that answers it.
2. Open the review. **REQUIRED:** Invoke the `ls-interactivity:interactive-review` skill in `diff <baseline> <note>` mode, with `--name engineering-assessment` so every run reloads the same tab.
3. Revise from the user's comments and rerun the same command to reload the review. Keep going until the user approves the section or says to move on.
4. Re-read the note, since the user may have edited it during the review. Copy it over the baseline, so the next review shows only the next section.

Close the review tab after the last section is approved.

## Content Rules

- **Only decided things:** Write in only the decisions the user has actually made. Something that was suggested or discussed but not decided goes in Unknowns or Alternatives, or stays out.
- **Impact and Dependencies:** List teams, never systems or platforms, ordered from most affected to least. Find each team's name in a source rather than guessing it. `package.yml` owners and `CODEOWNERS` in the affected code are good places to check. Put cross-cutting notes that aren't about a team, such as an affected migration, in a paragraph below the list.

## Rationalizations

| Thought                                         | Reality                                                                   |
| ----------------------------------------------- | ------------------------------------------------------------------------- |
| "I'll draft every section, then review once"    | One section per review. The user's feedback on one shapes the next.       |
| "The suggestion was reasonable, so include it"  | Only decisions the user made go in. Suggestions aren't decisions.         |
| "The team name is obvious from the code's area" | Find it in a source, such as `CODEOWNERS`. Guessed names are often wrong. |
| "Nobody edited the note during review"          | Re-read it before refreshing the baseline. The user may have edited it.   |
