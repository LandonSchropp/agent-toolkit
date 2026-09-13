# Git Town

## The Terminal Hook

Since git-town v22.7.0, `git town` commands require an interactive terminal unless `TERM=dumb` is set. Agent Bash calls have no interactive terminal, so `hooks/git-town.sh` prepends `TERM=dumb` to any Bash call that runs `git town`. It passes the rest of the tool input through unchanged, so settings such as the call's timeout survive the rewrite.
