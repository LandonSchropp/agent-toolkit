---
description: Use when creating a note, document, script or project that shouldn't outlive a known date — interview prep, a migration, a course, a time-boxed experiment — so it gets deleted on time instead of rotting in the repository.
---

# Self-Destruct

Time-boxed work leaves debris behind. A self-destruct records what to delete, when, and why, where an agent will actually read it.

**REQUIRED:** Invoke the `ls-code:project-conventions` skill for `AGENTS.local.md` and `CLAUDE.local.md`.

## Mark The File

Markdown gets a callout, at the top of the file after any frontmatter:

```markdown
> [!warning] Self-Destruct
> Delete this note after 2026-09-05, once the interview loop is over. It documents a single time-boxed project, and nothing in it generalizes.
```

Outside a vault, where that callout renders as a literal blockquote, use `> **Self-Destruct:**` and the same two sentences.

Anything with comment syntax gets one comment line, after any shebang:

```bash
# Self-Destruct: delete this file after 2026-09-05, once the migration has landed.
```

A format with no comments — JSON, CSV, an image — gets no marker, which makes the entry below its only record. A directory gets its marker in the README, or none if it hasn't got one.

Always an absolute date. "In three weeks" is unreadable by the time it matters.

## Record It in AGENTS.local.md

The marker only fires if someone opens the file, so the instruction also goes where every session reads it. Add an entry under a `## Self-Destructs` section in the repository's `AGENTS.local.md`:

```markdown
## Self-Destructs

- After 2026-09-05, delete `<path>` and `<path>`, remove their lines from `.git/info/exclude`, and delete this entry. <Why this existed and why it stops mattering then.>
```

The deleting agent never loads this skill, so the entry has to stand alone: every path, its exclude lines, and the entry itself.

## Keep It Out Of Version Control

A self-destructing file isn't committed unless the user asks for it. Add its path to `.git/info/exclude`, which is local to the clone and never committed itself. Not `.gitignore` — that is committed, so it would outlive the file it excludes.

## Destroying

This skill sets the trap; it doesn't spring it. There is no sweep to run and nothing to check on a schedule. When you read an entry whose date has passed, delete what it names — the entry included — as part of whatever you were already doing, then tell the user what went. The `## Self-Destructs` section goes with the last entry under it.
