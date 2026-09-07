# OpenClaw

OpenClaw runs the user's standing personal agents, each with its own workspace and sessions. A delegation is a turn on the agent whose domain the task falls in.

## Choosing the Agent

`openclaw agents list` names the roster, each agent's identity beside its id. Match the task to the agent that owns its domain, and split it into a turn per agent only when it genuinely spans two.

## Sending

Write the prompt to a file and send it as a turn on the agent's main session:

```bash
openclaw agent --agent <agent-id> --message-file <path>
```

Pass the prompt as a file rather than as an argument. Prompts routinely contain backticks and `$`, which the shell expands before the command sees them. Check the agent id against the roster first, since a wrong one fails the whole turn.

The command blocks for the agent's whole turn, so run it in the background and don't wait on the result. The reply lands in the agent's own session, which the user reads in the Control UI, not in your reply. A long turn outlives the command's own timeout, since the gateway owns it once it is accepted; sending it again would run it twice.

From inside OpenClaw, use `sessions_send` against the target agent instead. It is the same handoff without shelling back into your own gateway.
