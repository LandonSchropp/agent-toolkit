---
description: Use when setting up tmuxinator for a project, creating a new tmuxinator config, or when a project needs a terminal workspace layout.
---

Create a tmuxinator config file at `~/.config/tmuxinator/<name>.yml`.

## Workflow

1. **Detect project name.** Infer the name from the current conversation context (project directory, repo name, etc.). Present it to the user for confirmation before proceeding. The name usually matches the directory name but not always.

2. **Check for existing config.** If `~/.config/tmuxinator/<name>.yml` already exists, show the user its contents and ask whether to overwrite or pick a different name. Do NOT silently overwrite.

3. **Determine windows.** Start with the default windows from `~/.config/tmuxinator/default.yml`. If the project would clearly benefit from additional windows (e.g., a dev server), suggest them to the user. Do not add extra windows without asking.

4. **Write the config.** Read `~/.config/tmuxinator/default.yml` as the base template. Add a `root` field with the project path (using `~` for home) and set the `name` field. Add any extra windows the user confirmed. Write the file to `~/.config/tmuxinator/<name>.yml`.

## Rationalizations

| Thought                                          | Reality                                                                |
| ------------------------------------------------ | ---------------------------------------------------------------------- |
| "I'll just write it without confirming the name" | The name matters. Always confirm with the user first.                  |
| "I'll skip checking for existing configs"        | Overwriting a config silently destroys the user's setup. Always check. |
| "I'll add extra windows since they seem useful"  | Ask first. The user's defaults exist for a reason.                     |
