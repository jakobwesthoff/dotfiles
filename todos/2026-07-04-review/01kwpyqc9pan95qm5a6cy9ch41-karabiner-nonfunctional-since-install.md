# Karabiner-Elements is non-functional: driver extension never approved, grabber not running

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.config/karabiner/karabiner.json (entire file), Brewfile:252 (`cask "karabiner-elements"`)

## Current state

Karabiner-Elements 15.3.0 is installed and its config is stowed
(`~/.config/karabiner` → dotfiles). karabiner.json configures:

- one complex-modification rule: Ctrl+Backspace → Option+Backspace
- per-device simple modifications for four devices (vendor/product
  1241/41521 with heavy modifier remapping, 1452/636 with caps→ctrl plus a
  grave_accent_and_tilde ↔ non_us_backslash swap, 1452/34304 ignored,
  13364/481 with the same key swap)
- `fn_function_keys` overrides for f3-f6, f9

## Problem

None of it is active. The remapping pipeline is down at the OS-permission
level, and by the log evidence it has been down since the March 2025
install (karabiner.json last modified Mar 6 2025; failure warnings start
Mar 7 2025):

- The DriverKit virtual HID device extension was never approved:
  `systemextensionsctl list` (2026-07-04) shows
  `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice (1.8.0/1.8.0)` in state
  `[activated waiting for user]`, with the "enabled" column empty.
- `karabiner_grabber` is not running: `pgrep -fl karabiner` shows only
  `karabiner_session_monitor`, `karabiner_console_user_server`, and a
  `Karabiner-VirtualHIDDevice-Manager forceActivate` process; `launchctl
  list` shows `org.pqrs.service.agent.karabiner_grabber` registered with
  no PID.
- `~/.local/share/karabiner/log/grabber_agent.log` logs
  `device_open_forbidden` on every start since 2025-03-07 (15.3.0).
- `console_user_server.log` spams
  `grabber_client connect_failed: No such file or directory` every ~1.1 s,
  rotating a 256 KB log roughly every 45 minutes (three rotated logs from
  today alone, 2026-07-04 16:33/17:17/18:00).

The critical remap survives without Karabiner: macOS-native modifier
mapping is set globally (`defaults -currentHost read -g` shows
`com.apple.keyboard.modifiermapping.0-0-0` mapping Caps Lock
(0x700000039) → Control (0x7000000E4)). The Ctrl+Backspace rule, the key
swaps, and the fn-key overrides are simply not in effect.

Of the four configured devices, only 13364/481 matches currently
connected hardware (`hidutil list`, 2026-07-04, shows it as "Keychron
Q11"); the internal keyboard appears there as vendor 0x0 via FIFO
transport, and the 1241/41521 board is not connected. Whether the
1452/636 entry matches this machine cannot be checked while the grabber
is down.

## Grounding

All commands run 2026-07-04 on this machine; outputs quoted above:
`systemextensionsctl list`, `pgrep -fl karabiner`, `launchctl list`,
`hidutil list`, `defaults -currentHost read -g`, plus the two log files
under `~/.local/share/karabiner/log/`.

## Proposed change

Decide whether Karabiner is still wanted:

- **Fix**: approve the driver extension (System Settings → General →
  Login Items & Extensions → Driver Extensions) and grant Input
  Monitoring to the Karabiner grabber, then verify the Ctrl+Backspace
  rule works. Before doing so, check that Karabiner's caps→ctrl device
  mappings do not double up with the existing macOS-native global
  caps→ctrl mapping.
- **Or remove**: uninstall the cask, `git rm` `.config/karabiner/`
  (including the two imported rule collections under
  `assets/complex_modifications/`, 150 KB, referenced by nothing in the
  active profile), and keep the native modifiermapping. This also stops
  the permanent log churn.

Either way, initial_macos_setup.sh currently installs the cask via
Brewfile but has no step (not even a manual-settings prompt, which the
script uses for other unautomatable settings at lines 277-292) for the
two required permission grants, so a fresh machine reproduces exactly
this broken state.
