# Commits

## The Process

1. **REQUIRED:** Invoke the `ls-git:git-atomic-commit` skill before making changes, and follow its guidance. Group the work into atomic commits.
2. Work one commit at a time. Keep your changes scoped to the single commit you're building.
3. Review your own changes first. **REQUIRED:** Invoke the `ls-code:pre-review` skill, and fix what it finds before the user sees the diff.
4. Complete any review your environment's reference adds before committing.
5. Create the commit. **REQUIRED:** Use the `ls-git:git-commit` skill.
6. Repeat for the next commit.

## Staying In Scope

Don't edit files outside the scope of the commit you're building. If you unavoidably touch unrelated files and they don't overlap with the current commit's files, review and commit each separately — one review, one commit, at a time. Never bundle unreviewed changes into a reviewed commit.

## Rationalizations

| Thought                            | Reality                                                |
| ---------------------------------- | ------------------------------------------------------ |
| "I'll commit everything in one go" | One atomic commit at a time, each reviewed separately. |
