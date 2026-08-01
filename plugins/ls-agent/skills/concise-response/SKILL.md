---
description: Invoke when the agent's conversational replies have gotten too long or wordy and the user wants shorter answers for the rest of the conversation.
disable-model-invocation: true
---

# Concise Response

The user invoked this because your prose has been too long. For the rest of this conversation, cut conversational text to the minimum: lead with the answer, drop preamble, restated questions, and trailing summaries. One or two sentences beats a paragraph.

This only governs the prose you write to the user. Don't shorten code, generated documents, or other artifacts because of it.

## Rationalizations

| Thought                                      | Reality                                                         |
| -------------------------------------------- | --------------------------------------------------------------- |
| "This one reply needs more detail"           | Keep genuinely essential detail, but cut the padding around it. |
| "The user will want a summary of what I did" | They asked for less reading, not more. Let the result speak.    |
