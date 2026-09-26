# Kanban Boards

For files with `kanban-plugin: board` in the frontmatter, follow these formatting conventions:

## Card Formatting

**Titles:** Start every card with a short, bold title on the checkbox line, and put the description in its own paragraph below it. A card that's only a wikilink uses the link as its title.

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
- [ ] **Task with child content**

  Additional description or notes about the task.

- [ ] **Task with category tag**

  [category:: Neovim]

- [ ] **Task with sub-list and category**

  Fix ordering of results:
  - [ ] App files should come before spec files
  - [ ] Models should come before services
  - [ ] Schema files should not outrank db/schema.rb

  [category:: Development]
```

## Agent Field

The `[agent:: X]` field marks how much of a card an agent can take on. It goes in the trailing paragraph at the end of the card, one field per line, alongside the category tag if there is one. The value is always one of these three, in title case:

| Value      | Meaning                                                                                                                                               |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Auto`     | An agent can complete the whole card unattended. The user reviews the resulting code, pull request or note, and the card closes once they approve it. |
| `Assisted` | An agent can do most of the card but needs the user mid-flight to answer questions or make a call.                                                    |
| `Manual`   | There is nothing left for an agent to do: physical work, work that needs the user's taste, or work that needs the user specifically.                  |

A card with no `agent` field has not been judged yet. That is a valid state, not an error to fix.

**Preparatory work:** There is deliberately no value for groundwork such as research, pricing, or gathering that an agent could do but that wouldn't close the card. A card tagged as prep-only could never be closed by the agent that worked it, which leaves its state ambiguous. Instead, split the groundwork into its own card, mark the new card `[agent:: Auto]`, and link it from the original. The original keeps whatever value actually describes it. Every value except `Manual` describes work an agent can actually finish.

```markdown
- [ ] **Task an agent can finish on its own**

  [category:: Development]
  [agent:: Auto]
```

The field only renders as a pill on the board when `agent` is listed in `metadata-keys`, as shown in [The Settings Block](#the-settings-block). The values have no colors; `category-colors` applies to categories only.

## Category Colors

A board can flavor its cards by category. The per-board `category-colors` setting maps `[category:: X]` values to named colors. A card whose category has a color gets a left stripe in that color, and the matching category pill gets a colored dot.

**Allowed colors:** `red`, `orange`, `yellow`, `green`, `cyan`, `blue`, `purple`, `pink`, `black`, `gray`, `white`, and nothing else. The first eight resolve to Obsidian's theme color variables (`var(--color-red)` and so on), and the last three to steps off the theme's neutral base ramp. Custom hex codes are not allowed: named colors adapt between light and dark themes, and a fixed hex code will read wrong in one of them.

**Matching:** Each `category` value must match the `[category:: X]` text. Matching is case-insensitive and trims surrounding whitespace. A card with several categories takes its stripe from the FIRST of its categories that has a color configured, ignoring the rest.

## The Settings Block

Board files end with a `kanban:settings` block holding the board's JSON configuration, including `category-colors`.

**Keep the JSON pretty-printed, never minified.** The plugin writes it in Prettier's JSON style: two-space indent, with each flat object kept on ONE line as long as it fits the 80-column print width, and expanded one entry per line when it doesn't. Match that format exactly so the next board save doesn't reformat the file and produce a spurious diff.

**Do not use `JSON.stringify(settings, null, 2)`.** That expands every object onto separate lines, which is not what the plugin writes.

The category pill only renders when `category` is listed in `metadata-keys`, so a board that colors categories needs both settings. Other common keys are `list-collapse`, `show-relative-date`, `archive-with-date`, and `append-archive-date`.

Prettier adds blank lines around the fence and a trailing newline, and the plugin reads either layout.

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
    },
    {
      "metadataKey": "agent",
      "label": "Agent",
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

That example shows both halves of the width rule: the `category-colors` entries fit on one line and stay inline, while the longer `metadata-keys` entries do not and expand.
