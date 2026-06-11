# Fix treesitter first-open race: await async parser install before starting highlight

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/treesitter.lua:40-57` (FileType autocmd for the
nvim-treesitter `main` branch): when a parser is missing it calls

```lua
pcall(require("nvim-treesitter").install, { lang })
...
pcall(vim.treesitter.start)
```

`install()` is asynchronous: in the installed plugin it is defined as
`M.install = a.async(...)` (`nvim-treesitter/lua/nvim-treesitter/install.lua:546`)
and returns a Task object exposing `:await(callback)`
(`nvim-treesitter/lua/nvim-treesitter/async.lua:81-91`). The immediate
`vim.treesitter.start()` therefore runs before the parser exists, fails
inside its `pcall`, and the **first** buffer of a newly installed
language shows no treesitter highlighting until reloaded (`:e`).

## Evidence / basis

- Config read: `treesitter.lua:40-57`.
- Installed nvim-treesitter (main branch, commit e5f65e31) source at
  the lines cited (read 2026-06-11).
- The overall FileType-autocmd approach itself matches upstream's
  documented recommendation (installed README.md:84-91) — only the
  async handling is missing.

## Fix

Use the returned task's `await` in the missing-parser branch and keep
the direct start for the already-installed path:

```lua
callback = function(ev)
  local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

  if pcall(vim.treesitter.language.inspect, lang) then
    pcall(vim.treesitter.start, ev.buf, lang)
    return
  end

  if require("nvim-treesitter.parsers")[lang] then
    require("nvim-treesitter").install({ lang }):await(function()
      -- Buffer may have been wiped while the install ran.
      if vim.api.nvim_buf_is_valid(ev.buf) then
        pcall(vim.treesitter.start, ev.buf, lang)
      end
    end)
  end
end,
```

Notes for implementation:

- `vim.treesitter.start(bufnr, lang)` with explicit args avoids
  depending on the current buffer at await time (the user may have
  switched windows during the download).
- Keep the `parsers[lang]` existence guard (treesitter.lua:48-51); it
  suppresses "unsupported language" noise, as the existing comment
  documents.
- `install()` is idempotent for already-installed parsers (existing
  comment at treesitter.lua:44-45, consistent with the upstream
  behavior), so the restructured flow stays safe if events race.

## Verification

Delete an installed parser (`:TSUninstall just` or remove its .so under
the nvim-treesitter data dir), open a file of that language, and
confirm highlighting appears in that same buffer once the install
completes, without `:e`.
