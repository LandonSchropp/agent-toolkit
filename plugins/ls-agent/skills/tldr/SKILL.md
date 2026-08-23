---
description: Invoke when the agent's conversational replies have gotten too long or wordy and the user wants shorter answers for the rest of the conversation.
disable-model-invocation: true
---

# TL/DR

The user invoked this because your prose has been too long. For the rest of this conversation, cut conversational text to the minimum: lead with the answer, drop preamble, restated questions, and trailing summaries. One or two sentences beats a paragraph.

## Rewrite the Last Response

When the user typed the command directly (e.g. `/tldr`), redo your immediately preceding response now, in the shorter style, instead of just acknowledging the change. The rewrite itself is the acknowledgment — don't preface it with "Noted" or "I'll be shorter from here on."

Skip the rewrite only when:

- Another skill's instructions invoked this skill on your behalf, rather than the user typing the command directly.
- The last response is already a sentence or two.

In both skip cases, apply the shorter style going forward without redoing anything.

This only governs the prose you write to the user. Don't shorten code, generated documents, or other artifacts because of it.

Favor scannable formatting over dense paragraphs: bullets for parallel items, tables for comparisons, short headers to let the user skip to what they need. This overrides any general preference for prose over bullets, since scannability wins here.

## Rationalizations

| Thought                                            | Reality                                                                                                 |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| "I'll just say I'll be more concise going forward" | That's a comment about the behavior, not the behavior itself. Rewrite the last response now.            |
| "This one reply needs more detail"                 | Keep genuinely essential detail, but cut the padding around it.                                         |
| "The user will want a summary of what I did"       | They asked for less reading, not more. Let the result speak.                                            |
| "I should prefer prose over bullets here"          | That default is for normal explanations. This skill overrides it: use whatever formats fastest to scan. |
