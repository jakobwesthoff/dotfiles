# bin/theme.rs is broken: every target config except .tmux.conf no longer exists

**Area**: shell-env
**File**: /Users/jakob/dotfiles/bin/theme.rs (main(), changer list at the bottom)
**Related**: /Users/jakob/dotfiles/.zshrc.d/050_aliases.sh:53-55 (`light`/`dark`/`toggle` aliases)

## Current state

`theme.rs` applies a light/dark theme switch to a fixed list of files:

```rust
~/.config/alacritty/alacritty.toml
~/.config/wezterm/wezterm.lua
~/.config/nvim/lua/plugins/colorscheme.lua
~/.tmux.conf                                  (via TMux/Marker)
~/Library/Application Support/Code/User/settings.json  (VSCode)
```

Each `Marker::apply` opens the file with `?`-propagation, and `main()` aborts
on the first `Err`.

## Problem

Verified on this machine (2026-07-04):

- `~/.config/alacritty/alacritty.toml` — does not exist
- `~/.config/wezterm/wezterm.lua` — does not exist (wezterm config was removed
  from the repo in commit 2274eea "Removed wezterm config as I by now only
  use ghostty")
- `~/.config/nvim/lua/plugins/colorscheme.lua` — does not exist; the nvim file
  carrying the `AUTO CHANGE MARKER: LIGHT/DARK` marker now lives at
  `.config/nvim/lua/mrjakob/plugins/gruvbox-material.lua`
- `~/Library/Application Support/Code/User/settings.json` — does not exist,
  VS Code is not installed (`/Applications/Visual Studio Code.app` absent,
  `command -v code` fails)
- `~/.tmux.conf` — exists (only working target)

Since the first changer (alacritty) already fails to open its file, the whole
run aborts before touching anything. The `light`, `dark` and `toggle` aliases
are therefore dead. There is also no changer for ghostty, the terminal
actually in use (`.config/ghostty/config` exists in the repo).

## Grounding

```
$ ls ~/.config/alacritty/alacritty.toml ~/.config/wezterm/wezterm.lua \
     ~/.config/nvim/lua/plugins/colorscheme.lua \
     "~/Library/Application Support/Code/User/settings.json"
ls: cannot access ... No such file or directory   (all four)
$ grep -rl "AUTO CHANGE MARKER" ~/dotfiles
.config/nvim/lua/mrjakob/plugins/gruvbox-material.lua
bin/theme.rs
$ command -v code   -> not found
```

## Proposed change

Update the changer list to the current reality:

1. Remove alacritty, wezterm, and VSCode changers (or make each changer
   tolerate a missing file by skipping instead of aborting — that would also
   make the tool robust against future config moves).
2. Point the nvim Marker at `~/.config/nvim/lua/mrjakob/plugins/gruvbox-material.lua`.
3. Add a ghostty changer. Verified via `ghostty +show-config --default
   --docs`: the `theme` key accepts `light:theme-name,dark:theme-name` and
   then follows the desktop appearance automatically, which may replace the
   Marker approach for ghostty entirely; alternatively a Marker-style entry
   in `.config/ghostty/config` fits the existing pattern (the repo's ghostty
   config currently has an empty `theme =` line).

## Correction (second pass)

The parenthetical in item 3 is wrong: `.config/ghostty/config` contains
no `theme` line at all (`grep -n "theme" .config/ghostty/config` → no
matches, 2026-07-04). The dark palette is hardcoded via
`background`/`foreground`/`palette` entries (lines 43-66), and those
explicit options beat a theme: the installed 1.3.1 docs state "Any
additional colors specified via background, foreground, palette, etc.
will override the colors specified in the theme." A `theme`-based
changer therefore also requires removing/relocating the hardcoded
palette block; the alternative is a Marker-style toggle of the palette
block itself. Related overview:
01kwpyqc9pan95qm5a6cy9ch45-theming-light-dark-overview.md.
