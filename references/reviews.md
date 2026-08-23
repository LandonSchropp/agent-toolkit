## Overview

Every commit needs explicit user approval before it is created. The approval requirement is a bright line: the user MUST say exactly `approve` or `approved`, ignoring case and allowing surrounding whitespace, before the agent commits.

No other acknowledgement counts. Do not accept "yes", "ok", "looks good", "ship it", implied consent, silence, prior approval for a plan, or any longer phrase as approval to commit.

## The Process

1. **REQUIRED:** Invoke the `ls-git:git-atomic-commit` skill before making changes, and follow its guidance. Group the work into atomic commits.
2. Work one commit at a time. Keep your changes scoped to the single commit you're building.
3. Review your own changes first. **REQUIRED:** Invoke the `ls-code:pre-review` skill, and fix what it finds before the user sees the diff.
4. Ask the user for approval to commit.
5. If the user says "approve" or "approved", ignoring case, create the commit. **REQUIRED:** Use the `ls-git:git-commit` skill.
6. If the user does not say "approve" or "approved", ignoring case, **do not commit**. Address feedback or wait for the user.
7. Repeat for the next commit.

## Staying In Scope

Don't edit files outside the scope of the commit you're building. If you unavoidably touch unrelated files and they don't overlap with the current commit's files, review and commit each separately — one review, one commit, at a time. Never bundle unreviewed changes into a reviewed commit.

## Rationalizations

| Thought                                     | Reality                                                                         |
| ------------------------------------------- | ------------------------------------------------------------------------------- |
| "They approved the plan"                    | Plan approval is not commit approval. Ask again.                                |
| "They said it looks good"                   | Only an exact `approve` or `approved` response permits a commit, ignoring case. |
| "This change is trivial, skip approval"     | Every commit needs explicit approval first.                                     |
| "I'll commit now and let them review after" | Approval comes before the commit. Present first.                                |
| "No feedback last time, so skip it now"     | A new change needs new approval.                                                |
| "I'll commit everything in one go"          | One atomic commit at a time, each approved separately.                          |
