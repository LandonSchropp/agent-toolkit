---
name: slack-message
description: Use when the user wants to draft a Slack message they'll post themselves, as opposed to one posted through Slack tools.
---

# Slack Message

Show the draft in your reply as plain prose. Write each link as an inline Markdown link, `[visible text](url)`, so the draft reads the way the message will look in Slack. Copy it to the clipboard only after the user approves it.

Mention a person by writing `@` followed by their name exactly as it appears in Slack, such as `@Jane Doe`. Slack turns that text into a real mention only when it matches the person's Slack display name exactly, so look the name up with a Slack user search. Never put a first name, a GitHub username, or a name linked to a profile or pull request where the mention belongs.

Slack's message box is a rich-text editor, not a Markdown parser. Pasted Markdown and Slack's `<url|text>` link syntax stay literal text, and so does the output of the built-in `/copy` command. The message has to reach the clipboard as rich text:

1. Write the message as HTML to a file in the scratchpad directory. Use `<a href>` for links, `<strong>` and `<em>` for emphasis, `<code>` for code and `<ul>` or `<ol>` for lists.
2. Slack collapses pasted paragraphs into single line breaks. Put `<p><br></p>` between every pair of paragraphs and before and after every list.
3. Run `scripts/copy-rich-text.sh <file>`, passing that file's path.
4. Tell the user the message is on their clipboard and ready to paste.

## Rationalizations

| Thought                                     | Reality                                                                 |
| ------------------------------------------- | ----------------------------------------------------------------------- |
| "Slack markup in the reply is close enough" | Pasted markup stays literal. Copy the rich text with the script.        |
| "The user can run `/copy`"                  | `/copy` copies plain Markdown, which Slack shows as literal text.       |
| "Copying now saves a step"                  | The user hasn't approved the draft. Wait for approval.                  |
| "Separate `<p>` tags are enough spacing"    | Slack collapses them into single line breaks. Add the empty paragraphs. |
| "A first name is clear enough"              | Only the exact Slack display name becomes a mention. Look it up.        |
