---
name: note
description: Use when working with files in ~/Notes (the user's Obsidian vault). Covers vault structure (PARA), file naming, frontmatter, icons, templates, kanban boards, and the obsidian CLI.
---

# Note

The user's Obsidian vault is at `~/Notes`. Reach it with the first of these that's available:

1. **The `obsidian` CLI:** See [Obsidian CLI](references/obsidian-cli.md).
2. **The Obsidian MCP server:** Its `vault_*` tools take paths relative to the vault root. Change an existing note with `vault_edit`, never `vault_write`, which silently overwrites edits synced from the user's devices.
3. **Direct file edits:** Edit the files in `~/Notes` directly.

**REQUIRED:** Read all of the following references before reading from or writing to any file in the vault:

- [Structure](references/structure.md): PARA directories and which sub-skill applies to each.
- [Conventions](references/conventions.md): File naming, frontmatter, triage.
- [Icons](references/icons.md)
- [Templates](references/templates.md)
- [Obsidian CLI](references/obsidian-cli.md)

## Related Skills

- `ls-notes:daily-note`: Invoke when the user mentions a daily note or daily todos, or when reading or writing any file under `Daily Notes/`.
- `ls-notes:project`: Invoke when reading or writing any file under `Projects/`, starting a new project, archiving a finished one, or editing any file with `kanban-plugin: board` in its frontmatter. It owns the kanban board conventions.
- `ls-notes:plan-day`: Invoke when the user says "plan my day" or "plan my morning", or wants to walk through morning journaling and tasks for today's daily note.
- `ls-notes:flashcards`: Invoke when the user wants flash cards or a spaced-repetition deck built from a note or other source material.
