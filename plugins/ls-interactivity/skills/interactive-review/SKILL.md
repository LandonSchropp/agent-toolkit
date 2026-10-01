---
name: interactive-review
description: Use when a skill needs the user to interactively review code changes in Hunk mid-workflow — working changes, staged changes, or a specific commit — then act on their decision and comments. Takes a review mode.
user-invocable: false
---

# Interactive Review

## Opening the Review

Run `scripts/interactive-review.sh <mode> [<arguments>] [--directory <path>]`. It opens Hunk in a background herdr tab named `review`, prints the repository to listen to, and returns right away. Running it again while that review is open reloads it in place, keeping the user's comments.

The script supports several modes:

- `working`: Unstaged changes only, including untracked files.
- `staged`: Staged changes only.
- `commit <sha>`: A single commit, compared with its parent.
- `diff <before> <after>`: One path against another, neither of which needs to be in a repository. See [Reviewing Files Outside A Repository](#reviewing-files-outside-a-repository).

Run `scripts/interactive-review.sh --help` for details. If it prints `Review is disabled for this workspace.` instead of a repository, skip the review.

`--directory` is the repository holding the changes, which is not always the one the session started in. Pass it explicitly every time rather than relying on where the command happens to run. When it isn't the session's own repository, commit with `git -C <same directory>`: the commit hook resolves the repository from that flag and can't see a `cd`, so it blocks an approved commit without one.

## Listening for the Decision

**REQUIRED:** Use the `hunk-review-loop` skill to listen for the user's decision and to act on it and the user's comments, but listen with `scripts/listen.sh --directory <printed repository>` in place of `hunk review listen`. It prints the same lines, and on an approval, a comment or a denial it switches the user back to your tab. In `staged` mode, the review shows only what's staged, so stage your fixes to make them show, and stage any edits the user makes during the review. Stage only the changes that belong to the commit, since a file can be partly staged on purpose.

Reply to every comment you handle. When you made the change exactly as asked, reply with ✅ and nothing else; otherwise _briefly_ explain what you did or why you didn't make the change. Never remove the user's comments: they're the record of what happened in the review.

When the user approves, and before committing:

1. Read the user's comments. Closing the tab ends the Hunk session, and its comments go with it.
2. Run `scripts/record-approval.sh --directory <printed repository>`, so the commit hook allows the commit.
3. Close the `review` tab. Closing Hunk also ends the listener.

In `commit` mode the commit already exists, so skip `record-approval.sh`. The decision and comments still count.

## Reviewing Files Outside A Repository

`diff <before> <after>` reviews one path against another — two files, or two directories — neither of which needs to be in a repository. It takes no `--directory`.

Nothing records the before-state for you, so copy the file or directory somewhere first, before the first edit. Without that copy there is nothing to diff against, and no way to make one after the fact.

The review shows a copy of `<after>`, so it doesn't follow later edits. After revising, run the script again with the same paths to refresh the open review.

## Choosing Working vs. Staged Mode

`working` mode reviews every unstaged change in the worktree, including untracked files, but nothing that is already staged.

Before invoking the script, run `git status`, and pick the mode from what it reports. Anything already staged is invisible to `working` mode, so a fully staged worktree has nothing for it to show and the script refuses to open it. If the worktree has uncommitted changes unrelated to the commit being built, `working` mode would mix them into the review; stage only the files belonging to this commit (`git add <files>`) and invoke `staged` mode instead. Either way, don't leave the commit's changes split across the index and the worktree, since neither mode shows both halves.

## Closing the Review

Once the user has approved and you've read their comments, close the `review` tab by its tab ID, the way the `ls-interactivity:interactive-command` skill closes a leftover tab. The tab has no script of its own to stop.

NEVER ask the user to close the tab for you. Always close it yourself.
