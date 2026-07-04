# tmux session picker hardcodes fzf `--color=light` while the whole environment is dark

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.zshrc:20
**Related todo**: 01kwpkwdy8882bx0njs9pxf1pz-theme-rs-broken-targets.md (the theme switcher that would need to own this)

## Current state

```zsh
fzf_options=("--no-sort" "--layout=reverse-list" "--border=sharp" "--color=light")
```

This is the fzf invocation shown on every terminal start (the tmux
session picker). There is no `FZF_DEFAULT_OPTS` anywhere in the repo, so
this is the only place an fzf color scheme is forced; all other fzf uses
(`kcfg`, `yoink`, ...) use fzf's default (dark) scheme.

## Problem

The active environment is dark on every layer checked (2026-07-04):

- ghostty: `background = #1d2021` (.config/ghostty/config:44)
- tmux: `.tmux/my-theme.conf` uses the gruvbox-material dark palette
  (`BG="#32302F"`, `BLACK="#1d2021"`)

`--color=light` selects fzf's light-background base scheme, so the one
fzf UI that appears on every terminal start is styled for the opposite
background from everything around it.

Pass 1 treated the flag as a preference. Taken together with the theme
system it becomes a defect in waiting: the repo has a light/dark
switcher (`bin/theme.rs`, `light`/`dark`/`toggle` aliases) whose broken
target list is already filed for repair. `.zshrc` is not among its
targets, so after that repair the picker would still be pinned to light
— the same class of orphaned hardcode as `BAT_THEME` (filed separately
in the bat-themes todo).

## Proposed change

Either drop `--color=light` (fzf's default tracks a dark background,
matching the current setup), or make the line switchable by the theme
system, e.g. the existing `AUTO CHANGE MARKER: LIGHT/DARK` marker
convention with a `.zshrc` Marker entry added to `bin/theme.rs`'s
changer list when that todo is implemented.
