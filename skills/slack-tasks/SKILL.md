---
description: Use when building or updating the Work tasks section of today's daily note from Slack activity.
---

# Slack Tasks

Build a task list from the user's Slack activity and write it into the Work section of today's daily note at `~/Notes/Daily Notes/YYYY-MM/YYYY-MM-DD - Daily Note.md`.

## Step 1: Gather Messages

Run these two searches in parallel using the Slack MCP. The logged-in user's ID is shown in the `slack_search_public_and_private` tool description.

- **Today's messages:** `from:<@USER_ID> after:YESTERDAY` — finds messages the user sent today
- **Open Later items:** `is:saved` and `is:saved is:complete` — diff the two sets to get items that are saved but not yet marked complete

For every message the user _replied to_ (not just sent), read the full thread. Replies often contain context or commitments that become tasks — the parent message, not the reply, holds that context.

## Step 2: Identify Actionable Items

An item is actionable if it requires the user to do something: review a PR, respond to a question, watch a video, follow up on a ticket, etc. Skip:

- Reactions, acknowledgments, or messages that are purely informational
- Later items already marked complete
- GitHub PRs that are merged OR have a review submitted by the user

To check PR status: `gh pr view <number> --repo <owner>/<repo> --json state,reviews,mergedAt`

## Step 3: Format Tasks

Each task gets one link embedded naturally in the prose — link to the **Slack conversation** where the item came from, not directly to the content (PR, doc, Loom, etc.). The conversation provides context; the content is one click away from there.

Exception: if the message itself IS the content (e.g. a GitHub PR comment thread), link directly to it.

Good examples:

```
- [ ] Review [Herbert's updated engineering assessment](slack://DM-thread)
- [ ] Watch [Viktor's Loom](slack://DM-thread) about AI agents
- [ ] Review Erik's [4 remaining stacked PRs](slack://thread) for the release pipeline
```

Avoid trailing `-- [thread]` or `-- [message]` links. Embed the link in the task description itself.

## Step 4: Write to Daily Note

Find the `### Work` section and append the tasks after any existing ones. Do not remove or reorder existing tasks.

## Rationalizations

| Thought                                          | Reality                                                                       |
| ------------------------------------------------ | ----------------------------------------------------------------------------- |
| "The PR link is more useful than the Slack link" | The Slack thread has context. Link there first.                               |
| "I only need to check messages the user sent"    | Replies to others often carry the real commitment. Read those threads.        |
| "A merged PR is done"                            | Check for a review by the user too — they may have only approved, not merged. |
| "I'll add a trailing `(thread)` link"            | Embed it in the prose. Trailing links are noise.                              |
