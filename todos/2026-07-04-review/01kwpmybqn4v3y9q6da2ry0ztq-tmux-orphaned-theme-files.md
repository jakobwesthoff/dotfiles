# Orphaned tmux theme files; tmux light/dark switching lost its marker

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.tmux/gruvbox-dark-theme.conf, /Users/jakob/dotfiles/.tmux/gruvbox-light-theme.conf, /Users/jakob/dotfiles/.tmux.conf:86-90
**Related todo**: 01kwpkwdy8882bx0njs9pxf1pz-theme-rs-broken-targets.md (theme.rs side of the same mechanism)

## Current state

`.tmux/` contains three theme files:

```
gruvbox-dark-theme.conf   (last modified Mar  6 2025)
gruvbox-light-theme.conf  (last modified Mar  6 2025)
my-theme.conf             (last modified Jun 13, current)
```

`.tmux.conf` sources only one of them:

```
#############
## THEMES
#############

source-file ~/.tmux/my-theme.conf
```

Repo-wide grep for `gruvbox-dark-theme|gruvbox-light-theme|my-theme`
(2026-07-04): the only hit is that `source-file` line. Nothing references
the two gruvbox files.

`bin/theme.rs` (aliases `light`/`dark`/`toggle`) switches the tmux theme by
finding the comment `AUTO CHANGE MARKER: LIGHT/DARK` in `~/.tmux.conf` and
replacing "dark"/"light" on the following line, then running
`tmux source ~/.tmux.conf`. The dark/light pair of theme files is the
counterpart of that mechanism: the marker line would toggle between
`gruvbox-dark-theme.conf` and `gruvbox-light-theme.conf`.

## Problem

- `.tmux.conf` contains no `AUTO CHANGE MARKER` line (grep count: 0), and
  the sourced filename `my-theme.conf` contains neither "dark" nor
  "light", so theme.rs's dark/light replacement can never match. The tmux
  half of the light/dark switcher is silently disconnected.
- The two gruvbox theme files are unreachable from any config and have not
  been touched since the my-theme.conf redesign.

## Grounding

- `grep -c "MARKER" .tmux.conf` → 0
- theme.rs marker mechanism: bin/theme.rs:59-109 (`Marker::apply`
  scans for `AUTO CHANGE MARKER: LIGHT/DARK`, replaces dark↔light on the
  next line), bin/theme.rs:249 (`TMux::new("~/.tmux.conf")`)
- Reference grep documented above; file dates from `ls -la .tmux/`.

## Proposed change

Decide the direction for tmux theming:

- **Dark-only (current reality)**: `git rm .tmux/gruvbox-dark-theme.conf
  .tmux/gruvbox-light-theme.conf` and drop the `TMux` changer from
  theme.rs (covered by the related todo).
- **Restore switching**: split `my-theme.conf` into dark/light variants
  (e.g. `my-theme-dark.conf` / `my-theme-light.conf`), put the
  `# AUTO CHANGE MARKER: LIGHT/DARK` comment directly above the
  `source-file` line in .tmux.conf, and point it at the dark variant. Then
  the existing theme.rs mechanism works again, and the old gruvbox files
  can still be deleted.
