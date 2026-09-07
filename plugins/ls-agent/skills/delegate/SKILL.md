---
name: delegate
description: Use when work belongs somewhere other than this session: a different repository, an asynchronous task queue, or a visual design tool, so an agent with the right environment and context does it instead.
---

# Delegate

Hand a task to an agent better placed to do it. Choose the platform first; it decides everything else.

## Choosing the Platform

- **Herdr:** The task edits a local repository, or otherwise needs a development environment and a live chat interface. `herdr-project list` names the repositories; most of them live under `~/Development`. See [Herdr](references/herdr.md).
- **Multica:** The task edits no repository and needs no live chat. It runs asynchronously and reaches the user at touch points it schedules. See [Multica](references/multica.md).
- **Claude Design:** The task is visual design. See [Claude Design](references/claude-design.md).

Route by the task, never by where this session happens to be running. `$HERDR_ENV` and `$MULTICA_AGENT_ID` say which platform you are on, which changes how you reach a target and how you reach the user, never which target gets the task.

## Writing the Prompt

The receiving agent has none of this conversation, and nothing it replies reaches you. A prompt saying "turn what we just did into a skill" is worthless to it. State, in the task's own terms:

- What the task is, in full. Where it came from a Linear issue, give the issue's URL rather than repeating its contents.
- What already happened that the agent needs to know, and where: repository, files, commits.
- What you have and have not already changed yourself, so it doesn't redo or undo work.

Pass the task through as the user gave it. Don't reinterpret it, improve it, or decide it needs less than it asks for. Each platform's reference adds what its own prompts need on top of this.

## Rationalizations

| Thought                                           | Reality                                                                           |
| ------------------------------------------------- | --------------------------------------------------------------------------------- |
| "It's a two-line change, I'll just do it here"    | Then it lands without the target's conventions. Delegate it.                      |
| "It's research, so it needs a workspace"          | It edits no repository. Multica runs it without tying up a checkout.              |
| "They edited the Multica draft, so it's approved" | An edit is feedback, not consent. Show the revision and wait.                     |
| "The CLI has no label flag on create, so skip it" | It is how the user finds delegated work. Attach it after the create.              |
| "I'll run the `design` skill instead"             | It is the smaller preview. Claude Design work goes to claude.ai/design.           |
| "I'll reference what we just did"                 | The receiving agent was not here. Spell it out.                                   |
| "I'll reuse the running agent, it's faster"       | A fresh worktree keeps the work on its own branch. Reuse only when asked.         |
| "I'll paste in the Linear issue's description"    | Give the URL. The agent reads the issue itself; the issue is the source of truth. |
