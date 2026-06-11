# Bump rustaceanvim from `^5` (v5.26.0, 2025-03) to `^9`

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/lsp.lua:195-199` pins:

```lua
{
  "mrcjkb/rustaceanvim",
  version = "^5", -- Recommended
  lazy = false,
},
```

Installed: v5.26.0, last commit 2025-03-31 (git describe / git log of
the installed copy). Upstream latest at review time: **v9.0.5,
released 2026-06-06** (GitHub releases API). The pin holds the plugin
more than a year behind across four major versions.

## Breaking changes between v5 and v9

From the upstream changelog
(https://raw.githubusercontent.com/mrcjkb/rustaceanvim/master/CHANGELOG.md,
fetched 2026-06-11):

- **6.0.0** (2025-04-03): don't auto-register LSP client capabilities;
  drop `config.tools.edition`; drop `rust-analyzer.json` support; drop
  nvim 0.10 support.
- **7.0.0**: drop ra-multiplex support in favour of lspmux.
- **8.0.0**: remove `.vscode/settings.json` support in favour of
  codesettings.nvim.
- **9.0.0** (2026-04-03): drop Neovim 0.11 support.

## Impact assessment for this config

The config sets **no** `vim.g.rustaceanvim` and uses none of:
`rust-analyzer.json`, `config.tools.edition`, ra-multiplex,
`.vscode/settings.json`. Neovim version floors are all satisfied
(running 0.13-dev). The single material item is 6.0.0's
**"don't auto-register LSP client capabilities"**:

- The config broadcasts blink.cmp capabilities via
  `vim.lsp.config("*", { capabilities = ... })` (lsp.lua:55-57).
- rustaceanvim starts its rust-analyzer client itself, not via
  `vim.lsp.config`/`vim.lsp.enable`, so the wildcard does **not** apply
  to it. Whether current rustaceanvim versions pick up `vim.lsp.config`
  settings was not verified during review — check the v9 docs on
  upgrade.
- If completion capabilities are missing in Rust buffers after the
  bump, add:

```lua
vim.g.rustaceanvim = {
  server = {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
  },
}
```

## Reminder from the existing spec comment

rust-analyzer must NOT be installed via mason for rustaceanvim
(lsp.lua:187-194, existing comment); it comes from
`rustup component add rust-analyzer`. Unchanged by the bump.

## Fix

1. Change the pin to `version = "^9"` (drop the stale
   `-- Recommended` comment or re-point it at the v9 docs).
2. `:Lazy update` rustaceanvim.
3. Test in a Rust project: completion (blink menu on `.`), hover,
   `:RustLsp` commands (e.g. `:RustLsp runnables`), inlay hints.
4. If completion regressed, add the `vim.g.rustaceanvim` capabilities
   snippet above.
