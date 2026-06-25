---
description: Use when a skill needs the user to interactively review code changes in revdiff mid-workflow — working changes, staged changes, or a specific commit — then read their annotations back. Takes a review mode.
user-invocable: false
---

# Interactive Review

**REQUIRED:** Use the `interactive-command` skill, running `scripts/review.sh <mode> [<sha>] --output <file>` with `Review` as the window name.

Create an empty scratch file first and pass it as `--output`. When the window closes, `<file>` holds the user's review annotations — read it back and continue. The modes are `working`, `staged`, and `commit <sha>`; run `scripts/review.sh --help` for details.
