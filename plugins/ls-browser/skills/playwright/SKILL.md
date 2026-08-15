---
description: Use when a task needs a browser — reading a page, filling a form, taking a look at something, or reaching anything behind a login. Always run this skill before the `playwright-cli` skill.
---

# Playwright

**REQUIRED:** Use the `playwright-cli` skill for the commands themselves. Drive the browser through `playwright-cli`, never through the Playwright MCP tools, which know nothing about the session.

Always name the session, and pass the name on every later command:

```bash
playwright-cli --session=<name> open <url> [flags]
```

Later commands attach to that browser and inherit the flags it was opened with, so one omitting `--headed` still drives the headed window. Name the session after the site or account, not the task, and prefer the long `--session` over `-s`.

## Headed Or Headless

Assume headless unless the instructions or the user say otherwise, or unless the work is blocked on something only the user can do in the window. A window steals focus, so open one only when it earns the interruption: signing in, approving a prompt, or watching the work happen.

## Profiles

Use a profile whenever the work depends on a login, in this phase or a later one. Without one the profile is in memory and every login dies with the session.

```bash
--browser=chrome --profile="$HOME/.local/share/agent-toolkit/playwright/<profile>"
```

When using profiles, _always_ use `--browser=chrome`. This ensures that the user can use their password manager to log into the website.

`main` is the profile unless a skill names its own. Chrome allows one browser per profile at a time, so an `open` that fails because the profile is in use should reuse the running session rather than start a second. Ignore the `--isolated` flag that failure suggests, which hands back a copy holding none of the logins.

When the profile directory is missing, create it with `./scripts/set-up-profile.rb --profile <name>`, never by hand. It writes the profile with Chrome's own password manager turned off, and the user installs 1Password in it before the first sign-in.

Write `$HOME`, not `~`, which is not expanded after `=`.

## Recipes

| Situation                        | Headed   | Profile |
| -------------------------------- | -------- | ------- |
| Reading a public page            | Headless | None    |
| Taking a look at a page together | Headed   | None    |
| Working behind a login           | Headless | Profile |
| Signing in to a site             | Headed   | Profile |

The combinations can change between phases of a task. For example, you can open a headed session to allow the user to sign in, close it, and then reopen the same session name headless to work.

## Signing In

**You cannot sign in yourself (unless explicitly given credentials by the user).** Logins go through native dialogs and second factors Playwright can't drive. Open a headed window, tell the user exactly what to do in it, and wait.

A persistent profile stays signed in between runs, so check whether the site already has a session before asking the user to sign in again.

## Cleaning Up

Close the session you opened: `playwright-cli --session=<name> close`.

Never run `close-all` or `kill-all`; other sessions belong to other work.
