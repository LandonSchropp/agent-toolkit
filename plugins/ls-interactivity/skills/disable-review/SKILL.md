---
name: disable-review
description: Temporarily turn off the requirement that pending changes be reviewed before committing in the current herdr workspace.
disable-model-invocation: true
---

# Disable Review

Run `scripts/disable-review.sh`. It turns off the commit review requirement for the current herdr workspace for one hour.

Only the requirement for review is lifted. Commits no longer need a review, but whenever the user wants to review something, such as a diff, pull request, or plan, still open it with the `ls-interactivity:interactive-review` skill.
