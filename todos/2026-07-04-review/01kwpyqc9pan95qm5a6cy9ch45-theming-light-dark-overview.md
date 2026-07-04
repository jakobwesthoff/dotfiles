# Overview: the light/dark theming story is one decision, filed as four scattered todos

**Area**: macos-desktop (spans shell-env)
**Files**: .config/ghostty/config, .tmux.conf + .tmux/, .zprofile.d/040_bat.sh + .config/bat/themes/, .zshrc:20, bin/theme.rs

This is a coordination todo. It adds no new findings; it ties the four
existing theming todos to the single decision they all hinge on, so they
get resolved in one pass instead of four inconsistent ones.

## The situation

The environment is dark on every layer that works, while the repo still
carries the remains of a light/dark switching mechanism that no longer
reaches any of those layers:

- **ghostty**: hardcoded Gruvbox Material Hard *dark* palette
  (.config/ghostty/config:43-66), no `theme` key at all.
- **tmux**: sources the dark `my-theme.conf`; the light/dark pair and
  the `AUTO CHANGE MARKER` hook are gone —
  `01kwpmybqn4v3y9q6da2ry0ztq-tmux-orphaned-theme-files.md`.
- **bat**: `BAT_THEME="Nord"` (with a TODO comment "Make switchable with
  the light/dark theme switcher"); vendored gruvbox-material dark+light
  themes never built into the cache —
  `01kwpmybqn4v3y9q6da2ry0ztp-bat-themes-not-wired.md`.
- **fzf session picker**: hardcoded `--color=light`, the one light
  element in an otherwise dark stack —
  `01kwpxt9143d9x8a8c0nwsqzec-fzf-picker-hardcoded-light.md`.
- **theme.rs** (the `light`/`dark`/`toggle` switcher): aborts on its
  first target, every target except .tmux.conf no longer exists, no
  ghostty target —
  `01kwpkwdy8882bx0njs9pxf1pz-theme-rs-broken-targets.md`.
- **nvim**: the only surviving `AUTO CHANGE MARKER` lives in
  .config/nvim/lua/mrjakob/plugins/gruvbox-material.lua (repo grep,
  2026-07-04) — reachable only if theme.rs is repaired.

## The single decision

**Dark-only** or **restore switching**. Each of the four todos offers a
"delete the light half" option and a "rewire it" option; picking
per-todo without deciding globally risks a half-restored switcher (e.g.
tmux toggles but ghostty stays pinned dark).

- If **dark-only**: take the delete option in all four todos (drop
  gruvbox light/dark tmux confs, drop or dark-pin bat themes, drop
  `--color=light`, delete or radically shrink theme.rs and its
  aliases), and remove the nvim marker comment plus the 040_bat.sh TODO
  comment as the last traces.
- If **restore switching**: fix theme.rs targets first (its todo), then
  wire each layer through one mechanism: ghostty natively supports
  `theme = light:<name>,dark:<name>` following the OS appearance
  (installed 1.3.1 docs; note the docs also state explicit
  `background`/`foreground`/`palette` options override the theme, so the
  hardcoded palette block would need to move into theme files),
  tmux/bat/fzf/nvim via the marker convention or equivalent. The
  vendored bat light theme and the tmux light conf become useful again.

## Proposed change

Make the dark-only vs switching decision once, then work through the
four referenced todos accordingly. Do not implement any of them in
isolation before that decision.
