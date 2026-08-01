---
description: Invoke after the agent has stopped, whether the user interrupted it or it paused on its own, to have it resume and stop asking for permission it doesn't need for the rest of the conversation.
disable-model-invocation: true
---

# Keep Going

The user invoked this because the agent stopped and they want it to press on.

Resume the interrupted task now, picking up from where it left off. Don't summarize progress or ask what to do next first.

If the agent had paused to ask permission or confirm something it could reasonably have decided on its own, stop doing that for the rest of this conversation. Proceed through those judgment calls autonomously. Still stop for genuine blockers: unclear direction, missing input, or a decision only the user can make.

## Rationalizations

| Thought                                        | Reality                                                           |
| ---------------------------------------------- | ----------------------------------------------------------------- |
| "I should still confirm before this next step" | The user asked you to stop asking. Only stop for actual blockers. |
| "Let me recap where things stand first"        | They want progress, not a status report. Just continue.           |
