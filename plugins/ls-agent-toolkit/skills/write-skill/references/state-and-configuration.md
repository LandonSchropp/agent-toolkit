# State and Configuration

A skill that needs to keep state or configuration stores it outside the repository, in the [XDG base directory](https://specifications.freedesktop.org/basedir-spec/latest/) that fits:

- Configuration: Settings the user edits by hand go in `${XDG_CONFIG_HOME:-$HOME/.config}`.
- Data: Files worth keeping, such as backups, go in `${XDG_DATA_HOME:-$HOME/.local/share}`.
- State: Records a skill keeps between runs, such as logs or history, go in `${XDG_STATE_HOME:-$HOME/.local/state}`.
- Cache: Files a skill can regenerate go wherever Claude puts them by default.

Within a base directory, everything goes under a directory named for the skill's toolkit, nested by plugin and skill as needed: `<toolkit>/<plugin>/<skill>/` (such as `${XDG_STATE_HOME:-$HOME/.local/state}/agent-toolkit/ls-notes/plan-day/draft.json`). Files that several skills in a plugin share go in the plugin's directory, and the skills that use them agree on the file names.

Always write the path with its fallback, as above.
