# Status Footer

When the user has something to act on, end your reply to them with a status footer so they can spot it at a glance. This applies only to replies the user reads directly, never to a subagent's report back to the agent that launched it. Put it last, one line per status, most urgent first, with the status in bold and title case. Keep each line to a few words; the details belong in the reply above. When your next step opens a window that blocks until the user closes it, put the footer in the message you send as you open it:

```markdown
⏳ **Waiting on Pre-Review**
```

Use only these statuses:

- 👀 Needs Review: A change is open in `interactive-review` waiting for the user's review. Never use this for a GitHub PR review request or any other kind of review.
- 📋 Review the Plan: A plan is open and waiting for the user to read it and respond.
- 🚢 Ready to Merge and Close: The work is committed in a repository that merges directly into the default branch. The branch still needs to merge and the workspace can be closed afterwards.
- 🔀 Ready to Open Pull Requests: The work is committed in a repository that integrates through pull requests, and its pull requests are ready to open.
- ✅ Ready to Close: The work is committed and already merged, so only the workspace is left to close. In a repository that integrates through pull requests, this applies only once every pull request has merged. Still applies even if you already removed the git worktree yourself.
- 🚧 Blocked by <Reason>: Work can't continue until the user answers a question, approves something or fixes a problem. Name the blocker. Approval to merge or close finished work is never a blocker; use Ready to Merge and Close, Ready to Open Pull Requests or Ready to Close.
- ⏳ Waiting on <Task>: A background task is running and you'll report back when it finishes. Name the task.

When none apply, leave the footer off. Never add a status that only describes what you did, like "Done" or "Updated the file". The footer is for the user's next move, not a recap.

## Rationalizations

| Thought                                         | Reality                                                                      |
| ----------------------------------------------- | ---------------------------------------------------------------------------- |
| "The status is obvious from the reply"          | The user scans the bottom first. If they have a next move, add it.           |
| "I'm waiting on approval to merge"              | That's Ready to Merge and Close, not Blocked by Merge Approval.              |
| "A PR is open for review, so Needs Review"      | Needs Review is only for `interactive-review`. Use another status or none.   |
| "The work is done, so Ready to Merge and Close" | Not when the repository uses pull requests. Use Ready to Open Pull Requests. |
| "The pull request is open, so Ready to Close"   | It isn't merged. Babysit it and use Waiting on until it merges.              |
| "I already removed the worktree myself"         | The workspace outlives its worktree. Still flag Ready to Close.              |
| "I called the last wait Pre-Review, keep it"    | Re-check what's actually blocking now, not what blocked last time.           |
