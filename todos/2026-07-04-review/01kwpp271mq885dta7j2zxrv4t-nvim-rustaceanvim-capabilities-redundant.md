# nvim: rustaceanvim capabilities hand-wiring is redundant since v9 merges vim.lsp.config("*")

**Area**: nvim
**File**: /Users/jakob/dotfiles/.config/nvim/lua/mrjakob/plugins/lsp.lua:53-64

## Current state

The rustaceanvim spec (pinned `version = "^9"`) carries an `init` block that
hands blink.cmp's capabilities to rust-analyzer manually:

```lua
init = function()
  -- rustaceanvim starts rust-analyzer itself rather than through
  -- vim.lsp.config/enable, so the wildcard vim.lsp.config("*")
  -- capabilities never reach it (and v6+ no longer auto-registers
  -- client capabilities). Hand blink.cmp's capabilities to its server
  -- directly. vim.g.rustaceanvim is read before the plugin loads.
  vim.g.rustaceanvim = {
    server = {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    },
  }
end,
```

Meanwhile lua/mrjakob/lsp.lua:15-17 already sets the same capabilities via
`vim.lsp.config("*", { capabilities = ... })`.

## Problem

The comment's claim that the wildcard capabilities "never reach"
rustaceanvim is no longer true for the installed/pinned version. The whole
`init` block duplicates what the wildcard config already delivers, and it
forces blink.cmp to load during lazy.nvim's init phase for no gain.

## Grounding

- Installed rustaceanvim is v9.0.5 (`git describe --tags` in
  `~/.local/share/nvim/lazy/rustaceanvim`), matching the `^9` pin.
- `rustaceanvim/lua/rustaceanvim/lsp/init.lua:159-173` (installed copy):
  `M.start` calls `vim.lsp.config('rust-analyzer', {})` to force resolution,
  reads the resolved `vim.lsp.config['rust-analyzer']`, and merges it over
  the `vim.g.rustaceanvim` server table:
  `vim.tbl_deep_extend('force', vim.deepcopy(config.server), ra_config)` —
  i.e. the `vim.lsp.config` values take precedence over `vim.g.rustaceanvim`.
- Neovim's resolution includes the wildcard: on the installed build,
  `runtime/lua/vim/lsp.lua:356-359` merges `lsp.config._configs['*']` into
  every resolved named config. The client name is `rust-analyzer`
  (rustaceanvim lsp/init.lua:11), so nvim-lspconfig's `lsp/rust_analyzer.lua`
  (underscore name) does not leak in; only the `"*"` config plus any
  `rust-analyzer`-named config apply.
- rustaceanvim's own docs state the same:
  `rustaceanvim/lua/rustaceanvim/config/init.lua:58-62` — "Some fields can
  also be set using |vim.lsp.config()| for 'rust-analyzer' or '*'. If both
  the `server` table and a `vim.lsp.config["rust-analyzer"]` are defined,
  rustaceanvim merges |vim.lsp.config()| settings into the `server` table,
  [with vim.lsp.config taking precedence]."

## Proposed change

Remove the `init` block (the whole `vim.g.rustaceanvim` capabilities
assignment) and its comment; the wildcard config in lua/mrjakob/lsp.lua
already covers rust-analyzer on v9. Afterwards verify in a Rust project that
blink.cmp completion still works (e.g. snippet/auto-import capabilities
active). If any other `vim.g.rustaceanvim` settings are ever needed, the
table can come back without the capabilities line.
