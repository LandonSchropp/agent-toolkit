---
name: delegate
description: Use when work belongs somewhere other than this session (a different repository, a standing personal agent, or a visual design tool), or before creating or changing a skill, to decide where it lives.
---

# Delegate

Hand a task to an agent better placed to do it. Choose the platform first; it decides everything else.

## Choosing the Platform

- **Herdr:** The task edits a local repository, or otherwise needs a development environment. `herdr-project list` names the repositories; most of them live under `~/Development`. See [Herdr](references/herdr.md).
- **OpenClaw:** The task edits no repository and needs no development environment. It belongs to the standing personal agent whose domain it falls in, which keeps the context and follows up on its own schedule. See [OpenClaw](references/openclaw.md).
- **Claude Design:** The task is visual design. See [Claude Design](references/claude-design.md).

Route by the task, never by where this session happens to be running. `$HERDR_ENV` says whether you are in Herdr or a general-purpose agent, which changes how you reach a target and how you reach the user, never which target gets the task.

## Skills

A skill that lives in a repository goes to Herdr: the one it is already in, `personal-agent-toolkit` when it is personal, and `agent-toolkit` otherwise. OpenClaw's own skills are a separate ecosystem, built and maintained there rather than delegated. See [OpenClaw](references/openclaw.md#skills).

## Writing the Prompt

The receiving agent has none of this conversation, and nothing it replies reaches you. A prompt saying "turn what we just did into a skill" is worthless to it. State, in the task's own terms:

- What the task is, in full. Where it came from a Linear issue, give the issue's URL rather than repeating its contents.
- What already happened that the agent needs to know, and where: repository, files, commits.
- What you have and have not already changed yourself, so it doesn't redo or undo work.

Pass the task through as the user gave it. Don't reinterpret it, improve it, or decide it needs less than it asks for. Each platform's reference adds what its own prompts need on top of this.

## Telling the User

Delegation is final. Say what was sent and where, then stop — never tell the user the agent will "report back" or "let you know" when it's done. Nothing it does flows back through this session; the user checks its progress by watching its own workspace or session directly.

## Rationalizations

| Thought                                        | Reality                                                                           |
| ---------------------------------------------- | --------------------------------------------------------------------------------- |
| "It's a two-line change, I'll just do it here" | Then it lands without the target's conventions. Delegate it.                      |
| "It's research, so it needs a workspace"       | It edits no repository. An OpenClaw agent runs it without tying up a checkout.    |
| "I'll wait for the agent's turn to finish"     | The turn is the agent's, and its reply is the user's. Send it and move on.        |
| "I'll run the `design` skill instead"          | It is the smaller preview. Claude Design work goes to claude.ai/design.           |
| "I'll reference what we just did"              | The receiving agent was not here. Spell it out.                                   |
| "I'll reuse the running agent, it's faster"    | A fresh worktree keeps the work on its own branch. Reuse only when asked.         |
| "I'll paste in the Linear issue's description" | Give the URL. The agent reads the issue itself; the issue is the source of truth. |
| "The skill is for one OpenClaw agent"          | It still lives in a repository, so it still goes to Herdr.                        |
| "I'll say it'll report back when it's done"    | Delegation is final. Nothing reaches this session; the user checks the workspace. |
