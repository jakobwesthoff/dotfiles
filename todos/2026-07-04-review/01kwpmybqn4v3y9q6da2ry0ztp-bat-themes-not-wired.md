# Vendored bat themes are unusable: cache never built, BAT_THEME set to Nord

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.config/bat/themes/ (three .tmTheme files)
**Related**: /Users/jakob/dotfiles/.zprofile.d/040_bat.sh (theme selection)

## Current state

The repo vendors three bat themes, symlinked into place via stow
(`~/.config/bat` → dotfiles):

```
gruvbox-dark-hard.tmTheme
gruvbox-material-dark-hard.tmTheme
gruvbox-material-light-hard.tmTheme
```

There is no bat config file (`bat --config-file` points to
`~/.config/bat/config`, which does not exist). Theme selection happens via
`.zprofile.d/040_bat.sh`:

```sh
# Configure the theme used by bat (a better cat)
# TODO: Make switchable with the light/dark theme switcher
export BAT_THEME="Nord"
```

## Problem

The vendored themes are dead weight in their current state:

1. bat only picks up custom themes from the config dir after
   `bat cache --build`; `~/.cache/bat` does not exist on this machine, so
   the cache was never built.
2. Even if it were built, `BAT_THEME="Nord"` selects a built-in theme, so
   nothing references the vendored files.

Meanwhile the terminal (ghostty), tmux theme, and nvim all use Gruvbox
Material Hard colors, which is what the vendored
`gruvbox-material-*-hard` themes match.

## Grounding

- `bat --version` → bat 0.26.1
- `ls ~/.cache/bat` → "No such file or directory" (2026-07-04)
- `bat --list-themes` (2026-07-04) contains built-ins `Nord`,
  `gruvbox-dark`, `gruvbox-light`, but none of the three vendored names
  (`gruvbox-dark-hard`, `gruvbox-material-dark-hard`,
  `gruvbox-material-light-hard`)
- Repo-wide grep: no script or config in the repo runs `bat cache` or
  references the vendored theme names.
- Ghostty config comment ".config/ghostty/config:43": "Colorscheme
  (Gruvbox Material Hard dark)" with matching palette values.

## Proposed change

Decide one of:

- **Wire it up**: add `bat cache --build` to machine bootstrap
  (initial_macos_setup.sh installs/wires other tools) and set
  `BAT_THEME="gruvbox-material-dark-hard"` in 040_bat.sh (bat registers a
  theme under its file basename). The light variant is already vendored
  for the light/dark switcher mentioned in the 040_bat.sh TODO and could
  be driven by bin/theme.rs later.
- **Or delete**: if Nord is the settled choice, `git rm` the three
  .tmTheme files (and the now-empty `.config/bat` tree).
