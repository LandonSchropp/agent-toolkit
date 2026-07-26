---
description: Use when reading or writing files under ~/Notes/Projects/, starting a new project, or archiving a finished one. Covers folder layout, the board file, supporting notes, and the project lifecycle across Future/, Projects/, and Archive/.
---

# Project

**REQUIRED:** Invoke the `ls-notes:note` skill first. Vault structure, conventions, icons, templates, and obsidian CLI guidance there all apply to projects.

## Layout

Each project is a folder named after the project, containing a board file of the same name:

```
Projects/<Project Name>/
  <Project Name>.md        # the kanban board
  <Supporting Note>.md
  <Supporting Note>.md
```

Supporting notes and assets are siblings of the board file. Don't nest them in subfolders.

## The Board File

The board file is a kanban board. **REQUIRED:** Read [Kanban Boards](references/kanban.md) for checkbox types, indentation, category tags, category colors, and the settings block. Those rules apply to every board file in the vault, including the ones outside `Projects/`.

Frontmatter:

```yaml
---
date: <YYYY-MM-DD>
tags: []
icon: LiKanbanSquare
kanban-plugin: board
prettier: false
---
```

Sections appear in this order, and no board uses all of them: Backlog, Blocked, To-Do, On Deck, In-Progress, Done, Cancelled, Archive. The header is `In-Progress`, hyphenated.

## Lifecycle

A project moves between three directories, and the whole folder moves with it:

- **Future/**: Not started yet. Someday or maybe.
- **Projects/**: Active.
- **Archive/Projects/**: Finished or abandoned.

`Projects/Projects.base` lists the active boards and filters out `Archive`, `Future`, and `Templates`, so a project drops off that list as soon as its folder moves.

## Templates

New projects come from `Templates/Projects/Project.md`. It seeds To-Do with links to two companion notes, created from `Templates/Projects/Project Kickoff.md` and `Templates/Projects/Project Completion.md`.
