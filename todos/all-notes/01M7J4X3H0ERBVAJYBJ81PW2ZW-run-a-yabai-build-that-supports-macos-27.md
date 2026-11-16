---
title: "Run a yabai build that supports macOS 27"
kind: bug
component: window-manager
status: blocked
origin: review
tags: [tooling]
---
# Run a yabai build that supports macOS 27

Found in the 2026-11-16 review of the single window centering
(`bin/yabai_center_single`). The installed yabai is the Homebrew stable
release v7.1.25 (`brew "koekeishiya/formulae/yabai"` in the `Brewfile`),
and it does not recognise macOS 27 (Golden Gate). On this machine
(macOS 27.0.1) it skips every code path it reserves for macOS 15 and 26,
so parts of yabai silently do not work.

## Problem

v7.1.25 detects the OS with an exact major version match
(`src/workspace.m`, `_workspace_is_macos_version_##name`), and its
newest known version is 26 (Tahoe). On 27 every
`workspace_is_macos_*` check is false, so `src/yabai.c` skips
`mission_control_observe()`, the space created and destroyed
notifications (1327/1328) and the Sequoia+ window notifications (804),
and falls back to notification 1204, which stopped working on Monterey.

Established on 2026-11-16: read in the v7.1.25 source (tag commit
`02de172` in the yabai repository), and reproduced live by registering
loggers on `mission_control_enter` and `mission_control_exit` and
opening and closing Mission Control; neither signal fired.

The fix is upstream commit `b2dc8b4` ("Tahoe fixes should also apply to
Golden Gate"), which is on yabai's master but in no release yet.

## Impact

- `mission_control_enter` and `mission_control_exit` signals never fire.
  The `mission_control_exit` signal in `.yabairc` is therefore dead for
  now.
- Space created and destroyed events and the window notification
  updates meant for macOS 15 and later are missing; their exact effect
  on 27 is not measured.
- The single window centering does not depend on any of these: it is
  driven by `window_resized` and the other window and space signals.

## Suggested fix

Upgrade to the first yabai release that contains `b2dc8b4`
(`brew upgrade koekeishiya/formulae/yabai`), then repeat the Mission
Control logger test. If something visibly breaks before that release,
`brew reinstall --HEAD koekeishiya/formulae/yabai` builds master
instead; the formula builds and ad-hoc signs it.

## Decisions

- 2026-11-16, user: deferred; filed as this todo instead of switching to
  a HEAD build right away.

## Relations

- Blocked by: a yabai release newer than v7.1.25 that contains upstream commit `b2dc8b4`
