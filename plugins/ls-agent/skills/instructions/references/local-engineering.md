# Local Engineering

You're running in Claude Code inside herdr, on the user's Mac. This environment owns engineering that edits a repository on this machine or needs the user's development environment, including all personal engineering and the skills in `agent-toolkit`. It never takes life admin, planning or design work; those belong to Non-Engineering.

Use the `trash` command in place of `rm` when removing files.

## Reviewing Commits

Every commit is reviewed before it is created. Present each commit's changes for review and create the commit only after the user signs off. Drive the review yourself.

The decision the `ls-interactivity:interactive-review` skill delivers (approve, comment or deny) is the only signal that matters — never ask the user whether they're ready to commit or want another look. A commit hook also blocks `git commit` until an approved review is on record, as a backstop, but don't rely on hitting it to find out the answer; act on the decision directly.

The decision and the user's comments are independent signals — read both. They combine into these cases:

- **Approved / comments:** Minor fixes. Address them, then commit — already signed off, no re-review needed.
- **Approved / no comments:** Ready to commit as-is.
- **Commented:** Questions or notes, not a decision yet. Answer the questions in your replies, make any changes the comments ask for, then wait for the next decision. Never record an approval or commit on a comment.
- **Denied / comments:** Real concerns. Address them, then wait for the next decision; the open review shows your changes.
- **Denied / no comments:** The user wasn't ready to review this. Stop and wait for them rather than retrying.

The review step in [Commits](commits.md) is this one:

1. Present the changes for review. **REQUIRED:** Invoke the `ls-interactivity:interactive-review` skill, normally in `working` mode; follow its own guidance on when to use `staged` mode instead.
2. Read the decision and the user's comments, and follow the matching case above.

## Running Commands

Run Bash commands one at a time. Don't chain commands together with `&&` or `;`. Each command is its own Bash tool call, so the user can review and approve them individually.

## Referring to Workspaces

When telling the user about a workspace, name it by the label shown in the herdr UI, never by its internal ID. The user never sees the IDs, so an ID tells them nothing. Keep IDs for herdr commands only; `herdr workspace list` maps them to labels.

## Finishing a Workspace

When the whole assignment is finished (not each task within it) the work isn't done until it is integrated and the workspace is closed. Offer to merge into main or open pull requests for the work (depending on the situation below) and close the workspace. Always offer both at the same time, so the user answers one question instead of two. The exception is a work repository that integrates through pull requests: open the pull requests, then offer to post them for review, and offer to close the workspace only once they're posted.

A main checkout closes the same way a linked worktree does; an agent closes itself out either way, even when its child worktrees are still open.

- **Repositories that merge directly into the default branch:** On approval, **REQUIRED:** invoke the `ls-git:git-merge-into-main` skill and follow it, then the `ls-agent:close-workspace` skill.
- **Repositories that integrate through pull requests:** **REQUIRED:** invoke the `ls-git:stacked-pull-requests` skill for a stack. When the user approves posting them for review, **REQUIRED:** invoke the `ls-git:ready-for-review` skill. Then invoke the `ls-agent:close-workspace` skill. The branch outlives the worktree in the main checkout, and the pull request merges from there.

## Rationalizations

| Thought                                                | Reality                                                                    |
| ------------------------------------------------------ | -------------------------------------------------------------------------- |
| "`rm` is fine for a scratch file"                      | `trash` is recoverable. Use it every time.                                 |
| "I'll ask if they're ready to commit"                  | The decision already answered that. Act on it, don't ask.                  |
| "I'll ask if they want to re-review"                   | A denial already answered that. Address it, don't ask.                     |
| "It was approved, so there's nothing to check"         | Approval and comments are independent. Check both.                         |
| "Denied with no feedback — I'll retry anyway"          | No comments means they weren't ready. Stop and wait.                       |
| "They only commented, so the rest is approved"         | A comment is not an approval. Reply, then wait for the next decision.      |
| "This change is trivial, skip the review"              | Every commit is reviewed. Present it.                                      |
| "I'll commit now and let them review after"            | Review comes before the commit. Present first.                             |
| "No feedback last time, so skip it now"                | A new change is a new review. Present it.                                  |
| "The worktree has unrelated edits too"                 | Stage only this commit's files and review in staged mode.                  |
| "The workspace ID is precise enough"                   | The user only sees labels. Name the workspace by its label.                |
| "Chaining commands saves a round trip"                 | Each command needs its own approval. Run them one at a time.               |
| "I'll ask to merge now and to close later"             | One question covers both. Ask once, then do both.                          |
| "The task is done, so the worktree can wait"           | An unmerged worktree is unfinished work. Offer to close it.                |
| "This is the main checkout, not a worktree"            | It closes too, even with worktrees still open.                             |
| "I'll merge into main, it's simpler"                   | Only where the repository merges directly. Elsewhere, open a pull request. |
| "The pull request hasn't merged, so keep the worktree" | The branch survives in the main checkout. Close the worktree anyway.       |
