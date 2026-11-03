# Pull Requests to Merge

Hand each pull request back to the session that wrote it, which babysits it to merge. Route only the pull requests you were given, and leave draft pull requests alone.

For each pull request:

1. **Find the session that created it:** Skip the pull request when `gh pr view <url> --json isDraft` says it's a draft. Otherwise, run `scripts/find-pull-request-session.sh --pull-request-url <url>`. It prints the session, the directory and branch it started in, and the workspace and pane when they're open. Never search for sessions that merely mention the URL, since many unrelated ones do. One session often owns a whole stack, so route each session once with all of its pull requests. When the script prints nothing, no session created it. Open a workspace on the pull request's head branch (`gh pr view <url> --json headRefName`) in step 2, and skip the resume.
2. **Reuse its workspace:** When `pane` is set, the session is still running there, so skip to step 3. When only `workspace` is set, resume the session in that workspace's agent. Otherwise, **REQUIRED:** use the `ls-agent:open-workspace` skill to reopen the workspace on the session's `branch`, which recreates the worktree if it was removed, then resume the session in its agent. That's the branch the session started on, which can differ from the pull request's head branch or even its repository. When `directory` still exists but is on another branch or a detached HEAD, switch it back with `git -C <directory> switch <branch>` before reopening it, and ask the user first if it has uncommitted changes. Never resume a session in a plain workspace, since it wouldn't get the project's tabs. Resume with `herdr agent prompt <pane> "/resume <session>"`, finding a workspace's pane with `herdr agent list`.
3. **Unpark it:** **REQUIRED:** Use the `herdr-group` skill to unpark the workspace if it's parked.
4. **Hand it the pull requests:** Prompt the session to invoke the `ls-git:babysit` skill on its pull requests. Include what it can't know on its own: other workspaces that share ground with it, whose repositories it shouldn't change, and anything that changed since its last turn, such as a fix that merged into main.

## Rationalizations

| Thought                                           | Reality                                                                   |
| ------------------------------------------------- | ------------------------------------------------------------------------- |
| "A session that mentions the URL is close enough" | Many sessions mention it. Only the one that created it owns it.           |
| "A plain workspace is faster to open"             | It lacks the project's tabs. Reopen through `ls-agent:open-workspace`.    |
| "A fresh session will figure it out"              | The session that wrote it has the context. Resume it whenever one exists. |
| "The draft is in the stack, so babysit it too"    | Drafts aren't ready. Leave them alone.                                    |
