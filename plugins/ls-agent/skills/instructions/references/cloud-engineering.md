# Cloud Engineering

You're running in Devin, in the cloud. This environment owns well-defined engineering in work repositories whose success can be verified without the user's judgment: migrations, upgrades, refactors, CI failures, reproducible bugs, tests and documentation.

Personal engineering, work that needs the user's judgment as it goes (naming, UX, architecture being designed in real time), the user's notes and non-engineering work mostly belong elsewhere. A task can still need a little of them along the way; handle that much, and flag anything bigger to the user.

## Reviews

The user reviews twice: the plan, then the pull request. Unlike Local Engineering, nobody reviews individual commits, so don't stop between them; all of the review happens on the pull request.

1. Unless the prompt already hands you a plan, such as one from a coordinating session or the Linear issue, **REQUIRED:** invoke the `ls-agent:plan` skill, and wait for the user to approve the plan.
2. Build the work following [Commits](commits.md). Pre-review is its only review step here. If there's no subagent tool to hand pre-review's checks to, run them yourself.
3. Push the feature branch and open a pull request.

## Multiple Pull Requests

One session owns at most one pull request. When the work needs more than one, this session coordinates and doesn't implement any of it:

1. **REQUIRED:** Invoke the `ls-agent:parallelize` skill to sort the work into stages.
2. Start a child session for every ready task in the stage at once, one pull request each.
3. Wait for the children to archive. A child archiving means its pull request merged and its task is done. Until then, stay quiet: don't message the user as children start, progress or report back, unless one is blocked on a decision only the user can make.
4. Once a stage's children have all archived, start the next stage, and tell its children what the earlier stages landed.

## Archiving

When this session's only pull request has merged, archive this session. A coordinating session archives itself once every child has archived and no work is left. Never archive a session that has an open pull request.

## Rationalizations

| Thought                                          | Reality                                                       |
| ------------------------------------------------ | ------------------------------------------------------------- |
| "Two pull requests is manageable in one session" | It isn't to the user. Start a child session per pull request. |
| "It's a small task, I'll do it while I wait"     | A coordinating session never implements. Hand it to a child.  |
| "I'll leave the session open in case"            | A merged pull request ends the session. Archive it.           |
| "I'll tell the user the children have started"   | A message nobody has to act on is noise. Stay quiet.          |
