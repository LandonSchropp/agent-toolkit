---
name: side-quest
description: Invoke when the conversation has drifted onto a tangent that deserves its own agent, so the tangent can be handed off and the main thread can get back on track.
disable-model-invocation: true
---

# Side Quest

The user invoked this because the conversation has wandered off the main task. Split the tangent out to another agent, then return to the main task.

## Identifying the Side Quest

The side quest is the tangent the conversation most recently drifted onto, unless the user's arguments name a different one. When it's obvious from context (and it usually is), outline the side quest in a sentence or two and ask the user whether that's right. Otherwise, ask the user what the side quest is. Don't delegate until the user confirms.

## Handing It Off

**REQUIRED:** Use the `ls-agent:delegate` skill to hand the side quest off. The prompt covers only the side quest, not the main task.

## Returning to the Main Thread

Once the hand-off is done, say where the side quest went in one sentence and resume the main task where it left off. Don't keep working on the side quest here, even if it comes up again; point back to the agent that owns it.

## Rationalizations

| Thought                                     | Reality                                                                      |
| ------------------------------------------- | ---------------------------------------------------------------------------- |
| "The side quest is obvious, skip the check" | Outline it anyway. The user confirms before anything is delegated.           |
| "It's nearly done, I'll just finish it"     | The user asked to split it out. Delegate it.                                 |
| "The agent needs the main task for context" | Only what bears on the side quest. The rest pulls it off track the same way. |
