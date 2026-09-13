# Terminal

- Use the `trash` command in place of `rm` when removing files.
- Search file contents with a built-in `Grep` tool when one is available. When you have to search from `Bash`, use `rg` instead of `grep`.
- Use the `gh` command for GitHub resources such as repositories, issues and pull requests.
- Don't prepend `timeout` to a command. Set the timeout on the `Bash` tool instead.

## Rationalizations

| Thought                               | Reality                                                    |
| ------------------------------------- | ---------------------------------------------------------- |
| "`rm` is fine for a scratch file"     | `trash` is recoverable. Use it every time.                 |
| "`grep` is already muscle memory"     | `rg` is faster and respects `.gitignore`. Reach for it.    |
| "`timeout` keeps the command bounded" | The `Bash` tool's timeout does that. Set it there instead. |
