# initial_macos_setup.sh logic nits from the second-pass audit (grouped)

**Area**: shell-env
**File**: /Users/jakob/dotfiles/initial_macos_setup.sh

Two small findings from the end-to-end logic read. The existing-clone
gap and the dead pgrep guard are already filed
(01kwpkwdy8882bx0njs9pxf1q8); this file collects what remains.

## 1. Keyboard defaults are written before System Settings is quit

The script's protection against System Settings overwriting freshly
written preferences is the quit at line 300:

```bash
osascript -e 'tell application "System Settings" to quit'
info "Closed System Settings to prevent conflicts"
```

But the Keyboard section (lines 263-269: `InitialKeyRepeat`,
`KeyRepeat`, `ApplePressAndHoldEnabled`) runs *before* it — and the
"Manual settings" section (lines 277-292) explicitly sends the user
into System Settings in between. By the script's own rationale, the
keyboard writes are unprotected: an open System Settings can flush its
cached values over them when it later quits. Fix by moving the Keyboard
section after the quit (or quitting System Settings once at the top of
the defaults work, before line 263).

## 2. `ssh-add` failure aborts the script silently

Line 70, in the keys-found branch:

```bash
ssh-add --apple-use-keychain 2>/dev/null
```

The script runs under `set -euo pipefail` (line 2). If `ssh-add` fails
(passphrase prompt cancelled, agent unavailable), `set -e` terminates
the whole script, and because stderr is discarded there is no output at
all — the run just stops after "ok SSH keys found". Append `|| true`
(best-effort, matching the `2>/dev/null` intent) or drop the
suppression so a fatal stop at least explains itself.

## Verified healthy in the same audit (no action)

- Ordering is sound: mas, skhd/yabai/asimeow service setup all run
  after `brew bundle install`, which installs them.
- The asimeow guard pattern `grep -q "asimeow.*scheduled"` matches the
  actual `brew services list` status on this machine ("scheduled").
- Dock `persistent-apps` targets `/Applications/Ghostty.app` and
  `/Applications/Zen.app` — both exist.
- Re-run idempotency: every mutating step is either guarded
  (Touch ID, mas, services, clone) or a constant `defaults write`;
  the Dock `persistent-apps` reset to exactly three apps on every run
  is the one destructive re-run effect, and it matches the script's
  opinionated-setup purpose.
