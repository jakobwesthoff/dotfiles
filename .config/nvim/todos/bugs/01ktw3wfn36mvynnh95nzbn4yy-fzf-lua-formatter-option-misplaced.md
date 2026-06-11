# Fix misplaced fzf-lua `formatter` option (currently silently ignored)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/fzf.lua:17-23` contains:

```lua
winopts = {
  preview = {
    wrap = "wrap",
  },
  formatter = "path.filename_first",
},
```

`formatter = "path.filename_first"` sits inside `winopts` (fzf.lua:21,
directly after the `preview` table). fzf-lua does not read a formatter
from `winopts`; it resolves `formatter` from picker-level / global opts (installed fzf-lua source,
`lua/fzf-lua/config.lua:537-563`: `if opts.formatter then ...
M.globals["formatters." .. opts.formatter]`). Defaults set it
per-provider (e.g. `defaults.lua:2131`). Nothing reads
`winopts.formatter`, so the intended "filename first" path display is
silently not applied.

`winopts.preview.wrap` (fzf.lua:19) is correctly placed and unaffected.

## Evidence / basis

- Config read: `fzf.lua:17-23`.
- Installed fzf-lua source: `config.lua:537-563` (formatter resolution
  from `opts.formatter`), `defaults.lua:2131` (per-provider default
  `formatter = "path.dirname_first"`), plus pickers that pin
  `formatter = false` (defaults.lua:1320, :1353).

## Fix

Move the key to the top level of `setup{}` to apply globally:

```lua
require("fzf-lua").setup({
  formatter = "path.filename_first",
  ui_select = true,
  ...
  winopts = {
    preview = { wrap = "wrap" },
  },
})
```

Note: applying it globally will change path rendering in all
file-listing pickers (files, oldfiles, grep results, LSP locations).
If only some pickers should use it, set it per picker instead, e.g.
`files = { formatter = "path.filename_first" }`.

## Verification

`:FzfLua files` — entries should render as `name  dir/` (filename
first) instead of the default `dir/name`.
