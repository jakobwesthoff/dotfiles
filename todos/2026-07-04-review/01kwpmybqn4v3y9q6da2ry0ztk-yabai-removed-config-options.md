# .yabairc sets 8 config options that yabai 7.1.24 no longer supports

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.yabairc:68-100 (the chained `yabai -m config` call)

## Current state

The single chained `yabai -m config` invocation includes these keys:

```
    window_topmost               off            \   (line 73)
    active_window_border_color   0xffFFBF29     \   (line 80)
    normal_window_border_color   0xaaE4E4E4     \   (line 81)
    window_border_width          4              \   (line 83)
    window_border_radius         12             \   (line 84)
    window_border_blur           off            \   (line 85)
    window_border_hidpi          on             \   (line 86)
    window_border                on             \   (line 87)
```

## Problem

All 8 keys are rejected by the installed yabai. They are dead lines that
produce an error per key when the config runs. Window borders are already
provided by JankyBorders, launched at .yabairc:106
(`borders active_color=0xFFF3B23E ... &`), and a single borders instance is
running (pgrep confirmed, PID matching those args).

The failure is non-fatal: yabai continues applying the remaining pairs of
the chained call. Verified live on 2026-07-04 that values coming *after*
the invalid keys are in effect: `window_shadow` = off, `layout` = bsp,
`window_gap` = 10, `split_type` = auto, `mouse_drop_action` = swap.

## Grounding

- `yabai --version` → `yabai-v7.1.24`
- Each key queried against the installed binary on 2026-07-04, e.g.:
  - `yabai -m config window_topmost` → `unknown command 'window_topmost' for domain 'config'`
  - `yabai -m config window_border` → `unknown command 'window_border' for domain 'config'`
  - same error for `active_window_border_color`, `normal_window_border_color`,
    `window_border_width`, `window_border_radius`, `window_border_blur`,
    `window_border_hidpi`
- Still-valid neighbors verified: `insert_feedback_color` → `0xffd75f5f`,
  `window_animation_duration` → `0.000000`
- yabai CHANGELOG v6.0.0 (2023-10-10): "Config option `window_topmost` has
  been removed [#1887]" —
  https://github.com/koekeishiya/yabai/blob/master/CHANGELOG.md
- JankyBorders README (https://github.com/FelixKratz/JankyBorders): "If a
  `borders` process is already running, invoking a new `borders` instance
  with any combination of the available options will update the properties
  of the already running instance." — the `&`-launch from .yabairc is one of
  the README's recommended startup methods and is safe across yabai restarts.

## Proposed change

Delete the 8 listed key/value lines from the chained `yabai -m config`
call in .yabairc. Border look stays as-is via the existing JankyBorders
launch on line 106.

Optional cleanup in the same pass: the fully commented-out duplicate of the
config block (lines 21-66) repeats the removed border options and old
padding values; it can be dropped since the live block directly below is
the maintained copy.
