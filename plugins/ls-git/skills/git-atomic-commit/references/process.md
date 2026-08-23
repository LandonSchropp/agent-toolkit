# Process

This guide explains how to split changes into atomic commits optimized for reviewability.

## Step 1: Propose a Commit Plan

Read the working tree and current branch before doing anything:

```bash
git status
git diff
scripts/show-stack-commits.sh
```

`show-stack-commits.sh` prints commits unique to the current branch compared with the default branch.

Group hunks by logical intent. For each group, decide:

- New commit: a net-new logical change. Identify the branch it should land on.
- Edit a prior commit: a fix, polish, or completion of work already committed. Identify the target SHA and the branch it lives on.

**Reviewability check:** Estimate the size of each commit (roughly by line count). If a commit exceeds 200–400 lines of changes, plan to split it further. Each commit should tell one story clearly enough that a reviewer can follow it without context-switching.

Present the plan to the user as a table and wait for confirmation before executing. Keep the table succinct — shorten branch names, commit messages, and descriptions where needed to keep rows scannable. Example:

| #   | Action | SHA       | Branch         | Message                | Description                     | Est. Size |
| --- | ------ | --------- | -------------- | ---------------------- | ------------------------------- | --------- |
| 1   | Edit   | `abc1234` | `ex-123-base`  | Add auth middleware    | Error handling in auth.ts:45-60 | ~80 LOC   |
| 2   | New    | —         | `ex-456-child` | Update onboarding docs | README and docs/onboarding.md   | ~150 LOC  |
| 3   | New    | —         | `ex-456-child` | Fix typo in user model | user.ts:120 comment             | ~5 LOC    |

If any planned commit looks large (> 400 LOC), discuss with the user: "Commit #2 is estimated at 300+ LOC. Should we split this further for easier review?"

## Step 2: Edits to Prior Commits

Stage only the hunks belonging to the edit using the techniques in Step 3 and Step 4. **REQUIRED:** Invoke the `ls-git:git-edit-commit` skill and follow its instructions to edit existing commits.

If the target commit lives on a different branch, stash the staged hunks (`git stash push --staged`), check out that branch, restore the stash, then invoke the `ls-git:git-edit-commit` skill there. After editing, return to the original branch and rebase dependent branches as needed.

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
3. Use `Edit` to apply ONLY the changes for the current commit. Reference `/tmp/file.ts.full` to see what to add. **Reviewability tip:** Include related changes that belong in this commit's narrative, even if scattered across the file. For example, if this commit adds a new function, also include a test for it and a docstring, even if they're in separate locations—they're all part of "adding this feature."
4. Stage and commit. **REQUIRED:** Use the `ls-git:git-commit` skill.
5. Before committing, check the size: `git diff --cached --stat`. If it exceeds 400 LOC, reconsider splitting further.
6. Repeat step 3–5 for each intermediate commit.
7. For the final commit, restore the full working version and commit:
   ```bash
   cp /tmp/file.ts.full path/to/file.ts
   git add path/to/file.ts
   ```
8. Verify nothing was lost. The diff should be empty:
   ```bash
   diff path/to/file.ts /tmp/file.ts.full
   ```

## Step 4: Split Across Separate Files

Stage selectively per commit. **REQUIRED:** Use the `ls-git:git-commit` skill for each.

```bash
git add path/to/first.ts path/to/second.ts
# commit
git add path/to/third.ts
# commit
```

After staging each set, check the size: `git diff --cached --stat`. Commits over 400 LOC are harder to review and increase the risk of bugs slipping through. If in doubt, split further—reviewers will thank you.
