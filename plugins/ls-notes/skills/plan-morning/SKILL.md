---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day, Daily Affirmation) and personal/work tasks for today's daily note.
---

# Plan Morning

Walkthrough of the morning sections of today's daily note in at most four stops: resolve leftover tasks on recent daily notes, morning journaling, today's tasks, and standup. Each interactive stop gives the user a single file to edit rather than a chat Q&A, so the whole walkthrough needs only a few responses.

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

## Editing

Each interactive stop presents a single scratch file at `/tmp/plan-morning.md`:

1. Write the content to the scratch file.
2. **REQUIRED:** Invoke the `ls-interactivity:interactive-edit` skill to open it, passing a window name for the current step (e.g. "Today's Tasks"). Summarize for the user what to fill in.
3. When the window closes, read the scratch file and apply the responses per the current step.

## Task List Format

Use this format whenever presenting tasks for editing:

- Start the file with instructions and the legend:

  ```markdown
  Edit the markers in place, delete a line to remove that task entirely, and add
  new tasks as `- [ ]` lines.

  Legend: `x` complete, `>` forward, `<` schedule, `-` cancel, `/` partial.
  ```

- Give each subsection that has tasks a `###` header. Day headers are step-specific — include them only when the step calls for them.
- Copy task lines verbatim (keep wikilinks and current markers) so they round-trip cleanly.

Example:

```markdown
### Personal

- [ ] Update the README.md
- [<] Read Chapter 3 of The Pragmatic Programmer

### Work

- [/] Post a [status update](https://example.com) for my current project
```

Applying the saved file: copy each task's edited marker back to its source note, and remove tasks the user deleted from the file. Markers mean: `x` complete, `>` forward to today, `<` rolling task that moves forward daily until done, `-` cancelled, `/` started but unfinished (carries to today).

## Step 1: Resolve Tasks From Recent Daily Notes

Find recent daily notes before today that still contain `- [ ]` or `- [/]` items (filenames in `Daily Notes/YYYY-MM/` sort by `YYYY-MM-DD` prefix). On a Monday this is typically the prior Friday; after a longer gap it may span several days.

Build one scratch file containing every such day oldest-first in the **Task List Format**, with each day under a `## [Weekday, Month Day, Year]` header (e.g., `## Monday, January 1, 2026`). Open it in Neovim and wait, then apply the results to the source notes. The forward-tasks script in Step 2 handles `>`, `<`, and `/` automatically.

## Step 2: Forward Tasks

Run the forward-tasks script at `scripts/forward-tasks.rb`. It creates today's note from the template (if it doesn't yet exist) and pulls every `>`, `<`, and `/` from the recent prior notes into today's note under the matching subheader, removing scheduled tasks from their source.

If the script exits non-zero, it will list the prior notes that still contain unresolved `- [ ]` items. Present the listed notes in the editor again as in Step 1, then rerun the script. Repeat until the script exits 0.

## Step 3: Read Today's Daily Note

Run `obsidian daily:read` to load today's note content for the remaining steps.

## Step 4: Morning Journaling

Build one scratch file covering every journaling prompt that's still empty, open it in Neovim, and wait. Include only the sections that need answers:

- **Yesterday's Highlights:** Include only if a daily note exists for yesterday (the literal previous calendar day, not just the most recent note) and its Highlights of the Day section is empty.
- **Gratitude:** Include only if today's Gratitude slots are empty.
- **Better Day:** Include only if today's Better Day slots are empty.
- **Daily Affirmation:** Include only if today's Daily Affirmation section is empty.

Example with every section included:

```markdown
## Yesterday's Highlights

1.
2.
3.

## Gratitude

1.
2.
3.

## Better Day

1.
2.
3.

## Daily Affirmation
```

If nothing is empty, skip this step. After the save, write the highlights into yesterday's note as a numbered list and the remaining answers into today's matching sections.

## Step 5: Today's Tasks

Before building the scratch file, fetch the user's open non-draft pull requests from the `oysterhr` GitHub organization:

```bash
gh search prs --author=@me --owner=oysterhr --state=open --draft=false --json title,url,number,repository
```

For each PR, fetch its review and CI status:

```bash
gh pr view <url> --json reviewDecision,statusCheckRollup,reviewRequests,mergeable
```

Assign each PR a status emoji using this priority order:

- 💬: `reviewDecision` is `CHANGES_REQUESTED`
- ❌: Any entry in `statusCheckRollup` has `state` of `FAILURE` or `ERROR`
- 💔: `mergeable` is `CONFLICTING` (merge conflicts)
- ⏱️: `reviewRequests` is non-empty (one or more reviewers have been requested but haven't reviewed yet)
- ❓: Any other merge-blocking condition not already covered (e.g., branch protection rules unmet)
- ✅: All CI checks pass, PR is approved, and no pending review requests

Format each PR title:

1. Strip any conventional commit type prefix (e.g., `feat: `, `fix(scope): `)
2. Strip any Linear ticket ID (e.g., `[EX-123] `, `AI-456: `)
3. Title case the remaining text
4. Prepend the repository name followed by a colon

Build a scratch file with today's Personal and Work tasks in the **Task List Format** (no day header — just the `###` subsections), open it in Neovim, and wait. Add one line to the file's instructions: fill in the daily improvement focus by extending its line to `- [ ] Daily improvement: <focus>`. Include the fetched PRs as indented subtasks under `- [ ] Update/merge open pull requests`:

```markdown
- [ ] Update/merge open pull requests
  - [ ] [WIDGETS: Add Pagination to Widget List](https://github.com/example-org/widget-service/pull/42) 💬
  - [ ] [webapp: Fix Login Redirect on Expired Session](https://github.com/example-org/webapp/pull/1234) ❌
```

After the save, apply the changes to today's note. For each newly added Work task, search Linear for matching issues in the user's teams. If a match is found, link to the Linear issue URL. If multiple candidates exist, ask which one matches.

## Step 6: Standup

If the `oyster-team-ai:standup` skill is installed, read the previous workday's daily note and collect its completed (`[x]`) Work tasks — these become the basis for the standup's "yesterday" section. Ask: "Do you want to include yesterday in your standup?" If the user says no, pass that to the standup skill so it can skip the Yesterday section.

When invoking the standup skill, filter today's Work tasks down to primary focus areas only. Skip trivial tasks: PR reviews, sending messages, responding to threads, quick admin actions, or anything short-lived that doesn't represent meaningful progress to share with the team. Pass only the filtered list as today's todos.
