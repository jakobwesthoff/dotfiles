# Ghostty: `shell-integration = none` makes the configured ssh features inert

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.config/ghostty/config:79-80 and 102-103

## Current state

```
# cursor settings
shell-integration = none          (line 80)
...
# try to set terminfo or fallback to xterm-256color for ssh
shell-integration-features = ssh-terminfo,ssh-env   (line 103)
```

No file in the dotfiles repo manually sources the Ghostty shell
integration script (repo-wide case-insensitive grep for "ghostty" finds
only comments/Brewfile/dock-setup references, no sourcing).

## Problem

`shell-integration-features` only takes effect when the integration script
is loaded. With `shell-integration = none` and no manual sourcing, the
`ssh-terminfo` and `ssh-env` features (the stated intent of line 102) never
activate: ssh to hosts without the `xterm-ghostty` terminfo keeps breaking
TERM, and no terminfo auto-install happens.

Also lost with integration fully disabled (per the installed docs): working
directory inheritance for new tabs/splits, prompt marking for
`jump_to_prompt`, no-confirmation close when sitting at a prompt, and
better repaint on resize.

## Grounding

- `ghostty +version` → 1.3.1
- `ghostty +show-config --default --docs` (installed binary, 2026-07-04):
  - shell-integration-features: "These require our shell integration to be
    loaded, either automatically via shell-integration or manually."
  - shell-integration docs list the features above as what integration
    enables; `none` = "Do not do any automatic injection. You can still
    manually configure your shell to enable the integration."
  - `ssh-env` / `ssh-terminfo`: "Available since: 1.2.0"
- Live check 2026-07-04 in an interactive zsh started from the current
  dotfiles: `whence -w ssh` → `ssh: command` (no integration wrapper),
  `typeset -f _ghostty_deferred_init` → not defined. Ghostty exports
  `GHOSTTY_SHELL_FEATURES=cursor:steady,path,ssh-env,ssh-terminfo,title`
  into the environment, but nothing consumes it.
- The section comment "# cursor settings" (line 79) sits directly above
  `shell-integration = none` and the block/no-blink cursor settings
  (lines 81-82), indicating the integration was disabled to keep a steady
  block cursor. The docs list `cursor` ("Set the cursor to a bar at the
  prompt") as an individually disableable feature.

## Proposed change

If the goal of `none` was only the cursor behavior, re-enable integration
and opt out of the cursor feature instead:

```
shell-integration = detect          # or delete the line; detect is default
shell-integration-features = no-cursor,ssh-terminfo,ssh-env
```

This makes the ssh features real and restores cwd inheritance, prompt
jumping, and prompt-aware close confirmation, while keeping the steady
block cursor. After changing, verify prompt rendering still behaves with
powerlevel10k (p10k precmd hooks are active in the current shell).

Alternative if integration is unwanted for another reason: keep `none` and
manually source
`$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration` from a
zshrc.d snippet; otherwise delete line 102-103, since they do nothing.
