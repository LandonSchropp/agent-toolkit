# Slack Formatting Reference

Slack converts a limited set of pseudo-markdown into rich formatting when the user pastes text and presses **Cmd+Shift+F**. This reference documents what is and isn't supported.

## Supported Syntax

| Syntax         | Renders as                          |
| -------------- | ----------------------------------- |
| `*bold*`       | Bold — SINGLE asterisks, not double |
| `_italic_`     | Italic                              |
| `~strike~`     | Strikethrough                       |
| `` `code` ``   | Inline code                         |
| ` ```code``` ` | Code block                          |
| `[text](url)`  | Hyperlinked text                    |
| `> quote`      | Blockquote                          |

## Literals

These pass through as-is — Slack resolves them automatically when the target exists. Do NOT escape or wrap them:

- `@DisplayName` — user mention. Match the user's actual Slack display name, including capitalization (e.g., `@Landon`, not `@landon`).
- `#channel-name` — channel link. Must be a real channel in the workspace.
- `:emoji_name:` — emoji.

## Not Supported

- **Bulleted and numbered lists.** Cmd+Shift+F does NOT convert `- item`, `* item`, or `1. item` into Slack's native list formatting. Slack's real list style (with hanging indentation on wrapped lines) is only applied when the user types `- ` or `* ` directly in the composer — there is no way to trigger it from pasted text. Best approximation: put a unicode bullet (`•`) at the start of each line. Wrapped lines will still align to column 1, not indent under the text, so keep list items short enough to fit on one line, or write as prose instead.
- **Double-asterisk bold (`**bold**`).** Slack only bolds with single asterisks. Double asterisks render as literal `*` characters around the word.
- **Headers (`#`, `##`, `###`).** Not converted. They appear as literal `#` characters. Use a `*bold line*` for emphasis on a standalone line.
- **HTML tags.** Render as literal text.
- **Tables.** No markdown table syntax is converted. Use a code block for tabular data.
- **Nested formatting in links.** `[*bold*](url)` does not produce bold link text — the asterisks render literally inside the link.
