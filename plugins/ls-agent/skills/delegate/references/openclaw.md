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

## Skills

An agent here draws on two sets of skills, and only one of them is repository work.

The user's own skills live in `agent-toolkit` and `personal-agent-toolkit`, and OpenClaw loads them from those checkouts through `skills.load.extraDirs`. Building or changing one goes to Herdr like any other change. A new one reaches an agent only once the user wires it in, so say which agents need it: its directory joins `skills.load.extraDirs`, and its bare name joins that agent's `agents.entries.<agent>.skills` allowlist, which replaces the default list rather than merging into it.

OpenClaw's own skills are the ones bundled with it, installed under `~/.openclaw/skills`, or built in an agent's workspace. They belong to OpenClaw, and they are maintained there rather than delegated to Herdr.

Name a repository skill so that no bundled OpenClaw skill already claims the name. `extraDirs` load below every other source, so the bundled skill silently wins a collision.
