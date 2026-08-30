---
description: Use when work belongs to a repository other than the one this session is in — turning a task just performed into a skill elsewhere, or propagating a change into a dependent repository — so an agent with that repository's context does it instead.
---

# Delegate

Hand a task to an agent running in another project. The point is context: an agent in the target repository already has its `AGENTS.md`, conventions, and layout, and will make a better change there than this session can.

## Choosing the Target

Run `herdr-project list` for the configured projects. Default to a fresh worktree so the work lands on its own branch. **REQUIRED:** Use the `ls-agent:open-workspace` skill; it returns the workspace id to send to.

Send to an already-running agent only when the user asks for it, or when the task needs that session's state. Find its workspace with `herdr agent list`, matching an agent's `cwd`: the project path for its main checkout, or `~/.herdr/worktrees/<project>/` for a worktree, whose last segment is the branch name slugified.

## Sending

```bash
scripts/prompt.sh --workspace <id> --prompt <text>
```

Single-quote the prompt. Delegated prompts are long and routinely contain backticks and `$`, which a double-quoted shell argument expands before the agent ever sees it.

This returns as soon as the prompt is delivered. A delegated task usually outlasts the turn that sent it, so waiting on it strands this session for nothing; the script's `--wait` flag is for the rare short task whose result decides what you do next. Run `--help` before using it.

## Writing the Prompt

The receiving agent has none of this conversation and cannot ask you anything. A prompt that says "turn what we just did into a skill" is worthless to it.

State, in the task's own terms:

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
| "I'll tighten up the task before sending it"   | Send it as given. Rewriting it loses what the user actually asked.        |
