---
description: Use when splitting a working tree into atomic commits, or when changes need to be distributed across new commits and/or edits to prior commits on the branch. Especially relevant when changes within a single file belong in different commits.
---

# Git Atomic Commit

An atomic commit captures one logical change. Each commit stays portable: it can be reviewed, reverted, cherry-picked, lifted into its own PR, edited, or reordered without rebase conflicts cascading through the work that came after.

Atomic commits also keep history honest. Without that discipline, the log records false starts and reversals — code added in one commit and removed in another — and readers have to trace every commit to know the final state.

## Why Changes in One File Get Split

A single file often picks up changes that belong in different commits:

- Refactor + behavior change: You restructured a function and then added new logic in the same edit. The refactor should land as its own commit ("make the change easy, then make the easy change") so reviewers can verify it's pure before evaluating the new behavior.
- Drive-by edits: Mid-feature you fixed a typo, removed dead code, or tidied imports. These don't belong with the feature work and shouldn't have to wait for it to merge.
- Independent concerns: A shared utility or config file gets touched by two unrelated efforts in the same session.

Don't let "but it's just one file" be the reason unrelated changes ship together.

## Triggering the Process

When the user invokes this skill, they _might_ be hinting that they'd like to split up some uncommitted changes atomically.

If there are uncommitted changes in the working tree (staged or unstaged), or the user is explicitly asking to reorganize existing work into atomic commits, follow the procedure in [references/process.md](references/process.md). Always present the plan to the user and wait for confirmation before executing.

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
