---
name: project-conventions
description: Use when setting up a new personal project, or when deciding which root file a piece of documentation, configuration, environment variable, or agent instruction belongs in. Covers the standard root files and what each one owns. Does not cover source code layout.
---

## Root Files

| File              | Committed | Owns                                                                                       |
| ----------------- | --------- | ------------------------------------------------------------------------------------------ |
| `README.md`       | Yes       | Everything true for both humans and agents: what the project is, install, commands, usage. |
| `CLAUDE.md`       | Yes       | Contains exactly `@AGENTS.md` and nothing else.                                            |
| `AGENTS.md`       | Yes       | Instructions only an agent needs: architecture, conventions, workflow.                     |
| `CLAUDE.local.md` | No        | Contains exactly `@AGENTS.local.md` and nothing else.                                      |
| `AGENTS.local.md` | No        | User-specific agent instructions that must not be committed.                               |
| `mise.toml`       | Yes       | Tool versions, tasks, and environment that version files can't express. Conditional.       |
| `mise.local.toml` | No        | Secrets and machine-specific environment variables.                                        |

ALWAYS create `README.md`, `CLAUDE.md`, and `AGENTS.md` in every project. Create the local files only when there's local content to put in them.

## Ownership

Never duplicate content between `README.md` and `AGENTS.md`. If something is useful to a human, it goes in the README even when agents also need it. `AGENTS.md` holds only what a human reader would have no use for.

Because of that split, `AGENTS.md` MUST open by requiring the agent to read `README.md`:

```markdown
**REQUIRED:** Read `README.md` before doing anything else. It documents the project's purpose, setup, and commands.
```

## Mise En Place

Prefer the conventional version file — `.node-version`, `.ruby-version`, and equivalents — since mise and other tools already read them. Add `mise.toml` only when the project needs tasks, environment variables, or a tool with no conventional version file. Don't create an empty one.

## Rules

- Import case MUST match the filename exactly: `@AGENTS.md`, never `@agents.md`. Lowercase resolves on macOS and silently loads nothing on Linux and CI.
- Never import `AGENTS.local.md` from `AGENTS.md`. `CLAUDE.local.md` already imports it, and it often won't exist.
- Never alter the casing of these filenames. It's `README.md`, never `readme.md` or `Readme.md`.
- Never put content in `CLAUDE.md` or `CLAUDE.local.md`. If either holds anything but its import line, move that content to the matching `AGENTS` file.
- Never commit a project whose only shim is `CLAUDE.local.md`. That file is gitignored, so a fresh clone loads no instructions at all.

## Rationalizations

| Thought                                            | Reality                                                              |
| -------------------------------------------------- | -------------------------------------------------------------------- |
| "Claude reads `AGENTS.md` natively now"            | It does not, at any version. Without `CLAUDE.md`, nothing is loaded. |
| "Claude will pick up `AGENTS.local.md` on its own" | It never does. Only `CLAUDE.local.md` importing it works.            |
| "This command belongs in `AGENTS.md`"              | If a human would run it, it belongs in `README.md`.                  |
| "I'll duplicate it in both to be safe"             | Duplicated docs drift. One owner, always.                            |
| "I'll add `mise.toml` for consistency"             | An empty `mise.toml` is noise. `.node-version` already does the job. |
