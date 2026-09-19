# Obsidian CLI

Vault files are ordinary Markdown. Reading and editing a note's body needs no special tooling — use whatever file tool fits, and edit frontmatter as YAML directly, keeping its indentation and quoting consistent.

The `obsidian` CLI dispatches to the running Obsidian app, which is the only way to refactor wikilinks across the vault when a file's path changes, query the app's index, or run a new file through Templater. Renaming or moving a file directly leaves wikilinks throughout the vault pointing at a path that no longer exists, so those always go through the CLI. **Never use `mv` on vault files.**

## Discovering Commands

Run `obsidian --help` to see the full command set. Most commands accept either `file=<name>` (resolves like a wikilink) or `path=<folder/note.md>` (exact path).

## Structural Operations

- `obsidian rename` / `obsidian move`: Rename or move a file. Wikilinks and embeds are updated across the vault automatically.
- `obsidian delete`: Delete a file. It lands in Obsidian's own trash and the vault index is updated, neither of which `trash` does.

## Vault Graph Queries

These read the app's index, so they see aliases, frontmatter tags, and the link graph that a plain text search misses.

- `obsidian search` / `obsidian search:context`: Vault-aware search.
- `obsidian backlinks` / `obsidian links` / `obsidian tags`: Notes linking in, links out, and the vault's tags.

## Other Operations

- `obsidian create name=... template=...`: Create a file with a template applied. Use this whenever a template exists for the file type, since Templater only runs inside the app.
- `obsidian property:read` / `property:set` / `property:remove`: Read and write frontmatter properties.
- `obsidian daily:read` / `daily:append` / `daily:prepend`: Interact with the daily note.
- `obsidian append`: Append content to an existing file.

## Without Bash

If the Bash tool is not available (for example, in Claude Desktop), fall back to direct file operations and apply the same vault conventions. Renames and moves will leave wikilinks across the vault dangling, and vault-graph queries are unavailable until Obsidian rescans, so flag both to the user instead of working around them silently.
