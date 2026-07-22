## Overview

Every commit is reviewed before it is created. Present each commit's changes for review and create the commit only after the user signs off. Drive the review yourself.

The `interactive-review` skill's own exit code is the approve/deny decision: 0 means the user approved, nonzero means they denied. That's the only signal that matters — never ask the user whether they're ready to commit or want another look. A commit hook also blocks `git commit` until an approved review is on record, as a backstop, but don't rely on hitting it to find out the answer; read the skill's exit code directly.

## The Process

1. **REQUIRED:** Invoke the `git-atomic-commit` skill before making changes, and follow its guidance. Group the work into atomic commits.
2. Work one commit at a time. Keep your changes scoped to the single commit you're building.
3. Present the changes for review. **REQUIRED:** Invoke the `interactive-review` skill in `working` mode.
4. Check its exit code. Nonzero means denied: address every point of feedback left in the annotations, then return to step 3 to re-review — don't attempt the commit first. Zero means approved: continue to step 5.
5. Create the commit. **REQUIRED:** Use the `git-commit` skill.
6. Repeat for the next commit.

## Staying In Scope

Don't edit files outside the scope of the commit you're building. If you unavoidably touch unrelated files and they don't overlap with the current commit's files, review and commit each separately — one review, one commit, at a time. Never bundle unreviewed changes into a reviewed commit.

## Rationalizations

| Thought                                     | Reality                                                   |
| ------------------------------------------- | --------------------------------------------------------- |
| "I'll ask if they're ready to commit"       | The exit code already answered that. Read it, don't ask.  |
| "I'll ask if they want to re-review"        | Nonzero exit already answered that. Re-review, don't ask. |
| "This change is trivial, skip the review"   | Every commit is reviewed. Present it.                     |
| "I'll commit now and let them review after" | Review comes before the commit. Present first.            |
| "No feedback last time, so skip it now"     | A new change is a new review. Present it.                 |
| "I'll commit everything in one go"          | One atomic commit at a time, each reviewed separately.    |
