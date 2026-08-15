---
description: Use when the user says "plan my morning" or wants to fill out morning journaling (Gratitude, Better Day, Daily Affirmation) and personal/work tasks for today's daily note.
---

# Plan Morning

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

This skill is split into 3 phases: pre-process the scratch files, run one editing pass through up to three windows (Yesterday, Today, Standup), then post-process the results.

Before doing anything else, read yesterday's and today's daily note files. (Today's note already having content is expected, not ambiguous.)

## Structure

### Scratch File Paths

Each window's content lives at `/tmp/plan-morning-<date>-<step>.md`, where `<date>` is today's ISO date and `<step>` is `yesterday`, `today`, or `standup` (e.g. `/tmp/plan-morning-2026-08-06-yesterday.md`). If a step's file already exists, don't rebuild its content — leave it as-is.

### Task List Format

Use this format whenever presenting tasks for editing, as one section nested within a window's scratch file:

- Open the task block with a `Tasks` header and one italic sentence saying what the user should do with them: `## Tasks` in the Today window, `### Tasks` in the Yesterday window.
- Give each day in the Yesterday window its own `## [Weekday, Month Day, Year]` header, with that day's task block nested under it. Suffix yesterday's header with `(Yesterday)`.
- Give each subsection that has tasks a header one level below the block.
- Copy task lines verbatim (keep wikilinks and current markers) so they round-trip cleanly.
- Never invent a placeholder task. The Today window is the one exception to the previous bullet: keep today's subheaders even when empty, so the user has somewhere to add tasks.

Example:

```markdown
## Tasks

_Add, edit, and remove tasks to plan today._

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

Run `scripts/resolve-tasks.rb`. It writes every recent prior note's unresolved (`- [ ]`) tasks to the Yesterday scratch path, oldest-first in the **Task List Format**, each day under a `## [Weekday, Month Day, Year]` header, with yesterday's suffixed `(Yesterday)`. Forwardable markers (`>`, `<`, `/`) carry forward automatically during the editing pass, so the script leaves them out.

Check whether a daily note exists for yesterday (the literal previous calendar day) and whether its `### :LiStar: Highlights of the Day` and `### :LiVote: Identity Vote` sections (both under `## :LiMoon: Evening`) are empty or missing entirely — an older note may not have these headers at all. If either is empty or missing, add the relevant prompt(s) as `###` sections under yesterday's own day header, which the script's oldest-first order puts at the end of the file. Add that `## [Weekday, Month Day, Year] (Yesterday)` header yourself when yesterday had no unresolved tasks and the script therefore wrote no section for it, along with the `# Previous Daily Notes` title if the script wrote nothing at all.

```markdown
# Previous Daily Notes

## Monday, January 1, 2026

### Tasks

_These tasks were left unresolved. Mark each one with what happened to it._

#### Personal

- [ ] Update the README.md

## Tuesday, January 2, 2026 (Yesterday)

### Tasks

_These tasks were left unresolved. Mark each one with what happened to it._

#### Work

- [ ] Post a [status update](https://example.com)

### Highlights

_What were the notable moments?_

1.
2.
3.

### Identity Vote

_Every action is a vote for the person you're becoming. Yesterday, did you move toward that person?_

- [ ] 🔴 Voted against
- [ ] 🟠 Slipped
- [ ] 🟡 Broke even
- [ ] 🟢 Made progress
- [ ] 🔵 Nailed it

**Evidence:**
```

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

Build the Today scratch file from today's note's current Tasks section plus the journaling prompts. Leave out forwarded tasks: the editing pass adds them to the file before the Today window opens. Include the Gratitude, Better Day, and Daily Affirmation prompts only for slots that are still empty in today's note. If the user asks for help writing the Daily Affirmation, see [Daily Affirmation](references/daily-affirmation.md). Add one line to the file's instructions: fill in the daily improvement focus by extending its line to `- [ ] Daily improvement: <focus>`.

```markdown
# Today

## Tasks

_Add, edit, and remove tasks to plan today._

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

**REQUIRED:** Invoke the `ls-interactivity:interactive-command` skill exactly once, with `scripts/plan-morning.rb` as the command and `plan-morning` as the tab name. Write the script's path out in full, since the command runs in a shell whose working directory is the session's, not the skill's.

That script is the whole pass: it opens every window Phase 1 built, in order, and runs the steps that belong between them. Run it and nothing else — the pass is deliberately uninterrupted, so don't take control back between windows to run a step yourself.

## Phase 3: Post-Processing

After the pass finishes, read each scratch file that exists directly from its dated path and apply the results.

Check the pass's exit status first. Zero means it applied the Yesterday scratch file's edits to their source notes — changed markers, tasks the user added, and tasks the user deleted — and forwarded every recent note's `>`, `<`, and `/` tasks into today's note and its scratch file. Nothing further is needed here.

A non-zero status means a step failed and the pass stopped there. Read the tail of `/tmp/plan-morning-<date>.log` for the error, fix it per the cases below, then rerun `scripts/plan-morning.rb` until it exits zero. The log spans every run for the day, so read only the error at the end of it.

- **A task not under a subheader:** A source note lost a header such as `### Personal`. Restore it in the note.
- **Unresolved `- [ ]` items:** The pass refuses to forward while any recent note still holds one. Fix it in the **Yesterday scratch file**, not the source note, whenever that file covers the day: the file is the source of truth, and tasks are matched by text alone, so a marker fixed only in the note gets overwritten from the file on the next run and the same error repeats. Edit the source note directly only for a day the scratch file doesn't cover.

### From Yesterday

- Write the Highlights answers into yesterday's note as a numbered list under `### :LiStar: Highlights of the Day`, if that section was included. Add the header (and its parent `## :LiMoon: Evening` header, per the template) if the note doesn't already have it.
- For the Identity Vote, if it was included, read the single checked option and fill in yesterday's note's `### :LiVote: Identity Vote` section (adding the header, and its parent `## :LiMoon: Evening` header, if missing): a `**Vote:**` line with the checked emoji mapped to its signed score, and an `**Evidence:**` line with the evidence text.

  | Checked          | Vote line               |
  | ---------------- | ----------------------- |
  | 🔴 Voted against | `🔴 Voted against (-2)` |
  | 🟠 Slipped       | `🟠 Slipped (-1)`       |
  | 🟡 Broke even    | `🟡 Broke even (0)`     |
  | 🟢 Made progress | `🟢 Made progress (+1)` |
  | 🔵 Nailed it     | `🔵 Nailed it (+2)`     |

  If no box is checked, leave yesterday's Identity Vote section empty. If more than one is checked, ask the user which they meant before writing.

The resulting section, whether it already existed or had to be added:

```markdown
## :LiMoon: Evening

### :LiStar: Highlights of the Day

1. Shipped the plan-morning rewrite
2. Fixed the missing Evening section bug

### :LiVote: Identity Vote

**Vote:** 🟢 Made progress (+1)
**Evidence:** Kept iterating on plan-morning until it actually worked end to end.
```

### From Today

- Apply the saved task edits to today's note: update changed markers/text in place, remove anything the user deleted, leave everything else untouched.
- For each newly added Work task, search Linear for a matching issue in the user's teams. If a match is found, link to the Linear issue URL. If multiple candidates exist, ask which one matches. If none match, leave the task unlinked.
- Apply the Gratitude, Better Day, and Daily Affirmation answers to their matching sections in today's note.

### From Standup

If the Standup window ran, parse its sections and hand off to `oyster-team-ai:standup`: "The user has already filled in their standup answers via an interactive editor — skip all context-gathering and question steps, compose the message, and post it directly without asking for confirmation. Yesterday: [bullets from file], Today: [bullets from file], Blockers: [content or none], Feeling: [content or none]."
