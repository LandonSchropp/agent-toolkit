# Local Engineering

Local Engineering runs in Claude Code inside herdr, on the user's Mac. Each workspace is a full development environment over its own checkout, so it takes anything that edits a repository or needs to be talked to while it works.

## Choosing the Target

Default to a fresh worktree so the work lands on its own branch. Use the `ls-agent:open-workspace` skill; it returns the workspace id.

Send to an already-running agent only when the user asks, or when the task needs that session's state. Find its workspace with `herdr agent list`, matching an agent's `cwd`: the project path for its main checkout, or `~/.herdr/worktrees/<project>/` for a worktree, whose last segment is the branch name slugified. When the task names the workspace by its project, find it in `herdr workspace list` by its `tokens.project` instead. Look the workspace up each time, since workspace IDs change.

## Sending

Send the prompt with the `SendMessage` tool. It arrives labeled with this session's name, so the receiver knows another agent sent it. Get the receiving session's name from the workspace ID, then confirm `ListAgents` shows it:

```bash
scripts/session-name.sh --workspace <id>
```

The send returns as soon as the message is delivered. A delegated task usually outlasts the turn that sent it, so waiting strands this session for nothing. `notify_when_idle` is for the rare short task whose result decides what you do next.

A session in a different permission mode holds cross-session messages until the user approves them, and they can expire. When the send result or a later `[Cross-session delivery notice]` says the message was held, tell the user to approve it in that workspace.

When `session-name.sh` fails, `ListAgents` doesn't show its name, or the session refuses the message, print the prompt as a fenced code block for the user to carry over instead. Do the same off the Mac, as in Devin or a cloud session of Claude Desktop, where there is no route to herdr. `session-name.sh` reaches the running Herdr app over its socket from anywhere on the machine, so being outside Herdr on the Mac is fine.

## The Prompt

Tell the agent that the user did not read the prompt and that it should proceed on its best judgment, or it stalls waiting on an answer. Leave that out of a prompt the user carries over, since they will have read it.

Then, beyond what any delegation needs, tell the agent:

- To follow its own repository's conventions and review process rather than anything inferred from your prompt.
- To run `ls-agent:plan` before starting on the task, unless the task would fit in a single commit. Skip planning for those and implement directly.
