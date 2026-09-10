---
name: instructions
description: Use at the start of any task, before taking action, to load the always-on workflow rules covering skill invocation, communication, skill scripts, and the conventions of the environment the session is running in.
---

# Instructions

Before doing anything else, check the following environment variables to determine which environment you're running in.

| Environment | Environment Variable |
| ----------- | -------------------- |
| Herdr       | `$HERDR_ENV`         |
| Multica     | `$MULTICA_AGENT_ID`  |

Then, you **MUST** read ALL of the reference files applicable to your environment.

| Reference                                                        | Environment |
| ---------------------------------------------------------------- | ----------- |
| [Communication](references/communication.md)                     | All         |
| [Skill scripts](references/skill-scripts.md)                     | All         |
| [Herdr](references/herdr.md)                                     | Herdr       |
| [Test-driven development](references/test-driven-development.md) | Herdr       |
| [Multica](references/multica.md)                                 | Multica     |

## EXTREMELY IMPORTANT

If you think there is a chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

## Rationalizations

| Thought                              | Reality                                                                      |
| ------------------------------------ | ---------------------------------------------------------------------------- |
| "This is just a simple question"     | Questions are tasks. Check for skills.                                       |
| "I need more context first"          | Skill check comes BEFORE clarifying questions.                               |
| "Let me explore the codebase first"  | Skills tell you HOW to explore. Check first.                                 |
| "I can check git/files quickly"      | Files lack conversation context. Check for skills.                           |
| "Let me gather information first"    | Skills tell you HOW to gather information.                                   |
| "This doesn't need a formal skill"   | If a skill exists, use it.                                                   |
| "I remember this skill"              | Skills evolve. Read the current version.                                     |
| "I'm running the task, so I'm there" | The user may not be. Check the environment before assuming you can wait.     |
| "This doesn't count as a task"       | Action = task. Check for skills.                                             |
| "The skill is overkill"              | Simple things become complex. Use it.                                        |
| "I'll just do this one thing first"  | Check BEFORE doing anything.                                                 |
| "This feels productive"              | Undisciplined action wastes time. Skills prevent this.                       |
| "I know what that means"             | Knowing the concept ≠ using the skill. Invoke it.                            |
| "They basically approved the commit" | Read your environment's reference; it defines the only approval that counts. |
| "They said the changes look good"    | Read your environment's reference; looking good is not commit approval.      |
