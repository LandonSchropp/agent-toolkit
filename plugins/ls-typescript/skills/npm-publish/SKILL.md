---
name: npm-publish
description: Use when publishing or releasing a new version of an npm/pnpm/yarn/bun package to the registry. Covers package-manager detection, semver bump selection, tagging, pushing, scoped-package access, authentication, and one-time passwords (OTP).
---

## Pre-flight checks

Do these BEFORE bumping the version — fail before creating a commit and tag, not after.

1. **Authenticated.** Run `npm whoami`. A `401` means you're not logged in: STOP and resolve it before anything else. `npm login` is interactive (browser-based), so you cannot run it for the user — ask them to (in Claude Code, `! npm login`), then re-check `npm whoami`. Don't bump or commit until this passes.
2. **Clean working tree.** Run `git status`. Commit or stash changes first.
3. **Tests and lint pass.** Run the project's test and lint scripts. NEVER publish a red build.
4. **Right branch, up to date.** Releases normally happen from `main`.

## Package manager

Detect from the lockfile (first match wins) and use that row's commands:

| Lockfile                      | Bump                    | Publish        |
| ----------------------------- | ----------------------- | -------------- |
| `yarn.lock`                   | `yarn version --<bump>` | `yarn publish` |
| `pnpm-lock.yaml`              | `pnpm version <bump>`   | `pnpm publish` |
| `bun.lock` / `bunfig.toml`    | `npm version <bump>`    | `bun publish`  |
| `package-lock.json` (or none) | `npm version <bump>`    | `npm publish`  |

Both steps only touch `package.json` and the registry, so `npm version` / `npm publish` are safe fallbacks when a manager's syntax differs (e.g. Yarn Berry publishes with `yarn npm publish`).

## Bump, push, and publish

1. **Bump.** Pick the level — major (breaking), minor (new backward-compatible feature), or patch (fix/internal only); ask if unsure. Run the bump command for your manager. It edits `package.json`, commits, and creates a `v<version>` tag.
2. **Push** the commit and tag: `git push --follow-tags`. REQUIRED: `--follow-tags`, or the tag stays on your machine.
3. **Publish** with your manager's command plus `--access public`. REQUIRED for scoped packages (`@scope/name`): without it npm publishes privately and rejects a free account.
4. **Verify:** `npm view <package-name> version`.

## Troubleshooting publish failures

- **`404` on a scoped package** is not "deleted" or "wrong name." The registry returns `404 ... PUT .../@scope%2fname` when you lack write access — it masks an auth failure. Re-check `npm whoami`.
- **`EOTP`** (2FA enabled): add `--otp=<code>` to the publish command. Codes expire in ~30 seconds — ask the user for it and run publish IMMEDIATELY in the same turn, don't gather it then do other work. A repeat `EOTP` means it expired; ask for a fresh one.
- **`EPUBLISHCONFLICT`**: that version already exists and can't be overwritten. This usually means the local branch is behind — the version was already bumped and published on the default branch. Don't just bump again on stale history; offer to rebase onto the latest default branch first, then bump from there.
- **Bumped and tagged but publish failed**: keep the commit and tag, fix the cause, and re-run only the publish — do not bump again.
