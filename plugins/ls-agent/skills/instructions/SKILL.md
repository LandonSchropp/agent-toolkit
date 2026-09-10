---
name: instructions
description: Use at the start of any task, before taking action, to load the always-on workflow rules covering skill invocation, communication, skill scripts, and the conventions of the environment the session is running in.
---

# Instructions

Before doing anything else, you **MUST** read the following reference files:

- [Communication](references/communication.md)
- [Skill scripts](references/scripts.md)

Then, you **MUST** read the references for your environment, which the environment variable identifies.

| Environment | Environment Variable | References                                                                                     |
| ----------- | -------------------- | ---------------------------------------------------------------------------------------------- |
| Herdr       | `$HERDR_ENV`         | [Herdr](references/herdr.md), [Test-driven development](references/test-driven-development.md) |
| Multica     | `$MULTICA_AGENT_ID`  | [Multica](references/multica.md)                                                               |

## EXTREMELY IMPORTANT

If you think there is a chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

## Rationalizations

| Thought                              | Reality                                                                   |
| ------------------------------------ | ------------------------------------------------------------------------- |
| "This is just a simple question"     | Questions are tasks. Check for skills.                                    |
| "I need more context first"          | Skill check comes BEFORE clarifying questions.                            |
| "Let me explore the codebase first"  | Skills tell you HOW to explore. Check first.                              |
| "I can check git/files quickly"      | Files lack conversation context. Check for skills.                        |
| "Let me gather information first"    | Skills tell you HOW to gather information.                                |
| "This doesn't need a formal skill"   | If a skill exists, use it.                                                |
| "I remember this skill"              | Skills evolve. Read the current version.                                  |
| "I'm running the task, so I'm there" | The user may not be. Check the platform before assuming you can wait.     |
| "This doesn't count as a task"       | Action = task. Check for skills.                                          |
| "The skill is overkill"              | Simple things become complex. Use it.                                     |
| "I'll just do this one thing first"  | Check BEFORE doing anything.                                              |
| "This feels productive"              | Undisciplined action wastes time. Skills prevent this.                    |
| "I know what that means"             | Knowing the concept ≠ using the skill. Invoke it.                         |
| "They basically approved the commit" | Read your platform's reference; it defines the only approval that counts. |
| "They said the changes look good"    | Read your platform's reference; looking good is not commit approval.      |
