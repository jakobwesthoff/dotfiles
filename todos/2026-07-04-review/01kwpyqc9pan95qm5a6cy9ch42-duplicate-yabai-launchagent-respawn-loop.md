# Stale yabai LaunchAgent from pre-rename versions makes the current one respawn-loop every ~30 s

**Area**: macos-desktop
**File**: ~/Library/LaunchAgents/com.koekeishiya.yabai.plist and com.asmvik.yabai.plist (machine state, not in the repo; repo-side counterpart is initial_macos_setup.sh:233-237)

## Current state

Two LaunchAgents both start `/opt/homebrew/bin/yabai` with `RunAtLoad`
and `KeepAlive` (SuccessfulExit=false, Crashed=true), writing to the same
log files `/tmp/yabai_jakob.{out,err}.log`:

- `com.koekeishiya.yabai.plist` (file date Mar 7 2025) — created by
  `yabai --install-service` of an older yabai. Upstream renamed the
  service label between v7.1.16 and v7.1.18
  (src/misc/service.h `_NAME_YABAI_PLIST`: `com.koekeishiya.yabai`
  through v7.1.16, `com.asmvik.yabai` from v7.1.18 on; checked against
  the koekeishiya/yabai tags on 2026-07-04).
- `com.asmvik.yabai.plist` (file date Mar 10 this year) — the label the
  installed yabai 7.1.24 creates and manages with its
  `--install/--uninstall/--restart-service` commands.

A yabai upgrade past the rename left both plists in place; only one
yabai instance can hold the lock file.

## Problem

The stale-label agent currently holds the lock and the *current*-label
agent loses, exits 1, and gets relaunched by launchd indefinitely:

- `launchctl list` (2026-07-04): `com.koekeishiya.yabai` PID 73253
  (running instance); `com.asmvik.yabai` PID `-`, last exit status 1.
- `/tmp/yabai_jakob.err.log` contains 131,563 lines of
  `yabai: could not acquire lock-file! abort..` (`grep -c`,
  2026-07-04). Uptime is 43 days, so one respawn roughly every 28
  seconds, still ongoing (log mtime 18:10 today); the file has grown to
  5.8 MB.

Side effects: the spam buries the real yabai errors in the same log
(the removed border options and the failing `sudo yabai --load-sa`,
both filed separately), and `yabai --restart-service` /
`--stop-service` from the installed binary manage the *asmvik* label,
i.e. they do not control the instance that is actually running.

## Proposed change

Remove the stale old-label agent and let the current one take over
(same binary, same config):

```
launchctl bootout gui/501/com.koekeishiya.yabai
rm ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
```

After the bootout, the looping `com.asmvik.yabai` agent acquires the
lock on its next respawn attempt; `launchctl kickstart
gui/501/com.asmvik.yabai` avoids waiting for it. Truncating
`/tmp/yabai_jakob.err.log` afterwards makes future errors visible.
