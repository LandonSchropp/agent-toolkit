---
description: Use when creating or editing a macOS LaunchAgent for a recurring or scheduled script. Covers plist structure, PATH resolution, multiple trigger times, the reload workflow, and which behaviors launchd already handles so they don't need to be rebuilt.
---

# Schedule

## Where things live

- Plist: `Library/LaunchAgents/com.landonschropp.<name>.plist` in the `~/.dotfiles` repo, rcup-linked to `~/Library/LaunchAgents`
- Logs: `~/Library/Logs/com.landonschropp.<name>/{stdout,stderr}.log`, set via `StandardOutPath`/`StandardErrorPath`

## Plist template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.landonschropp.NAME</string>
    <key>ProgramArguments</key>
    <array>
      <string>/bin/zsh</string>
      <string>-lc</string>
      <string>COMMAND</string>
    </array>
    <key>StandardOutPath</key>
    <string>/Users/landon/Library/Logs/com.landonschropp.NAME/stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/landon/Library/Logs/com.landonschropp.NAME/stderr.log</string>
    <key>StartCalendarInterval</key>
    <array>
      <dict>
        <key>Hour</key>
        <integer>7</integer>
      </dict>
    </array>
  </dict>
</plist>
```

**REQUIRED:** `ProgramArguments` MUST run the command through `/bin/zsh -lc "COMMAND"`, never bare. launchd jobs skip the login shell, so `PATH` is missing `~/.local/bin` and everything rcup manages. `-lc` sources the login profile, putting commands like `sync-repositories` on `PATH`.

## Multiple trigger times

`StartCalendarInterval` is an array of dicts, not a single time. Each dict is one full trigger spec — `Hour`, `Minute`, `Day`, `Weekday`, `Month`, any subset; omitted fields are wildcards. The job fires whenever any dict fully matches. For "twice a day," add a second dict differing only in `Hour`. `Hour` isn't special — for a specific weekday or minute, set that field on the dict that needs it.

## Reload after editing

```bash
plutil -lint <plist>
~/.dotfiles/bin/set-up-launchd
```

Reloads every LaunchAgent, not just the edited one — fine, since every setup script in `~/.dotfiles` is idempotent.

## What launchd already handles — don't rebuild it

- **No overlapping runs of the same job.** Verified by testing: two triggers a minute apart, against a job that slept 90s, produced exactly one PID — the second was dropped, not queued. Don't add `flock`/`lockf` for this.
- **Missed runs are deferred, not dropped.** If the Mac is asleep at trigger time, `man launchd.plist` documents that it fires the job once on wake instead, coalescing everything missed in between into one catch-up run. No flag makes it drop instead.

So guard the _script_, not the schedule: make it idempotent (safe to run twice with no ill effect) rather than adding lock files or hour-checking guards to the plist.

## Verify, don't assume

launchd docs and blog posts disagree on overlap and catch-up behavior. When it matters, test it directly: a throwaway `/tmp` plist, unique `Label`, trigger a minute or two out, command logs a timestamp+PID and sleeps past the next trigger. `launchctl bootstrap gui/$(id -u) /tmp/test.plist`, wait, read the log, then `bootout` and delete the scratch files.

## Rationalizations

| Thought                                              | Reality                                                                                                                        |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| "I'll just run the bare command in ProgramArguments" | It won't find anything outside `/usr/bin`. Always wrap in `/bin/zsh -lc`.                                                      |
| "I should add a lock file so it can't run twice"     | launchd already guarantees this for a single Label. Verify before adding one.                                                  |
| "I'll guard against catch-up runs firing late"       | That trades a documented, harmless behavior for the script going stale for days if missed. Make the script idempotent instead. |
