---
name: side-quest
description: Invoke when the conversation has drifted onto a tangent that deserves its own agent, so the tangent can be handed off and the main thread can get back on track.
disable-model-invocation: true
---

# Side Quest

The user invoked this because the conversation has wandered off the main task. Split the tangent out to another agent, then return to the main task.

## Identifying the Side Quest

The side quest is the tangent the conversation most recently drifted onto, unless the user's arguments name a different one.

If the user's arguments already describe the side quest, that description is the confirmation, so proceed straight to handing it off. Otherwise, when it's obvious from context, outline the side quest in a sentence or two and ask the user whether that's right. If it's not obvious from context either, ask the user what the side quest is. Don't delegate until the user confirms.

## Handing It Off

**REQUIRED:** Use the `ls-agent:delegate` skill to hand the side quest off. The prompt covers only the side quest, not the main task.

## Returning to the Main Thread

Once the hand-off is done, say where the side quest went in one sentence and resume the main task where it left off. Don't keep working on the side quest here, even if it comes up again; point back to the agent that owns it. After that one mention, don't bring the side quest up again unless the user explicitly asks about it. Nothing comes back to this session to report — the user watches the delegated agent's own workspace directly.

## Rationalizations

| Thought                                      | Reality                                                                       |
| -------------------------------------------- | ----------------------------------------------------------------------------- |
| "The side quest is obvious, skip the check"  | Obvious from context still isn't the same as user-described. Outline and ask. |
| "They gave a description, confirm anyway"    | The description already is the confirmation. Proceed.                         |
| "It's nearly done, I'll just finish it"      | The user asked to split it out. Delegate it.                                  |
| "The agent needs the main task for context"  | Only what bears on the side quest. The rest pulls it off track the same way.  |
| "I'll check in on the side quest's progress" | It's delegated. Don't mention it again unless the user asks.                  |
