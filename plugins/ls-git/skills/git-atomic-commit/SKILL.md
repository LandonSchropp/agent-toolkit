---
description: Use when splitting a working tree into atomic commits, or when changes need to be distributed across new commits and/or edits to prior commits on the branch. Especially relevant when changes within a single file belong in different commits.
---

# Git Atomic Commit

An atomic commit captures one logical change. Each commit stays portable: it can be reviewed, reverted, cherry-picked, lifted into its own PR, edited, or reordered without rebase conflicts cascading through the work that came after.

Atomic commits also keep history honest. Without that discipline, the log records false starts and reversals — code added in one commit and removed in another — and readers have to trace every commit to know the final state.

Crucially, **atomic commits optimize for reviewability**. A commit should be small enough that a reviewer can understand all of it at once without context-switching. When a logical change grows large, split it into smaller, reviewable pieces—each defensible on its own, each landing in a single coherent narrative arc.

## Why Changes in One File Get Split

A single file often picks up changes that belong in different commits:

- Refactor + behavior change: You restructured a function and then added new logic in the same edit. The refactor should land as its own commit ("make the change easy, then make the easy change") so reviewers can verify it's pure before evaluating the new behavior.
- Drive-by edits: Mid-feature you fixed a typo, removed dead code, or tidied imports. These don't belong with the feature work and shouldn't have to wait for it to merge.
- Independent concerns: A shared utility or config file gets touched by two unrelated efforts in the same session.
- Commit size: Even a single logical concern can become too large to review comfortably. If a commit exceeds roughly 100-200 lines of changes, consider splitting it further. Reviewers must hold the entire change in mind at once; smaller commits make that easier and catch bugs faster.

Don't let "but it's just one file" or "but it's one logical change" be the reason unrelated changes or oversized changes ship together. **Optimize for the reviewer, not the commit count.**

## What Makes a Commit Reviewable

A reviewable commit:

- **Stays focused.** One purpose, one narrative. A reviewer should never ask "why is X in this commit?"
- **Is small.** Typically under 200–400 lines of changes. Larger changes force reviewers to split their attention and miss bugs.
- **Stands alone.** It can be understood without tracing through other commits. The diff should be self-explanatory.
- **Builds on stable ground.** It depends only on commits already in the branch, not on later ones.

When you feel a commit straining these bounds, it's a signal to split it. Break it into smaller commits that each pass this test, even if it means fragmenting a single logical effort.

## Triggering the Process

When the user invokes this skill, they _might_ be hinting that they'd like to split up some uncommitted changes atomically.

If there are uncommitted changes in the working tree (staged or unstaged), or the user is explicitly asking to reorganize existing work into atomic commits, follow the procedure in [references/process.md](references/process.md). Always present the plan to the user and wait for confirmation before executing.

Keep the worktree clean while preparing each atomic commit. If you discover changes that are unrelated to the current commit, stash them or revert them before showing the diff to the user or asking for approval. The goal is to keep the review surface limited to the files that belong to the change under review.

If there's nothing to split, apply atomic-commit principles to any new commits made during the rest of the session.

## Rationalizations

| Thought                                              | Reality                                                                        |
| ---------------------------------------------------- | ------------------------------------------------------------------------------ |
| "I'll just commit everything as one"                 | The user invoked this skill to split. Propose a plan first.                    |
| "I can use `git add -p`"                             | Requires a TTY. You can't. Use restore-and-replay.                             |
| "I'll add a follow-up commit to patch the prior one" | If it belongs to a prior commit on the branch, edit it. Don't pollute history. |
| "I'll skip the plan step and start committing"       | Without a plan, you'll commit the wrong groupings. Show the user first.        |
| "Restore-and-replay is too tedious"                  | It's the only working option. Use it.                                          |
| "I'll describe the splits and let the user do it"    | After plan approval, execute the splits yourself.                              |
| "This is one logical change, don't split it"         | Logical unity ≠ reviewability. If reviewers can't hold it in mind, split it.   |
| "Splitting takes more time"                          | Smaller commits are faster to review, catch more bugs, and cherry-pick better. |
| "The change is too interconnected to split"          | Interdependencies between commits signal design debt. Splitting exposes it.    |
