---
name: delegate
description: Use when work belongs somewhere other than this session (a different repository, another environment, or a visual design tool), or before creating or changing a skill, to decide where it lives.
---

# Delegate

Hand a task to the environment best placed to do it. Choose the environment first; it decides everything else.

## Choosing the Environment

Answer these in order and stop at the first that decides it:

1. **Is it engineering?** If not, it goes to [Non-Engineering](references/non-engineering.md). Visual design is Non-Engineering work done in [Claude Design](references/claude-design.md).
2. **Is it personal engineering?** It goes to [Local Engineering](references/local-engineering.md), since Cloud Engineering only takes work. `is-work-computer` tells you which machine you're on.
3. **Can success be verified without the user's judgment?** If so, and it doesn't need the user's Mac, it goes to [Cloud Engineering](references/cloud-engineering.md). If it needs the Mac, the development environment, or the user's judgment as it goes (naming, UX, architecture designed in real time), it goes to [Local Engineering](references/local-engineering.md).

Route by the task, never by where this session happens to be running. Your own environment changes how you reach a target, never which target gets the task. When the questions don't settle it, ask the user.

## Skills

A skill that lives in a repository goes to Local Engineering: the one it is already in, or else `personal-agent-toolkit` when it's personal, `agent-toolkit` when it's the user's own engineering tooling, and `babylist/claude-plugins` when it's for work. Non-Engineering's own skills are built and maintained there rather than delegated.

## Writing the Prompt

The receiving agent has none of this conversation, and nothing it replies reaches you. A prompt saying "turn what we just did into a skill" is worthless to it. State, in the task's own terms:

- What the task is, in full. Where it came from a Linear issue, give the issue's URL rather than repeating its contents.
- What already happened that the agent needs to know, and where: repository, files, commits.
- What you have and have not already changed yourself, so it doesn't redo or undo work.

Pass the task through as the user gave it. Don't reinterpret it, improve it, or decide it needs less than it asks for. Each environment's reference adds what its own prompts need on top of this.

## Telling the User

Delegation is final. Say what was sent and where, then stop — never tell the user the agent will "report back" or "let you know" when it's done. Nothing it does flows back through this session; the user checks its progress by watching its own workspace or session directly.

## Rationalizations

| Thought                                        | Reality                                                                           |
| ---------------------------------------------- | --------------------------------------------------------------------------------- |
| "It's a two-line change, I'll just do it here" | Then it lands without the target's conventions. Delegate it.                      |
| "It's research, so it needs a workspace"       | It edits no repository, so it is Non-Engineering work, not a checkout.            |
| "I'll wait for the agent's turn to finish"     | The turn is the agent's, and its reply is the user's. Send it and move on.        |
| "I'll run the `design` skill instead"          | It is the smaller preview. Claude Design work goes to claude.ai/design.           |
| "I'll reference what we just did"              | The receiving agent was not here. Spell it out.                                   |
| "I'll reuse the running agent, it's faster"    | A fresh worktree keeps the work on its own branch. Reuse only when asked.         |
| "I'll paste in the Linear issue's description" | Give the URL. The agent reads the issue itself; the issue is the source of truth. |
| "The skill is only used by Non-Engineering"    | It still lives in a repository, so it goes to Local Engineering.                  |
| "I'll say it'll report back when it's done"    | Delegation is final. Nothing reaches this session; the user checks the workspace. |
