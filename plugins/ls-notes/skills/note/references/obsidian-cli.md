# Obsidian CLI

The `obsidian` CLI is the preferred way to interact with the vault from a shell. It keeps the vault index synchronized, refactors wikilinks across the vault on rename or move, and reads or writes frontmatter without YAML formatting risk.

## Discovering Commands

Run `obsidian --help` to see the full command set. Most commands accept either `file=<name>` (resolves like a wikilink) or `path=<folder/note.md>` (exact path).

## Common Operations

- `obsidian rename` / `obsidian move`: rename or move a file. Wikilinks and embeds are updated across the vault automatically. **Never use `mv` for vault files.**
- `obsidian create name=... template=...`: create a file with a template applied. Prefer this over `Write` when a template exists for the file type.
- `obsidian delete`: delete a file and update the vault index. Prefer over `trash`.
- `obsidian property:read` / `property:set` / `property:remove`: manipulate frontmatter without editing YAML directly.
- `obsidian search` / `obsidian search:context`: vault-aware search (respects aliases and tags).
- `obsidian daily:read` / `daily:append` / `daily:prepend`: interact with the daily note.
- `obsidian backlinks` / `obsidian links` / `obsidian tags`: vault graph queries.
- `obsidian append`: append content to an existing file.

## Without Bash

If the Bash tool is not available (for example, in Claude Desktop), apply the same vault conventions via direct file operations. Be aware:

- Renames and moves will leave wikilink references across the vault dangling. Flag this to the user when it happens so they can decide whether to update or accept the breakage.
- Frontmatter must be edited as YAML — keep indentation and quoting consistent.
- The vault index will not refresh until Obsidian rescans the file, so vault-graph operations (backlinks, tags, aliases) are unavailable.
