---
name: plan-day
description: Use when the user says "plan my day" or "plan my morning", or wants to fill out morning journaling (Gratitude, Better Day, Daily Affirmation) and personal/work tasks for today's daily note.
---

# Plan Day

**REQUIRED:** Invoke the `ls-notes:daily-note` skill NOW for vault context and file path conventions.

The planning happens in `plan-day`, a terminal app on the user's `PATH` that writes the results into the daily notes itself.

## Open Pull Requests

Before opening `plan-day`, fill in the subtasks of today's `Update/merge open pull requests` Work task. Skip this when today's note has no such task, or when the `plan-day` draft (see [Planning](#planning)) exists.

Find the user's pull requests in their work GitHub organization (the domain of their work email, without the TLD):

```bash
gh search prs --author=@me --owner=<organization> --state=open --json title,url,repository
gh search prs --author=@me --owner=<organization> --merged --merged-at=">=<today's ISO date>T00:00:00<UTC offset>" --json title,url,repository
```

Use midnight in the user's time zone, since GitHub otherwise compares the date in UTC.

Check each open one:

```bash
gh pr view <url> --json author,reviewDecision,statusCheckRollup,reviewRequests,mergeable,mergeStateStatus,latestReviews,headRefName,baseRefName
```

Give it every status that applies, comma-separated:

- `💬 Feedback`: `reviewDecision` is `CHANGES_REQUESTED`, or it isn't `APPROVED` and an entry in `latestReviews` by someone other than the `author` is `COMMENTED`. Replying to a review thread records a `COMMENTED` review from the author, which doesn't count.
- `⏱️ Awaiting Review`: `reviewRequests` isn't empty.
- `☠️ CI Failing`: An entry in `statusCheckRollup` has a `state` or `conclusion` of `FAILURE` or `ERROR`.
- `🚫 Blocked`: `mergeable` is `CONFLICTING`, or `mergeStateStatus` is `BLOCKED` and no other status applies. `BLOCKED` also covers a missing approval or failing check, which the other statuses already name.
- `❓ Pending`: `mergeable` is `UNKNOWN`, or an entry in `statusCheckRollup` has a `status` other than `COMPLETED` or a `state` of `PENDING`.

A pull request merged today gets `🚀 Merged` alone and is checked off.

Write one subtask per pull request. Title it with the repository name, a colon, and the pull request's title with any conventional commit prefix (`feat: `) or ticket ID (`[EX-123] `) removed, keeping its casing. Leave the parent task's text as it is. List a stack from bottom to top: a pull request whose `baseRefName` is another's `headRefName` comes after it.

```markdown
- [ ] Update/merge open pull requests
  - [ ] [widget-service: Add pagination to the widget list](https://github.com/example-org/widget-service/pull/42) (💬 Feedback, ☠️ CI Failing)
  - [ ] [widget-service: Sort the widget list by date](https://github.com/example-org/widget-service/pull/43) (⏱️ Awaiting Review)
  - [x] [webapp: Fix the login redirect](https://github.com/example-org/webapp/pull/7) (🚀 Merged)
```

If the task already has pull request subtasks, update them in place: refresh each status, add new pull requests, and remove ones that were closed, or merged before today. Never add a second line for the same pull request.

## Planning

**REQUIRED:** Invoke the `ls-interactivity:interactive-command` skill with `plan-day > /tmp/plan-day-<date>.md 2> /tmp/plan-day-<date>.log` as the command, where `<date>` is today's ISO date, and `plan-day` as the tab name. With its output redirected, `plan-day` draws on the terminal and prints only a summary to the file.

When the tab closes, read the summary and the log.

**Never edit a daily note while the `plan-day` tab is open.** `plan-day` holds back any planned change that conflicts with an edit made after it read the note, so an edit made mid-session can undo what the user planned. This covers every daily note, not just today's, and every edit, even a one-character typo fix the user asked for. Tell the user each edit is queued, hold it until the tab closes, then apply it along with the comments.

The one exception is a session the user hasn't started. `plan-day` saves a draft to `${XDG_STATE_HOME:-$HOME/.local/state}/plan-day/draft.json` the first time the user turns a page or clicks a tab. While that file doesn't exist, close the tab (**REQUIRED:** follow the `ls-interactivity:interactive-command` skill's rules for closing a tab), do what the user asked, then open `plan-day` again as above. Once the draft exists, queue the edit, even if the user has gone back to the first page: a reopened session resumes from the draft and still holds back the conflicting changes.

## Errors

Before carrying out any comment, resolve every problem the summary or the log reports by following the instructions `plan-day` prints with it.

## Comments

Each comment is an instruction about its task. Carry out every one, editing the notes directly; ask the user only when a comment is ambiguous or needs a decision from them.

## More Tasks

Once every comment is carried out, ask the user whether there are any other tasks they'd like to add to today's daily note, and add them.

Once the user has no more tasks to add, **REQUIRED:** use the `ls-agent:close-workspace` skill to close this workspace.
