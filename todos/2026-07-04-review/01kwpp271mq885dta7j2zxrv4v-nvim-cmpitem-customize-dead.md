# nvim: gruvbox-material customize targets nvim-cmp match groups that blink.cmp never uses

**Area**: nvim
**File**: /Users/jakob/dotfiles/.config/nvim/lua/mrjakob/plugins/gruvbox-material.lua:56-59

## Current state

The theme's `customize` hook recolors the completion-match highlight:

```lua
-- Change partial cmp matches
if group == "CmpItemAbbrMatch" or group == "CmpItemAbbrMatchFuzzy" then
  opts.fg = colors.orange
end
```

Completion in this config is provided by blink.cmp
(lua/mrjakob/plugins/blink-cmp.lua), not nvim-cmp.

## Problem

blink.cmp does not render through `CmpItemAbbrMatch*` unless
`appearance.use_nvim_cmp_as_default = true`, which this config does not set
(and which blink documents as "will be removed in a future release"). The
matched-text group blink actually uses is `BlinkCmpLabelMatch`, and
gruvbox-material defines that group itself as green/bold. Result: the
orange override is dead config; matched characters in the completion menu
render green/bold from the theme, not orange as the customize block
intends.

## Grounding

Installed plugin sources (all read 2026-07-04):

- blink.cmp `lua/blink/cmp/highlights.lua:13-16`: the
  `BlinkCmpLabelMatch -> CmpItemAbbrMatch` link is only created
  `if use_nvim_cmp then`; `use_nvim_cmp_as_default` defaults to `false`
  (`lua/blink/cmp/config/appearance.lua:12`) and is not set in
  plugins/blink-cmp.lua.
- gruvbox-material.nvim `lua/gruvbox-material/groups.lua:759`:
  `BlinkCmpLabelMatch = { fg = colors.green, bold = true }` — the theme has
  first-class blink support, so blink's `default = true` links never
  override it.
- gruvbox-material.nvim `groups.lua:729-730` still defines
  `CmpItemAbbrMatch`/`CmpItemAbbrMatchFuzzy`, which is why the customize
  hook fires for them — but nothing in this setup consumes those groups.

## Proposed change

In the `customize` function, replace the `CmpItemAbbrMatch`/
`CmpItemAbbrMatchFuzzy` branch with one for `BlinkCmpLabelMatch`
(e.g. `opts.fg = colors.orange`, keep/adjust `bold` as desired) if the
orange match color is still wanted; otherwise delete the branch. Verify by
opening the completion menu and checking the matched-character color.
