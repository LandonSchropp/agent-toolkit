# Process

This guide explain how to split changes into atomic commits.

## Step 1: Propose a Commit Plan

Read the working tree and the branch stack before doing anything:

```bash
git status
git diff
scripts/show-stack-commits.sh
```

`show-stack-commits.sh` walks up the git-town parent chain and prints commits unique to each branch in the stack. A change in the working tree might belong to a commit on a parent branch, not just the current one.

Group hunks by logical intent. For each group, decide:

- New commit: a net-new logical change. Identify the branch it should land on.
- Edit a prior commit: a fix, polish, or completion of work already committed. Identify the target SHA and the branch it lives on.

Present the plan to the user as a table and wait for confirmation before executing. Keep the table succinct — shorten branch names, commit messages, and descriptions where needed to keep rows scannable. Example:

| #   | Action | SHA       | Branch         | Message                | Description                     |
| --- | ------ | --------- | -------------- | ---------------------- | ------------------------------- |
| 1   | Edit   | `abc1234` | `ex-123-base`  | Add auth middleware    | Error handling in auth.ts:45-60 |
| 2   | New    | —         | `ex-456-child` | Update onboarding docs | README and docs/onboarding.md   |
| 3   | New    | —         | `ex-456-child` | Fix typo in user model | user.ts:120 comment             |

## Step 2: Edits to Prior Commits

Stage only the hunks belonging to the edit using the techniques in Step 3 and Step 4. **REQUIRED:** Invoke the `git-edit-commit` skill and follow its instructions to edit existing commits.

If the target commit lives on a different branch in the stack, stash the staged hunks (`git stash push --staged`), check out that branch, restore the stash, then invoke the `git-edit-commit` skill there. After editing, return to the original branch and run `git town sync` so downstream branches pick up the change.

## Step 3: Split Within a Single File

Agents can't use `git add -p` to interactively stage hunks (it requires a TTY). When multiple commits draw from the same file, use restore-and-replay instead:

1. Save the full working version:
   ```bash
   cp path/to/file.ts /tmp/file.ts.full
   ```
2. Restore the file to HEAD:
   ```bash
   git restore path/to/file.ts
   ```
3. Use `Edit` to apply ONLY the changes for the current commit. Reference `/tmp/file.ts.full` to see what to add.
4. Stage and commit. **REQUIRED:** Use the `git-commit` skill.
5. Repeat step 3 and 4 for each intermediate commit.
6. For the final commit, restore the full working version and commit:
   ```bash
   cp /tmp/file.ts.full path/to/file.ts
   git add path/to/file.ts
   ```
7. Verify nothing was lost. The diff should be empty:
   ```bash
   diff path/to/file.ts /tmp/file.ts.full
   ```

## Step 4: Split Across Separate Files

Stage selectively per commit. **REQUIRED:** Use the `git-commit` skill for each.

```bash
git add path/to/first.ts path/to/second.ts
# commit
git add path/to/third.ts
# commit
```
