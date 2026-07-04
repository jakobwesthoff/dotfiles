# `sudo yabai --load-sa` fails on every yabai start: SIP enabled, no sudoers entry, requirement undocumented

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.yabairc:17-18

## Current state

```sh
sudo yabai --load-sa
yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
```

The comment block above (lines 3-15) says "for this to work you must
configure sudo such that it will be able to run the command without
password" and links the yabai wiki.

## Problem

The scripting addition cannot load on this machine at all, and the sudo
configuration the lines depend on does not exist:

- `csrutil status` (2026-07-04): "System Integrity Protection status:
  enabled." The scripting addition requires partially disabled SIP
  (yabai man page notes this for the SA-dependent options; the wiki's
  install instructions require `csrutil enable --without fs --without
  debug --without nvram`). With SIP fully enabled, `yabai --load-sa`
  cannot inject into Dock.app even with working passwordless sudo.

- `/private/etc/sudoers.d/` is empty (`ls -la`, 2026-07-04).
- Repo-wide grep for "sudoers": no hits outside this todo folder.
  initial_macos_setup.sh installs and starts the yabai service
  (lines 233-237) but never creates the sudoers entry; README.md does
  not mention it either.

Consequence, verified in `/tmp/yabai_jakob.err.log` (2026-07-04): all 12
config runs since boot logged
`sudo: a terminal is required to read the password; either use the -S
option to read from standard input or configure an askpass helper` and
`sudo: a password is required`. The scripting addition is never loaded
by the config (Touch ID pam does not help: launchd context has no
terminal). `lsof` on the Dock process shows no yabai payload loaded.

Impact on the active config: the only setting in use that depends on
this machinery is `window_shadow off` (.yabairc:74) — the yabai man
page marks it "System Integrity Protection must be partially disabled",
so it does nothing here. The commented-out space-switching binds in
.skhdrc:174-177 name the same dependency ("Requires scripting additions
though"). Everything else in .yabairc and .skhdrc (bsp layout, gaps,
warp/insert/mirror/float bindings) works without SA, which is why the
failure has gone unnoticed.

On a fresh machine the same state reproduces: Brewfile installs yabai,
initial_macos_setup.sh starts the service, and load-sa fails silently
from the first boot.

## Proposed change

Decide the direction:

- **Drop it (fits the current machine)**: delete .yabairc:17-18 and
  `window_shadow off` (accepting shadows), since with SIP enabled the
  scripting addition can never load and no active binding or setting
  needs it. The failing sudo lines and the dock_did_restart signal then
  stop producing errors.
- **Or commit to the SA**: partially disable SIP per the yabai wiki,
  create the sudoers entry (`/private/etc/sudoers.d/yabai` with the
  sha256-pinned `<user> ALL=(root) NOPASSWD: sha256:<hash> <path>/yabai
  --load-sa` line), and add the sudoers step to initial_macos_setup.sh
  so a fresh install and yabai upgrades are covered (the hash changes
  per binary; the wiki documents regenerating it). This is only worth
  it if the SA features (fast space switching, window_shadow off,
  opacity) are actually wanted.
