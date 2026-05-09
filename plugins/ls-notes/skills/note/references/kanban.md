# Kanban Boards

For files with `kanban-plugin: board` in the frontmatter, follow these formatting conventions:

**Checkbox types:** Use specific checkbox types for top-level list items based on the header text. Preserve existing checkboxes in sub-lists.

| Header      | Checkbox Type |
| ----------- | ------------- |
| Backlog     | `[<]`         |
| Blocked     | `[?]`         |
| To-Do       | `[ ]`         |
| On Deck     | `[>]`         |
| In Progress | `[/]`         |
| Done        | `[x]`         |
| Cancelled   | `[-]`         |

**Indentation:** Use exactly two spaces for all child content below task items.

**Category tags:** Place `[category:: X]` tags in their own paragraph at the end of the task's content with two-space indentation.

Example formatting:

```markdown
- [ ] Task with child content

  Additional description or notes about the task.

- [ ] Task with category tag

  [category:: Neovim]

- [ ] Task with sub-list and category

  Fix ordering of results:
  - [ ] App files should come before spec files
  - [ ] Models should come before services
  - [ ] Schema files should not outrank db/schema.rb

  [category:: Development]
```
