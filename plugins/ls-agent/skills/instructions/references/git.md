# Git

## Working Directory

- The session's primary working directory is the source of truth for which checkout to edit. When a repository is checked out in multiple places, such as a dedicated worktree alongside another clone, always edit the copy under the current working directory.
- Never navigate to a same-named checkout elsewhere on disk (for example `~/Development/<repo>`) to make changes. Resolve repository-relative paths against the working directory.

## Branches

- A repository is personal when its `origin` remote is under the user's `LandonSchropp` GitHub account, or when it has no remote at all. Every other repository is a work repository.
- In a personal repository, default to working directly on `main` instead of creating a feature branch.
- Work repositories always use a feature branch.
- In a linked worktree, stay on the worktree's own branch, even in a personal repository.

## Pushing

Push after committing: always on a feature branch, and on `main` only in personal repositories. Never push directly to `main` in a work repository.

## Rationalizations

| Thought                                     | Reality                                                                      |
| ------------------------------------------- | ---------------------------------------------------------------------------- |
| "The other checkout is the real repository" | The working directory is the one to edit. Stay in it.                        |
| "A feature branch is always safer"          | Personal repositories default to `main`, unless you're in a linked worktree. |
