# Conventions

## File Naming

- File names ARE titles. Use descriptive, human-readable names.
- Time-sensitive content uses a `YYYY-MM-DD` prefix.
- Maintain consistency within each directory.

## Headers

- **Never include an H1.** The file's name acts as the title in Obsidian.
- Use **title case** for all headers (H2 and below).

## Frontmatter

- Use ISO dates (`YYYY-MM-DD`).
- Use tags sparingly, only for cross-cutting themes.
- Only set `icon` when applying a template that includes one. Never add icons to frontmatter manually.

## Obsidian Formatting Quirks

- **`::` in link labels**: Obsidian interprets `[text:: value]` as a property tag. Never use `::` in a markdown link label — shorten or rephrase the label to avoid it (e.g. use `InvalidURIError` instead of `URI::InvalidURIError`).

## Triage

When unsure where a new note belongs, drop it into `Triage/` for later organization rather than guessing.
