---
description: Use when work belongs to a repository other than the one this session is in — turning a task just performed into a skill elsewhere, or propagating a change into a dependent repository — so an agent with that repository's context does it instead.
---

# Delegate

Hand a task to an agent running in another project. The point is context: an agent in the target repository already has its `AGENTS.md`, conventions, and layout, and will make a better change there than this session can reach across and make.

## Choosing the Target

Run `herdr-project list` for the configured projects. Default to a fresh worktree so the work lands on its own branch. **REQUIRED:** Use the `ls-agent:open-workspace` skill; it returns the workspace id to send to.

Send to an already-running agent only when the user asks for it, or when the task needs that session's state. Find its workspace with `herdr agent list`: an agent's `cwd` is the project path in the main checkout, or a path under `~/.herdr/worktrees/<project>/` in one of its worktrees — match the project segment, since herdr slugifies the branch into the last one.

## Sending

```bash
scripts/prompt.sh --workspace <id> --prompt <text>
```

Single-quote the prompt. Delegated prompts are long and routinely contain backticks and `$`, which a double-quoted shell argument expands before the agent ever sees it.

This returns as soon as the prompt is delivered, which is what you want: a delegated task usually outlasts the turn that sent it, and waiting on it strands this session for nothing. The script's `--wait` flag exists for the rare short task whose result decides what you do next. Run it with `--help` before using it.

## Writing the Prompt

The receiving agent has none of this conversation and cannot ask you about it, so everything it needs has to be in the prompt text. **REQUIRED:** Use the `ls-agent:orchestrate` skill for what that means in practice.

## Rationalizations

| Thought                                        | Reality                                                                   |
| ---------------------------------------------- | ------------------------------------------------------------------------- |
| "It's a two-line change, I'll just do it here" | Then it lands without the target repository's conventions. Delegate it.   |
| "I'll reference what we just did"              | The receiving agent was not here. Spell it out.                           |
| "I'll reuse the running agent, it's faster"    | A fresh worktree keeps the work on its own branch. Reuse only when asked. |
| "I'll wait so I can report back what happened" | Delegated work outlasts your turn. Send it and move on.                   |
