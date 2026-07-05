---
description: Syncs a subset of the user's local tracked repositories.
disable-model-invocation: true
---

# Sync Repositories

## Process

1. **Prepare the repositories:** Run `./scripts/prepare-repositories.sh`. It records a parent branch for any checked-out feature branch that lacks one (so git-town can sync it) and prints one repository path per line.

2. **Sync each repository.** For each path it prints, `cd` into the repository and run `git town sync`. git-town rebases the checked-out branch onto the latest default branch and returns you to it.

3. **Resolve conflicts inline.** If `git town sync` pauses on a conflict, resolve the conflicting files by hand, preserving the intent of both sides. Then run `git town continue`, repeating until that repository's sync completes. Move on to the next repository.

## Rationalizations

| Thought                                        | Reality                                                                        |
| ---------------------------------------------- | ------------------------------------------------------------------------------ |
| "I'll `git town skip` past the conflict"       | Skip discards that branch's sync. Resolve the files, then `git town continue`. |
| "I'll `git town undo` for a clean slate"       | Undo throws the sync away. This skill resolves conflicts; it never backs out.  |
| "The conflict looks minor, I'll force past it" | Resolve every conflict by hand so both sides' intent survives.                 |
| "I'll skip a repository that looks messy"      | Sync every repository the prepare script prints.                               |
