---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day, Daily Affirmation) and personal/work tasks for today's daily note.
---

# Plan Morning

Walkthrough of the morning sections of today's daily note in at most three stops: Yesterday, Today, and Standup. Each interactive stop gives the user a single file to edit rather than a chat Q&A, so the whole walkthrough needs only a few responses.

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

## Editing

Each interactive stop presents a single scratch file at `/tmp/plan-morning.md`:

1. Write the content to the scratch file.
2. **REQUIRED:** Invoke the `ls-interactivity:interactive-edit` skill to open it, passing a lower-kebab-case window name for the current step (e.g. "yesterday" or "today"). Summarize for the user what to fill in.
3. When the window closes, read the scratch file and apply the responses per the current step.

## Task List Format

Use this format whenever presenting tasks for editing, as one section nested within a stop's scratch file:

- Give the task block a `##` header — either `## Tasks` or a day header (e.g., `## Monday, January 1, 2026`) when the step calls for one.
- Give each subsection that has tasks a `###` header.
- Copy task lines verbatim (keep wikilinks and current markers) so they round-trip cleanly.

Example:

```markdown
## Tasks

### Personal

- [ ] Update the README.md
- [<] Read Chapter 3 of The Pragmatic Programmer

### Work

- [/] Post a [status update](https://example.com) for my current project
```

Applying the saved file: copy each task's edited marker back to its source note, and remove tasks the user deleted from the file. Markers mean: `x` complete, `>` forward to today, `<` rolling task that moves forward daily until done, `-` cancelled, `/` started but unfinished (carries to today).

## Step 1: Yesterday

Combine yesterday's unresolved tasks with its journaling prompts into a single scratch file.

**Unresolved tasks:** Run the resolve-tasks script at `scripts/resolve-tasks.rb`. It writes every recent prior note's unresolved (`- [ ]`) tasks to the scratch file, oldest-first in the **Task List Format**, each day under a `## [Weekday, Month Day, Year]` header (e.g., `## Monday, January 1, 2026`). Forwardable markers (`>`, `<`, `/`) carry forward automatically in Step 2, so the script leaves them out.

**Highlights and Identity Vote:** Include each section only if a daily note exists for yesterday (the literal previous calendar day, not just the most recent note) and its matching section (Highlights of the Day, Identity Vote) is empty.

If the resolve-tasks script wrote unresolved tasks, retitle its `# Resolve Tasks` header to `# Yesterday` and append whichever journaling sections apply below it. If the script found nothing to resolve, start the file fresh with a `# Yesterday` header and just the journaling sections. If no unresolved tasks exist and both journaling sections are already filled, skip this stop entirely.

Example with every section included:

```markdown
# Yesterday

## Monday, January 1, 2026

### Personal

- [ ] Update the README.md

## Highlights

_What were the notable moments from [yesterday's weekday and date]?_

1.
2.
3.

## Identity Vote

_Every action is a vote for the person you're becoming. Yesterday, did you move toward that person?_

- [ ] 🔴 Voted against
- [ ] 🟠 Slipped
- [ ] 🟡 Broke even
- [ ] 🟢 Made progress
- [ ] 🔵 Nailed it

**Evidence:**
```

Open the scratch file for editing per the **Editing** steps with window name "yesterday". After the window closes:

- Apply the saved task markers to the source notes per the **Task List Format**.
- Write the highlights into yesterday's note as a numbered list.
- For the Identity Vote, read the single checked option and fill in the empty `### :LiVote: Identity Vote` section of yesterday's note: write a `**Vote:**` line with the checked emoji mapped to its signed score, and an `**Evidence:**` line with the evidence text.

  | Checked          | Vote line               |
  | ---------------- | ----------------------- |
  | 🔴 Voted against | `🔴 Voted against (-2)` |
  | 🟠 Slipped       | `🟠 Slipped (-1)`       |
  | 🟡 Broke even    | `🟡 Broke even (0)`     |
  | 🟢 Made progress | `🟢 Made progress (+1)` |
  | 🔵 Nailed it     | `🔵 Nailed it (+2)`     |

  If no box is checked, leave yesterday's Identity Vote section empty. If more than one is checked, ask the user which they meant before writing.

## Step 2: Forward Tasks

