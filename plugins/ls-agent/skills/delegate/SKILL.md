---
description: Use when work belongs to a repository other than the one this session is in — turning a task just performed into a skill elsewhere, or propagating a change into a dependent repository — so an agent with that repository's context does it instead.
---

# Delegate

Hand a task to an agent in another project. It has that repository's `AGENTS.md`, conventions, and layout, and will make a better change than this session can.

## Choosing the Target

`herdr-project list` shows the configured projects. Default to a fresh worktree so the work lands on its own branch. **REQUIRED:** Use the `ls-agent:open-workspace` skill; it returns the workspace id.

Send to an already-running agent only when the user asks, or when the task needs that session's state. Find its workspace with `herdr agent list`, matching an agent's `cwd`: the project path for its main checkout, or `~/.herdr/worktrees/<project>/` for a worktree, whose last segment is the branch name slugified.

## Sending

```bash
scripts/prompt.sh --workspace <id> --prompt <text>
```

Single-quote the prompt — prompts routinely contain backticks and `$`, which a double-quoted argument expands before the agent sees it.

This returns as soon as the prompt is delivered. A delegated task usually outlasts the turn that sent it, so waiting strands this session for nothing; `--wait` is for the rare short task whose result decides what you do next. Run `--help` on it first.

## Writing the Prompt

The receiving agent has none of this conversation, and nothing it replies reaches you. A prompt saying "turn what we just did into a skill" is worthless to it.

Open by naming where the prompt came from, or it reads as the user speaking and stalls waiting on an answer:

> This comes from an agent working in `<project>`, sent through `ls-agent:delegate`. The user is not reading this channel, so proceed on your best judgment rather than waiting for a reply.

Then state, in the task's own terms:

- What the task is, in full. Where it came from a Linear issue, include the issue and its description rather than the title.
- What already happened that the agent needs to know, and where — repository, files, commits.
- What you have and have not already changed yourself, so it doesn't redo or undo work.
- That it should follow its own repository's conventions and review process rather than anything inferred from your prompt.

Pass the task through as the user gave it. Don't reinterpret it, improve it, or decide it needs less than it asks for.

## Rationalizations

| Thought                                        | Reality                                                                   |
| ---------------------------------------------- | ------------------------------------------------------------------------- |
| "It's a two-line change, I'll just do it here" | Then it lands without the target repository's conventions. Delegate it.   |
| "I'll reference what we just did"              | The receiving agent was not here. Spell it out.                           |
| "I'll reuse the running agent, it's faster"    | A fresh worktree keeps the work on its own branch. Reuse only when asked. |
