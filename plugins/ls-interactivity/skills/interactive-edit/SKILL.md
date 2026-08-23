---
description: Use when a skill needs the user to interactively edit a file in VS Code mid-workflow, then read their changes back.
user-invocable: false
---

# Interactive Edit

Run `code --reuse-window --wait <file>` in the background. It opens `<file>` in VS Code and blocks until the editor window closes. Afterward, read the file to get the user's saved edits.

To present generated content for editing, write it to a scratch file first and pass that as `<file>`.