Run the forward-tasks script at `scripts/forward-tasks.rb`. It creates today's note from the template (if it doesn't yet exist) and pulls every `>`, `<`, and `/` from the recent prior notes into today's note under the matching subheader, removing scheduled tasks from their source.

If the script exits non-zero, it will list the prior notes that still contain unresolved `- [ ]` items. Present the listed notes in the editor again as in Step 1, then rerun the script. Repeat until the script exits 0.

## Step 3: Read Today's Daily Note

Run `obsidian daily:read` to load today's note content for the remaining steps.

## Step 4: Today

Combine today's tasks with its journaling prompts into a single scratch file.

**Gratitude, Better Day, and Daily Affirmation:** Include each section only if its slot(s) in today's note are still empty. If the user asks for help writing the Daily Affirmation, see [Daily Affirmation](references/daily-affirmation.md).

**Today's Tasks:** Before building the scratch file, fetch the user's open non-draft pull requests from the `oysterhr` GitHub organization:

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

**Resolve auto-titled links:** Obsidian automatically converts pasted URLs into markdown links, but its title-fetch often lacks permissions, leaving a generic site name as the label (`Slack`, `GitHub`, `Linear`, `Notion`, etc.). Before building the scratch file, scan for tasks with these placeholder labels and handle each based on context:

- **Link-only task:** The task has no description beyond the link. Fetch the resource and derive a full, actionable task title following the daily-note formatting conventions. For Slack links, read the thread carefully — the body often references another resource that is the actual focus of the task, and the title should reflect that.
- **Link within a task:** The task has descriptive text but one of its links has a generic label. Use the appropriate MCP server to look up the resource and replace only the link label with its real title.

Build a scratch file with today's Personal and Work tasks in the **Task List Format** under a `## Tasks` header, followed by whichever journaling sections apply. Add one line to the file's instructions: fill in the daily improvement focus by extending its line to `- [ ] Daily improvement: <focus>`. Include the fetched PRs as indented subtasks under `- [ ] Update/merge open pull requests`:

```markdown
# Today

## Tasks

### Personal

- [ ] Update the README.md
- [ ] Daily improvement: <focus>

### Work

- [ ] Update/merge open pull requests
  - [ ] [WIDGETS: Add Pagination to Widget List](https://github.com/example-org/widget-service/pull/42) 💬
  - [ ] [webapp: Fix Login Redirect on Expired Session](https://github.com/example-org/webapp/pull/1234) ❌

## Gratitude

_I am grateful for…_

1.
2.
3.

## Better Day

_What would make today great?_

1.
2.
3.

## Daily Affirmation

_Who do you want to be?_

I am…
```

Open the scratch file for editing per the **Editing** steps with window name "today". After the window closes:

- Apply the task changes to today's note per the **Task List Format**. For each newly added Work task, search Linear for matching issues in the user's teams. If a match is found, link to the Linear issue URL. If multiple candidates exist, ask which one matches.
- Apply the Gratitude, Better Day, and Daily Affirmation answers to their matching sections in today's note.

## Step 5: Standup

If the `oyster-team-ai:standup` skill is installed, build and open a pre-filled scratch file rather than asking standup questions in chat.

1. **Fetch yesterday:** Search `#team-ai-standups` with `slack_search_public_and_private` (query: `from:@<user> in:#team-ai-standups`) to find the user's most recent post. Extract its **Today** section bullets — these pre-fill Yesterday.

2. **Build scratch file:** Write `/tmp/plan-morning.md` using this template. Fill in the Yesterday bullets from the previous standup and the Work tasks comment from today's daily note. Include all Work tasks in the comment — the user will decide what to carry into Today.

   ```markdown
   # Daily Standup

   ## Yesterday

   • Previous standup Today item 1
   • Previous standup Today item 2

   ## Today

   <!-- Work tasks from today's daily note (reference only — not included in standup):
   - [ ] Task A
   - [ ] Task B
   -->

   ## Blockers

   ## Feeling
   ```

3. **Open for editing:** **REQUIRED:** Invoke the `ls-interactivity:interactive-edit` skill with window name "standup".

4. **Hand off:** After the window closes, read the file and parse each section. Invoke `oyster-team-ai:standup` and tell it: "The user has already filled in their standup answers via an interactive editor — skip all context-gathering and question steps, compose the message, and post it directly without asking for confirmation. Yesterday: [bullets from file], Today: [bullets from file], Blockers: [content or none], Feeling: [content or none]."
