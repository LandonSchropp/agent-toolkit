# Templates

Templates live under `Templates/` (organized into subdirectories like `Templates/Notes/`, `Templates/Periodic/`, `Templates/Projects/`, etc.) and define the structure, headings, and frontmatter for new files of each type.

## Finding a Template

List the contents of `Templates/` and its subdirectories to see what's available, then read the candidate template file to confirm it fits before relying on it.

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
