# Cloud Engineering

You're running in Devin, in the cloud. This environment owns well-defined engineering in work repositories whose success can be verified without the user's judgment: migrations, upgrades, refactors, CI failures, reproducible bugs, tests and documentation.

Personal engineering, work that needs the user's judgment as it goes (naming, UX, architecture being designed in real time), the user's notes and non-engineering work mostly belong elsewhere. A task can still need a little of them along the way; handle that much, and flag anything bigger to the user.

## Reviews

The user reviews twice: the plan, then the stack's pull requests. Unlike Local Engineering, nobody reviews individual commits, so don't stop between them; all of the review happens on the pull requests.

1. Unless the prompt already hands you a plan, such as one from a coordinating session or the Linear issue, **REQUIRED:** invoke the `ls-agent:plan` skill, and wait for the user to approve the plan.
2. Build the work following [Commits](commits.md). Pre-review is its only review step here. If there's no subagent tool to hand pre-review's checks to, run them yourself.
3. Push the feature branch and open the stack's pull requests.

## Stacks

One session owns one stack. A stack is a single pull request, or several that have to land in order because each builds on the one before. Stack only work that can't be parallelized, and build stacks with Devin's own stacked pull requests, not the `ls-git:stacked-pull-requests` skill.

When the work needs more than one stack, this session coordinates and doesn't implement any of it:

1. **REQUIRED:** Invoke the `ls-agent:parallelize` skill to sort the work into stages, treating each chain of pull requests that must land in order as a single task: one stack.
2. Start a child session for every ready stack in the stage at once.
3. Wait for the children to archive. A child archiving means its stack merged. Until then, stay quiet: don't message the user as children start, progress or report back, unless one is blocked on a decision only the user can make.
4. Once a stage's children have all archived, start the next stage, and tell its children what the earlier stages landed.

## Archiving

When every pull request in this session's stack has merged, archive this session. A coordinating session archives itself once every child has archived and no work is left. Never archive a session that has an open pull request.

## Rationalizations

| Thought                                          | Reality                                                       |
| ------------------------------------------------ | ------------------------------------------------------------- |
| "These two stacks are manageable in one session" | They aren't to the user. Start a child session per stack.     |
| "I'll stack these to keep them together"         | Independent work runs in parallel. Stack only what must wait. |
| "It's a small task, I'll do it while I wait"     | A coordinating session never implements. Hand it to a child.  |
| "I'll leave the session open in case"            | A merged stack ends the session. Archive it.                  |
| "I'll tell the user the children have started"   | A message nobody has to act on is noise. Stay quiet.          |
