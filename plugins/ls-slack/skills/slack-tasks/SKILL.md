---
description: Use when building or updating the Work tasks section of today's daily note from Slack activity.
---

# Slack Tasks

Build a task list from the user's Slack activity and append it to the Work section of today's daily note.

**REQUIRED:** Invoke the `ls-notes:daily-note` skill first. It ensures today's note exists and documents its section structure.

## Step 1: Gather Messages

Run these two searches in parallel using the Slack MCP. The logged-in user's ID is shown in the `slack_search_public_and_private` tool description.

- **Today's messages:** `from:<@USER_ID> after:YESTERDAY` — finds messages the user sent today
- **Open Later items:** `is:saved` and `is:saved is:complete` — diff the two sets to get items that are saved but not yet marked complete

For every message the user _replied to_ (not just sent), read the full thread. Replies often contain context or commitments that become tasks — the parent message, not the reply, holds that context.

## Step 2: Identify Candidate Items

An item is a candidate if it represents something the user did, is doing, or needs to do: review a PR, respond to a question, watch a video, follow up on a ticket, ship a change, etc. Skip only purely informational messages (reactions, acknowledgments, FYIs).

Include items the user has already completed (merged PR, submitted review, Slack Later item marked complete) — these belong in the daily note as `[x]`, not omitted.

**Consolidate open PR review requests** into a single `- [ ] Review pull requests` candidate. The user reviews all of them at once in one channel and does not want each PR listed individually. This applies only to PRs the user has yet to review; PRs the user has already merged or reviewed should still be listed individually as `[x]` so they appear as a record of done work.

To check PR status: `gh pr view <number> --repo <owner>/<repo> --json state,reviews,mergedAt`.

## Step 3: Format Tasks With Suggested Markers

Format each candidate as a markdown task line. Pick the suggested marker based on the item's current state:

- `[ ]`: Open / not yet started.
- `[/]`: In progress (e.g., a PR you've commented on but not yet reviewed).
- `[x]`: Already complete (e.g., a PR you've merged or a review you've submitted).

Each task gets one link embedded naturally in the prose — link to the **Slack conversation** where the item came from, not directly to the content (PR, doc, Loom, etc.). The conversation provides context; the content is one click away from there. Exception: if the message itself IS the content (e.g. a GitHub PR comment thread), link directly to it. Avoid trailing `-- [thread]` or `-- [message]` links — embed the link in the task description itself.

Example formatting:

```
- [ ] Review Alex's [engineering assessment](slack://DM-thread)
- [/] Follow up on Jordan's [4 remaining stacked PRs](slack://thread) for the release pipeline
- [x] Merged the [release pipeline PR](slack://thread)
```

## Step 4: Match Linear Issues for Coding Tasks

For candidates that involve writing, shipping, or reviewing code (not PR reviews already handled as consolidated items), search Linear for matching issues in the user's teams (use `list_issues` with team and project filters). Use the task description as keywords to find relevant open issues.

For each match found, ask the user for confirmation in the Step 5 batch — don't interrupt for each one individually:

- **Task has no Slack link** (e.g., item came from a Slack Later item title with no thread context): ask whether to use the Linear issue URL as the task link.
- **Task has a Slack link and the Slack thread does not reference the Linear issue**: ask whether the Slack conversation should be linked to the Linear issue.

If no match is found for a coding task, leave it as-is.

## Step 5: Confirm Each Task

Present the formatted candidates to the user in a single message:

- Use `## Slack Tasks` as the header.
- Number each candidate, preserving its suggested marker in the line (e.g., ``1. `[x]` Merged the release pipeline PR``).
- If any tasks from Step 4 need a yes/no on linking to a Linear issue, include those questions after the numbered list, clearly labeled.
- End with this legend: ``Legend: `y` add as shown, `n` skip, ` ` open, `/` in-progress, `x` complete.``

Wait for the user's response. They will give one answer per number (e.g., `1. y, 2. n, 3. x`). `y` adds the task with the suggested marker; `n` skips it; any other marker character overrides the suggested marker and adds the task with that marker.

## Step 6: Write Approved Tasks to Daily Note

Append the approved tasks (with their final markers) to the Work subsection of Tasks in today's daily note. Do not remove or reorder existing tasks.

## Rationalizations

| Thought                                          | Reality                                                                       |
| ------------------------------------------------ | ----------------------------------------------------------------------------- |
| "The PR link is more useful than the Slack link" | The Slack thread has context. Link there first.                               |
| "I only need to check messages the user sent"    | Replies to others often carry the real commitment. Read those threads.        |
| "A merged PR is done"                            | Check for a review by the user too — they may have only approved, not merged. |
| "I'll add a trailing `(thread)` link"            | Embed it in the prose. Trailing links are noise.                              |
