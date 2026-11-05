---
name: babysit
description: Use when a session has opened its pull requests or posted them for review, whether one or a whole stack, and they need to be carried through feedback, CI and review to merge, or when the orchestrator tells a session to babysit its pull requests.
---

# Babysit

Carry this workspace's pull requests to merge. Babysit only the pull requests this session opened or was handed. Leave draft pull requests alone.

The workspace stays open the whole time. Never close it while any of its pull requests is still open.

## Start

1. **REQUIRED:** Use the `herdr-group` skill to move the workspace to In Review.
2. Register every pull request, even one you think is already registered. (Adding pull requests is idempotent.)

   ```bash
   herdr-pull-request-status add --workspace "$HERDR_WORKSPACE_ID" --url <url>
   ```

## Watch

Run `herdr-pull-request-status watch --workspace "$HERDR_WORKSPACE_ID"` with the `Monitor` tool, at its longest timeout. It prints a JSON line for each pull request when it starts, and another whenever one changes. It exits once every pull request has merged or closed. Re-arm it each time it expires. Don't poll GitHub yourself.

Handle each line by its `feedback` and `status`:

- **Feedback:** Whenever `feedback` isn't empty, whatever the status, **REQUIRED:** use the `ls-git:pull-request-feedback` skill to work through it. Optional and nit comments are real feedback, since the user may want to address them.
- **CI failed:** Open each of the `failingChecks` URLs, find the cause and fix it. If the failure is flaky, rerun it with `gh run rerun --failed`.
- **Merge conflicts:** Update the branch onto its parent. For a stack, **REQUIRED:** use the `ls-git:stacked-pull-requests` skill to sync it.
- **Ready to merge:** See [Merging](#merging).
- **Merged or closed:** Once every pull request is, offer to close the workspace. On approval, **REQUIRED:** use the `ls-agent:close-workspace` skill to close it.
- **Anything else:** Waiting for CI, review or the merge queue resolves on its own.

## Merging

Ask the user once per stack, the first time one of its pull requests is ready to merge. After that, merge each pull request as it becomes ready, without asking again.

Merge in dependency order. A pull request that depends on another one waits until that one merges, even when the other one is in a different repository. `watch` reports it as merged. When it has to deploy first, ask the user to confirm the deploy.

**REQUIRED:** Use the `ls-git:stacked-pull-requests` skill to merge a stack, and the `ls-git:merge-pull-request` skill to merge a single pull request.

## Rationalizations

| Thought                                               | Reality                                                            |
| ----------------------------------------------------- | ------------------------------------------------------------------ |
| "The status is ready, so the feedback can wait"       | Unanswered feedback gets handled first, whatever the status says.  |
| "It's only a nit"                                     | Nits are real feedback. Show them to the user.                     |
| "This workspace already registered its pull requests" | Registering again is harmless. A reopened workspace has none.      |
| "I'll check `gh pr view` while I wait"                | `watch` already reports every change. Let it tell you.             |
| "It's ready, I'll merge the next one too"             | Merge in order. A dependent pull request waits for its dependency. |
