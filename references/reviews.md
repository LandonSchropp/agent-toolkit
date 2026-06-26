## Overview

Every commit is reviewed before it is created. Present each commit's changes for review and create the commit only after the user signs off. Drive the review yourself.

## The Process

1. **REQUIRED:** Invoke the `git-atomic-commit` skill before making changes, and follow its guidance. Group the work into atomic commits.
2. Work one commit at a time. Keep your changes scoped to the single commit you're building.
3. Present the changes for review. **REQUIRED:** Invoke the `interactive-review` skill in `working` mode.
4. If the user leaves feedback, address every point, then ask whether they'd like to re-review or commit. If they want another look, return to step 3.
5. Once the user is ready, create the commit. **REQUIRED:** Use the `git-commit` skill.
6. Repeat for the next commit.

## Staying In Scope

Don't edit files outside the scope of the commit you're building. If you unavoidably touch unrelated files and they don't overlap with the current commit's files, review and commit each separately — one review, one commit, at a time. Never bundle unreviewed changes into a reviewed commit.

## Rationalizations

| Thought                                     | Reality                                                |
| ------------------------------------------- | ------------------------------------------------------ |
| "This change is trivial, skip the review"   | Every commit is reviewed. Present it.                  |
| "I'll commit now and let them review after" | Review comes before the commit. Present first.         |
| "No feedback last time, so skip it now"     | A new change is a new review. Present it.              |
| "I'll commit everything in one go"          | One atomic commit at a time, each reviewed separately. |
