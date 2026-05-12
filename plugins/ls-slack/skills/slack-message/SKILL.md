---
description: Use when asked to draft, write, or format a message for Slack. Produces raw text the user can copy into Slack, then format with Cmd+Shift+F.
---

# Slack Message

The user will copy your output, paste it into Slack, and press **Cmd+Shift+F** to convert the pseudo-markdown into Slack's rich formatting.

## Output Format

Output the message directly — no preamble ("Here's the message:"), no trailing commentary, no wrapping code block. The message is the entire response.

## Formatting Syntax

**REQUIRED:** See [references/slack-formatting.md](references/slack-formatting.md) for the exact pseudo-markdown Slack accepts, what passes through literally, and what is NOT supported.

## Rationalizations

| Thought                                          | Reality                                                                                                                                                             |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| "I'll use `**bold**` — that's standard markdown" | Slack requires single asterisks. Double asterisks render literally in Slack.                                                                                        |
| "I'll add a `# Header` for structure"            | Cmd+Shift+F doesn't convert headers. Use a `*bold line*` instead.                                                                                                   |
| "I'll add a short intro before the message"      | The message IS the response. Any text outside it is noise the user has to skip past.                                                                                |
| "I'll use `•` bullets for list items"            | Bullets can't be copy-pasted into Slack's list format. Write list items as plain lines separated by a single newline — the user will apply the list style manually. |
