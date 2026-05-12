---
description: Use when needing to fixup, squash, drop, reword, reorder, or edit commits in a branch's history. Handles the non-interactive approach agents need since `git rebase -i` requires a TTY.
---

# Git Edit Commit

This skill outlines how agents can edit previous commits. Agents can't use `git rebase -i` directly, which requires a TTY. This skill provides helper scripts instead.

REQUIRED: Always reference commits by SHA, not by HEAD-relative notation like `HEAD~3`.

## Inspect Commits First

Run `git log --oneline` to get SHAs. Output is newest-first; the rebase plan is oldest-first.

## Amending the Latest Commit

To fold staged changes into the most recent commit without changing its message:

```bash
git add <files>
git commit --amend --no-edit
```

## Fixup and Squash (Recommended Shortcut)

```bash
git commit --fixup=<target-sha>   # merge into target, discard message
git commit --squash=<target-sha>  # merge into target, combine messages

# <oldest-sha-in-scope>^ is the parent of the oldest commit in scope; use --root if it's the first commit
scripts/non-interactive-git-rebase.sh --autosquash <oldest-sha-in-scope>^
```

## Drop, Reorder, Edit

Use `scripts/non-interactive-git-rebase.sh`. Supply the plan via stdin. Use `--root` when the oldest commit in scope is the repository's first commit.

```bash
scripts/non-interactive-git-rebase.sh <oldest-sha-in-scope>^ <<'PLAN'
pick abc1234 Keep this commit
squash def5678 Merge this into the previous
drop ghi9012 Remove this commit entirely
PLAN
```

### Edit

Mark the commit `edit` in the plan. Git pauses there. Then:

```bash
git add <files>
git commit --amend --no-edit
git rebase --continue
```

## Reword

```bash
scripts/reword-commit.sh --sha <sha> --message "New commit message"
```

## Todo Commands

| Command  | Effect                                       |
| -------- | -------------------------------------------- |
| `pick`   | Keep the commit as-is                        |
| `squash` | Merge into previous commit, combine messages |
| `fixup`  | Merge into previous commit, discard message  |
| `drop`   | Remove the commit from history               |
| `reword` | Keep changes, edit the commit message        |
| `edit`   | Pause rebase to amend the commit             |

## Conflicts and Recovery

- Resolve conflicts, stage files, then: `git rebase --continue`
- Abandon and restore original state: `git rebase --abort`

## Rationalizations

| Thought                                           | Reality                                                          |
| ------------------------------------------------- | ---------------------------------------------------------------- |
| "I can't do interactive rebase without a TTY"     | Use `scripts/non-interactive-git-rebase.sh` instead              |
| "I'll use HEAD~N as the upstream"                 | Use a SHA — HEAD~N is fragile and ambiguous                      |
| "I'll just --amend instead" (for an older commit) | `--amend` only works on the latest commit; use rebase for others |
| "I'll undo the commits and redo them one by one"  | Rebase rewrites history in one step — no need to redo commits    |
| "I'll create a new commit to fix it"              | That pollutes history; rebase is the right tool                  |
