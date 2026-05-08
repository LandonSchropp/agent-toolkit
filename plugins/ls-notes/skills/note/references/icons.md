# Icons

Icons are camelCase identifiers that render as inline glyphs in Obsidian.

## Format

- **In content:** wrap the identifier in colons. Example: `:LiSun:`, `:LiBook:`.
- **In frontmatter** (`icon:` property): bare, no colons. Example: `icon: LiSun`.

## Sets

- **Lucide (preferred):** identifiers prefixed with `Li`. Examples: `LiSun`, `LiBook`, `LiSettings`, `LiKanbanSquare`.
- **Tabular (fallback when Lucide lacks a suitable option):** identifiers prefixed with `Ti`. Examples: `TiBan`, `TiDatabase`, `TiBallAmericanFootball`.

Always try Lucide first. Only reach for Tabular when no Lucide icon fits.

## Exclusions

Never use icons in:

- `Resources/Learning Notes/`
- `Resources/Today I Learned/`
- `Resources/Articles/`

## Manual Insertion

Only set the `icon:` frontmatter property when applying a template that already includes one. Do not add icons to existing notes manually.

## Finding an Available Icon

Both libraries are large (~1,500 Lucide, ~5,000 Tabler icons). When you need to pick an icon and do not already know a matching name, look up candidates by fetching:

- **Lucide (preferred):** `https://lucide.dev/icons/?search=<keyword>`.
- **Tabler (fallback):** `https://tabler.io/icons?q=<keyword>`.

The site name is kebab case; the vault uses prefixed PascalCase. Convert by capitalizing each segment and prepending the prefix:

- Lucide `arrow-up-right` → `LiArrowUpRight`
- Tabler `ball-american-football` → `TiBallAmericanFootball`
