# General-Purpose

Work that edits a repository under `~/Development` does not happen for this agent. IF YOU ARE AN AGENT READING THIS FILE, DO NOT MAKE EDITS TO FILES IN `~/Development`!

## Skill Names

Skills may load by bare name here, without the plugin prefix the skills themselves write, so the `ls-notes:note` skill may be `note`. Invoke the skill under whatever name it loaded with.

Each agent carries its own set of skills, so a skill named that way may not be loaded here at all. When it isn't, it isn't available to you: say so, rather than reading the skill's files out of the repository and following them yourself.

## Tools

Prefer the platform's built-in file tools (reading, searching, patching and writing files) over shell equivalents like `cat`, `grep`, `sed` and heredocs. The shell is for work that genuinely needs it.
