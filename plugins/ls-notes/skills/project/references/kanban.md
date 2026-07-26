# Kanban Boards

For files with `kanban-plugin: board` in the frontmatter, follow these formatting conventions:

**Never format a board with Prettier, and never remove `prettier: false` from a board's frontmatter.** Prettier rewrites the list and indentation structure the kanban plugin depends on, which corrupts the board. Add the key if a board is missing it.

## Card Formatting

**Checkbox types:** Use specific checkbox types for top-level list items based on the header text. Preserve existing checkboxes in sub-lists.

| Header      | Checkbox Type |
| ----------- | ------------- |
| Backlog     | `[<]`         |
| Blocked     | `[?]`         |
| To-Do       | `[ ]`         |
| On Deck     | `[>]`         |
| In-Progress | `[/]`         |
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

## Category Colors

A board can flavor its cards by category. The per-board `category-colors` setting maps `[category:: X]` values to named colors. A card whose category has a color gets a left stripe in that color, and the matching category pill gets a colored dot.

**Allowed colors:** `red`, `orange`, `yellow`, `green`, `cyan`, `blue`, `purple`, `pink`, `black`, `gray`, `white`, and nothing else. The first eight resolve to Obsidian's theme color variables (`var(--color-red)` and so on), and the last three to steps off the theme's neutral base ramp. Custom hex codes are not allowed: named colors adapt between light and dark themes, and a fixed hex code will read wrong in one of them.

**Matching:** Each `category` value must match the `[category:: X]` text. Matching is case-insensitive and trims surrounding whitespace. A card with several categories takes its stripe from the FIRST of its categories that has a color configured, ignoring the rest.

## The Settings Block

Board files end with a `kanban:settings` block holding the board's JSON configuration, including `category-colors`.

**Keep the JSON pretty-printed, never minified.** The plugin writes it in Prettier's JSON style: two-space indent, with each flat object kept on ONE line as long as it fits the 80-column print width, and expanded one entry per line when it doesn't. Match that format exactly so the next board save doesn't reformat the file and produce a spurious diff.

**Do not use `JSON.stringify(settings, null, 2)`.** That expands every object onto separate lines, which is not what the plugin writes.

The category pill only renders when `category` is listed in `metadata-keys`, so a board that colors categories needs both settings. Other common keys are `list-collapse`, `show-relative-date`, `archive-with-date`, and `append-archive-date`.

**Leave no blank lines inside the block.** The marker, the fence, and the closing `%%` sit on consecutive lines, and the file ends at `%%` with no trailing newline. Prettier inserts blank lines around the fence, which is one more reason boards keep `prettier: false`.

````text
%% kanban:settings
```
{
  "kanban-plugin": "board",
  "show-relative-date": true,
  "metadata-keys": [
    {
      "metadataKey": "category",
      "label": "Category",
      "shouldHideLabel": false,
      "containsMarkdown": false
    }
  ],
  "category-colors": [
    { "category": "Recruiter Screen", "color": "red" },
    { "category": "Take-Home", "color": "orange" },
    { "category": "Onsite", "color": "green" }
  ]
}
```
%%
````

That example shows both halves of the width rule: the `category-colors` entries fit on one line and stay inline, while the longer `metadata-keys` entry does not and expands.
