# Templates

Templates live under `Templates/` (organized into subdirectories like `Templates/Notes/`, `Templates/Periodic/`, `Templates/Projects/`, etc.) and define the structure, headings, and frontmatter for new files of each type.

## Finding a Template

Templater maps destination paths to templates through the `file_templates` list in `.obsidian/plugins/templater-obsidian/data.json`. Each entry pairs a path regex with a template, and the first regex that matches the note's vault-relative path wins. A catch-all entry such as `.*` matches any path that no specific entry claims.

When that file isn't readable, such as through the Obsidian MCP server, infer the folder's template from its neighbors. Read a few notes already in the destination folder, then find the template under `Templates/` whose frontmatter and headings they share. Read that template to confirm it fits before relying on it.

A folder has a template when a specific entry matches it or its neighbors share one. A match on the catch-all alone gives the folder a template only when its neighbors use it too.

## Moving a Note

Moving a note never triggers Templater, so apply the destination's template by hand whenever a note moves into a folder that has one. Merge the template into the note:

- **Frontmatter:** Keep every value the note already has. Add each template key the note lacks, and fill each empty key, using the template's default.
- **Body:** Keep the note's content as it is. Add each template heading the note lacks in the template's order.
- **Placeholders:** Resolve Templater placeholders as described in [Without the `obsidian` CLI](#without-the-obsidian-cli), using the note's new path.

## Applying a Template

### With the `obsidian` CLI

When `obsidian create` is used, Obsidian automatically applies the right template based on the destination folder and runs it through the Templater plugin (date placeholders, dynamic conditionals, frontmatter all filled in). For most cases, just create the file in the correct folder — no `template=` argument needed:

```
obsidian create path="Resources/Articles/My Article.md"
```

Pass `template=<name>` only to override the folder default (the name is the path under `Templates/` without the `.md` extension):

```
obsidian create path="Triage/Quick Capture.md" template="Thoughts/Idea"
```

### Without the `obsidian` CLI

Direct file operations bypass Obsidian, so no template auto-applies and Templater does not run. Read the matching template, copy its content into the new file, and substitute Templater placeholders manually. Common ones:

- `<% tp.date.now("YYYY-MM-DD") %>` → today's ISO date.
- `<% tp.file.title %>` → the new file's name (without `.md`).
- `<% tp.file.folder(true) %>` → the file's parent folder path.
- `<%* … _%>` blocks contain JavaScript control flow. Evaluate the conditions in your head to decide which branches to keep, then remove the directive markers and any unused branches from the output.

Flag any conditional you cannot confidently evaluate so the user can resolve it.
