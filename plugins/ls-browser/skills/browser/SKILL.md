---
name: browser
description: Use when a task needs a browser, such as reading a page, filling a form, taking a look at something, or reaching anything behind a login. Always run this skill before the `claude-in-chrome` or `playwright-cli` skills.
---

# Browser

## Claude Duet

If you're running in Claude Duet, use its built-in browser and follow Duet's own rules for it, including how to sign in. Never use Playwright in Duet: it has no browser to launch there.

## Everywhere Else

Drive the browser through Claude in Chrome. **REQUIRED:** Use the `claude-in-chrome` skill. It works in the user's own Chrome, in a window they can see, with the extension's safety checks and the user's existing logins.

Use Playwright only when a skill or the user explicitly tells you to. **REQUIRED:** Read [Playwright](references/playwright.md) before using it.

If Claude in Chrome isn't connected or a site blocks it, stop and tell the user. Never fall back to Playwright on your own.

## Rationalizations

| Thought                                     | Reality                                                                    |
| ------------------------------------------- | -------------------------------------------------------------------------- |
| "Headless won't interrupt the user"         | Claude in Chrome is the default. Playwright needs an explicit instruction. |
| "The Playwright MCP tools are already here" | Being loaded isn't being told to. Use Claude in Chrome.                    |
| "Chrome isn't responding, Playwright works" | Stop and tell the user. Don't switch paths on your own.                    |
| "The Chrome tools are listed in Duet too"   | Only Duet's sign-in rules reach for Chrome. Use the cloud browser.         |
