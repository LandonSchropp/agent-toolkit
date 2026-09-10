# Herdr

Each workspace is a full development environment over its own checkout, so Herdr takes anything that edits a repository or needs to be talked to while it works.

## Choosing the Target

`herdr-project list` shows the configured projects. Default to a fresh worktree so the work lands on its own branch. **REQUIRED:** Use the `ls-agent:open-workspace` skill; it returns the workspace id.

Send to an already-running agent only when the user asks, or when the task needs that session's state. Find its workspace with `herdr agent list`, matching an agent's `cwd`: the project path for its main checkout, or `~/.herdr/worktrees/<project>/` for a worktree, whose last segment is the branch name slugified.

## Sending

```bash
scripts/prompt.sh --workspace <id> --prompt <text>
```

Single-quote the prompt. Prompts routinely contain backticks and `$`, which a double-quoted argument expands before the agent sees it.

This returns as soon as the prompt is delivered. A delegated task usually outlasts the turn that sent it, so waiting strands this session for nothing; `--wait` is for the rare short task whose result decides what you do next. Run `--help` on it first.

Nothing about this path depends on being inside Herdr. Both commands drive the running Herdr app over its socket from anywhere on the machine. `herdr` needs only that the app is running; `herdr-project` additionally needs `bun` on the `PATH`.

## The Prompt

Open by naming where the prompt came from, or it reads as the user speaking and stalls waiting on an answer:

> This comes from an agent working in `<project>`, sent through `ls-agent:delegate`. The user did not read this prompt, so proceed on your best judgment.

Then, beyond what any delegation needs, tell the agent:

- To follow its own repository's conventions and review process rather than anything inferred from your prompt.
- To run `ls-agent:plan` before starting on the task.
