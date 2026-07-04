# Ghostty: explicit `font-feature = calt/clig/liga` re-enables features that are already on by default

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.config/ghostty/config:4-7

## Current state

```
# Enable ligatures for all fonts configured below
font-feature = "calt"
font-feature = "clig"
font-feature = "liga"
```

## Problem / opportunity

The three lines (and the comment's implication that ligatures need
enabling) are redundant. Ghostty enables these ligature features by
default:

- Maintainer statement (mitchellh,
  https://github.com/ghostty-org/ghostty/discussions/8312): "Ligatures
  by default is a defining characteristic of Ghostty. We offer a
  configuration to disable it." — `calt`, `liga`, `clig` are enabled by
  default (only `dlig` is off, being spec-defined as opt-in).
- Source at the installed version's tag
  (src/font/shaper/feature.zig, v1.3.1): `default_features` hardcodes
  `liga` on ("These features are hardcoded to always be on by
  default"), and src/font/shaper/coretext.zig appends user features on
  top of the defaults; `calt`/`clig` are default-on OpenType features
  applied by the shaper itself.
- Installed docs (`ghostty +show-config --default --docs`, Ghostty
  1.3.1): default is `font-feature =` (empty), and the docs only
  describe *disabling* ligatures ("To disable programming ligatures,
  use `-calt`... To generally disable most ligatures, use `-calt,
  -liga, -dlig`").

Harmless at runtime (re-enabling an enabled feature is a no-op), but the
lines suggest a dependency that does not exist.

## Proposed change

Delete lines 4-7 (comment plus the three `font-feature` lines).
Ligature rendering stays identical. If the intent was to pin the
behavior against upstream default changes, keep the lines but fix the
comment to say the features are already Ghostty defaults and are listed
for explicitness.
