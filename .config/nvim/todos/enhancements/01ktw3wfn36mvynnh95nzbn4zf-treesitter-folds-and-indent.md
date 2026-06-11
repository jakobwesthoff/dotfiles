# Consider enabling treesitter-based folds and indentation

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). Optional enhancement — both
features are off today and nothing is broken.

## Situation

The treesitter setup (`lua/mrjakob/plugins/treesitter.lua`) enables
highlighting only. The installed nvim-treesitter (main branch) README
documents two further integrations, both one-liners in exactly the
FileType autocmd the config already has:

- **Folding** — provided by Neovim core, not the plugin
  (README.md:95-100):

```lua
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldmethod = "expr"
```

- **Indentation** — provided by the plugin, explicitly marked
  **experimental** upstream (README.md:104-108):

```lua
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
```

## Considerations specific to this config

- Folding: with `foldmethod=expr` everything starts folded unless
  `foldlevel`/`foldlevelstart` is raised; a typical companion is
  `vim.opt.foldlevelstart = 99` in options.lua so files open unfolded
  and folds are opt-in via `zc`/`zM`. The config currently sets no fold
  options at all (options.lua read in full during review).
- Indentation: `smartindent`/`autoindent` are on (options.lua:14-15)
  and vim-sleuth manages buffer indent *width*; treesitter indentexpr
  changes how new lines are indented, which interacts per-language.
  Given the upstream "experimental" label, enable per-filetype where
  the default indent annoys (e.g. start with just `rust`/`typescript`)
  rather than globally.
- Both belong naturally in the existing `treesitter-start` FileType
  autocmd (treesitter.lua:40-57), gated on the parser actually being
  available (the same condition that gates `vim.treesitter.start`).

## Basis

Installed nvim-treesitter README at the lines cited (commit e5f65e31,
read 2026-06-11); config files as cited. The foldlevel companion and
per-language indent rollout are suggestions, not upstream requirements.
