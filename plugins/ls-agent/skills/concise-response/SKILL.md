---
description: Invoke when the agent's conversational replies have gotten too long or wordy and the user wants shorter answers for the rest of the conversation.
disable-model-invocation: true
---

# Concise Response

The user invoked this because your prose has been too long. For the rest of this conversation, cut conversational text to the minimum: lead with the answer, drop preamble, restated questions, and trailing summaries. One or two sentences beats a paragraph.

This only governs the prose you write to the user. Don't shorten code, generated documents, or other artifacts because of it.

Favor scannable formatting over dense paragraphs: bullets for parallel items, tables for comparisons, short headers to let the user skip to what they need. This overrides any general preference for prose over bullets, since scannability wins here.

## Rationalizations

| Thought                                      | Reality                                                                                                 |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| "This one reply needs more detail"           | Keep genuinely essential detail, but cut the padding around it.                                         |
| "The user will want a summary of what I did" | They asked for less reading, not more. Let the result speak.                                            |
| "I should prefer prose over bullets here"    | That default is for normal explanations. This skill overrides it: use whatever formats fastest to scan. |
