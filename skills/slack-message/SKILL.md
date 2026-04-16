---
description: Use when asked to draft, write, or format a message for Slack. Produces raw text the user can copy and paste into Slack, then format with Cmd+Shift+F.
---

# Slack Message

The user will copy your output, paste it into Slack, and press **Cmd+Shift+F** to convert the pseudo-markdown into Slack's rich formatting. Your output must be raw text — not rendered markdown — so the user can copy it cleanly.

## Output Format

Wrap the entire message in a **four-backtick** fenced code block. Four (not three) is the default so the message itself can safely contain a normal three-backtick code block without breaking the outer fence.

`````
````
Hey team — quick update on the migration:

• *Staging* is done
• Prod rolls out tomorrow at _9am PT_

Run this to check status:

```
SELECT count(*) FROM migrations WHERE state = 'done';
```

See [the runbook](https://example.com/runbook) for rollback steps.
````
`````

Output nothing else — no preamble ("Here's the message:"), no trailing commentary. The code block is the entire response.

## Formatting Syntax

**REQUIRED:** See [references/slack-formatting.md](references/slack-formatting.md) for the exact pseudo-markdown Slack accepts, what passes through literally, and what is NOT supported.

## Rationalizations

| Thought                                                 | Reality                                                                                                |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| "I'll skip the code block — the user can read markdown" | Without the fence, the harness renders the formatting. The user loses the raw text they need to paste. |
| "Three backticks on the outer fence is enough"          | If the message ever contains a code block, three outer backticks break. Always use four.               |
| "I'll use `**bold**` — that's standard markdown"        | Slack requires single asterisks. Double asterisks render literally in Slack.                           |
| "I'll add a `# Header` for structure"                   | Cmd+Shift+F doesn't convert headers. Use a `*bold line*` instead.                                      |
| "I'll add a short intro before the code block"          | The code block IS the response. Any text outside it is noise the user has to skip past.                |
