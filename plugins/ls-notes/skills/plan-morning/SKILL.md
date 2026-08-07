---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day, Daily Affirmation) and personal/work tasks for today's daily note.
---

# Plan Morning

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

This skill is split into 3 phases: pre-process the scratch files, run one editing pass through up to three windows (Yesterday, Today, Standup), then post-process the results.

Before doing anything else, read yesterday's and today's daily note files. (Today's note already having content is expected, not ambiguous.)

## Structure

### Scratch File Paths

Each window's content lives at `/tmp/plan-morning-<step>-<date>.md`, where `<step>` is `yesterday`, `today`, or `standup` and `<date>` is today's ISO date (e.g. `/tmp/plan-morning-yesterday-2026-08-06.md`). If a step's file already exists, don't rebuild its content — leave it as-is.

### Task List Format

Use this format whenever presenting tasks for editing, as one section nested within a window's scratch file:

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

Markers mean: `x` complete, `>` forward to today, `<` rolling task that moves forward daily until done, `-` cancelled, `/` started but unfinished (carries to today).

## Phase 1: Pre-Processing

Build each scratch file per **Scratch File Paths**, before opening any window.

Complete all of Phase 1 without stopping or asking the user for input.

### Yesterday's Content

Run `scripts/resolve-tasks.rb`. It writes every recent prior note's unresolved (`- [ ]`) tasks to its output path, oldest-first in the **Task List Format**, each day under a `## [Weekday, Month Day, Year]` header. Forwardable markers (`>`, `<`, `/`) carry forward automatically in Phase 3, so the script leaves them out. Move its output to the dated Yesterday path.

Check whether a daily note exists for yesterday (the literal previous calendar day) and whether its Highlights of the Day and Identity Vote sections are empty. If either is empty, append the relevant prompt(s) to the Yesterday scratch file below the resolved tasks, under a `# Yesterday` header:

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

Skip this window entirely if there are no unresolved tasks and both journaling sections are already filled.

### Today's Content

Fetch the user's open non-draft pull requests from the `oysterhr` GitHub organization:

```bash
gh search prs --author=@me --owner=oysterhr --state=open --draft=false --json title,url,number,repository
```

For each PR, fetch its review and CI status:

```bash
gh pr view <url> --json reviewDecision,statusCheckRollup,reviewRequests,mergeable
```

Assign each PR a status emoji using this priority order:

- 💬: `reviewDecision` is `CHANGES_REQUESTED`
- ❌: Any entry in `statusCheckRollup` has `state` (or `conclusion`) of `FAILURE` or `ERROR`
- 💔: `mergeable` is `CONFLICTING` (merge conflicts)
- ⏱️: `reviewRequests` is non-empty (one or more reviewers have been requested but haven't reviewed yet)
- ❓: Any other merge-blocking condition, including `mergeable` being unresolved (`UNKNOWN`)
- ✅: All CI checks pass, PR is approved, and no pending review requests

Format each PR title:

1. Strip any conventional commit type prefix (e.g., `feat: `, `fix(scope): `)
2. Strip any Linear ticket ID (e.g., `[EX-123] `, `AI-456: `)
3. Title case the remaining text
4. Prepend the repository name followed by a colon — check `CLAUDE.local.md` for a repository abbreviation before falling back to the full name

Merge each PR into today's note as an indented subtask under `- [ ] Update/merge open pull requests` in the Work subheader:

```markdown
- [ ] Update/merge open pull requests
  - [ ] [WIDGETS: Add Pagination to Widget List](https://github.com/example-org/widget-service/pull/42) 💬
  - [ ] [webapp: Fix Login Redirect on Expired Session](https://github.com/example-org/webapp/pull/1234) ❌
```

**Resolve auto-titled links:** Obsidian automatically converts pasted URLs into markdown links, but its title-fetch often lacks permissions, leaving a generic site name as the label (`Slack`, `GitHub`, `Linear`, `Notion`, etc.). Scan today's note and the recent prior notes for tasks with these placeholder labels and fix each one in place:

- **Link-only task:** The task has no description beyond the link. Fetch the resource and derive a full, actionable task title following the daily-note formatting conventions. For Slack links, read the thread carefully — the body often references another resource that is the actual focus of the task, and the title should reflect that.
- **Link within a task:** The task has descriptive text but one of its links has a generic label. Use the appropriate MCP server to look up the resource and replace only the link label with its real title.

Build the Today scratch file from today's note's current Tasks section plus the journaling prompts. Include the Gratitude, Better Day, and Daily Affirmation prompts only for slots that are still empty in today's note. If the user asks for help writing the Daily Affirmation, see [Daily Affirmation](references/daily-affirmation.md). Add one line to the file's instructions: fill in the daily improvement focus by extending its line to `- [ ] Daily improvement: <focus>`.

```markdown
# Today

## Tasks

### Personal

- [ ] Update the README.md
- [ ] Daily improvement: <focus>

### Work

- [ ] Update/merge open pull requests
  - [ ] [WIDGETS: Add Pagination to Widget List](https://github.com/example-org/widget-service/pull/42) 💬

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

### Standup's Content

Skip this window if the `oyster-team-ai:standup` skill isn't installed.

Search `#team-ai-standups` with `slack_search_public_and_private` (query: `from:@<user> in:#team-ai-standups`) to find the user's most recent post, and extract its **Today** section bullets. Build the Standup scratch file:

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

## Phase 2: The Editing Pass

**REQUIRED:** Invoke the `ls-interactivity:interactive-command` skill exactly once, with a single command that opens `nvim` on each window whose scratch file exists, in order:

```bash
nvim -- /tmp/plan-morning-yesterday-<date>.md; nvim -- /tmp/plan-morning-today-<date>.md; nvim -- /tmp/plan-morning-standup-<date>.md
```

Omit any window that Phase 1 skipped. Name the tab `plan-morning`.

## Phase 3: Post-Processing

After the tab closes, read each scratch file that exists directly from its dated path and apply the results.

### From Yesterday

- For each day section, apply the saved task markers to that day's source note: a task whose marker changed gets updated in place, and a task the user deleted from the file gets removed from the note. Leave untouched anything the file doesn't mention.
- Write the Highlights answers into yesterday's note as a numbered list, if that section was included.
- For the Identity Vote, if it was included, read the single checked option and fill in yesterday's note's empty Identity Vote section: a `**Vote:**` line with the checked emoji mapped to its signed score, and an `**Evidence:**` line with the evidence text.

  | Checked          | Vote line               |
  | ---------------- | ----------------------- |
  | 🔴 Voted against | `🔴 Voted against (-2)` |
  | 🟠 Slipped       | `🟠 Slipped (-1)`       |
  | 🟡 Broke even    | `🟡 Broke even (0)`     |
  | 🟢 Made progress | `🟢 Made progress (+1)` |
  | 🔵 Nailed it     | `🔵 Nailed it (+2)`     |

  If no box is checked, leave yesterday's Identity Vote section empty. If more than one is checked, ask the user which they meant before writing.

Then run `scripts/forward-tasks.rb`. It merges every `>`, `<`, and `/` task from the recent prior notes into today's note under the matching subheader, removing scheduled tasks from their source.

If the script exits non-zero, it names the prior notes it can't proceed with. Fix the named problem and rerun until it exits 0:

- **A task not under a subheader:** The note lost a header such as `### Personal`. Restore it directly.
- **Unresolved `- [ ]` items:** Resolve it directly in the source note.

### From Today

- Apply the saved task edits to today's note, the same way as Yesterday's: update changed markers/text in place, remove anything the user deleted, leave everything else untouched.
- For each newly added Work task, search Linear for a matching issue in the user's teams. If a match is found, link to the Linear issue URL. If multiple candidates exist, ask which one matches. If none match, leave the task unlinked.
- Apply the Gratitude, Better Day, and Daily Affirmation answers to their matching sections in today's note.

### From Standup

If the Standup window ran, parse its sections and hand off to `oyster-team-ai:standup`: "The user has already filled in their standup answers via an interactive editor — skip all context-gathering and question steps, compose the message, and post it directly without asking for confirmation. Yesterday: [bullets from file], Today: [bullets from file], Blockers: [content or none], Feeling: [content or none]."
