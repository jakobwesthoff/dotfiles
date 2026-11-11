# Evaluate migrating from lazy.nvim to the native vim.pack plugin manager

Created: 2026-06-11, from the 2026-06-11 full-config code review.
Updated: 2026-11-11, from the 2026-11-11 config modernization review.
This is an evaluation/experiment todo. No decision has been made.

## What vim.pack provides on the running build

Verified on NVIM v0.13.0-dev-2756 (runtime
`/opt/homebrew/Cellar/neovim/HEAD-e508aa0/share/nvim/runtime`):

- API: `vim.pack.add`, `vim.pack.update`, `vim.pack.get`, `vim.pack.del`
  (headless probe).
- **Lockfile** support, intended to be put under version control
  (`runtime/lua/vim/pack.lua:14-25`, `vim.pack-lockfile`).
- **Version constraints**: plain strings (branch/tag) or
  `vim.version.range('1.0')` semver ranges (pack.lua:46-55, :366-368).
- **Hooks** via `PackChangedPre`/`PackChanged` autocmd events, with a
  documented build-script example (pack.lua:165-201). That covers
  nvim-treesitter's `:TSUpdate` and blink.cmp-style build steps.
- **Load control**: `add(..., { load = false })` works like `:packadd!`,
  or a function taking full responsibility for loading (pack.lua:961
  region), the primitive for hand-rolled lazy loading.
- Parallel installation, blobless partial clones (pack.lua doc header).
- Introduced in 0.12 (`runtime/doc/news-0.12.txt:353`); still evolving.

Added in 0.13-dev, verified on v0.13.0-dev-1966 (`runtime/doc/news.txt`):

- `:packupdate` and `:packdel` user commands (news.txt:323).
- `vim.pack.get()` shows the revision of a pending update and can fetch
  updates before computing its output (news.txt:445-446).
- A `vim.pack-manifest` of plugins (news.txt:447).
- `'packlockfile'` sets where the lockfile lives (news.txt:470), so it
  can sit in the dotfiles repo.

## What lazy.nvim does for this config that vim.pack does not

From the specs in `lua/mrjakob/plugins/` (22 files, 2026-11-11):

- **Declarative event/keys/ft/cmd lazy loading**: used by conform
  (`event = BufWritePre`, `cmd`, `keys`), autopairs (`InsertEnter`),
  crates (`BufRead Cargo.toml`), which-key (`VimEnter`), lazydev
  (`ft = lua`), template-string (`ft`), and todo-comments +
  nvim-highlight-colors (`BufReadPre`/`BufReadPost`/`BufNewFile`). With
  vim.pack each of these becomes manual autocmd + `packadd`/setup code,
  or simply eager loading.
- **Dependency ordering** (`dependencies = ...`), including transparent
  install of nvim-web-devicons and mason.nvim for mason-tool-installer.
- **`opts` sugar** calling `setup()` automatically.
- **Priority/ordering** for the colorscheme (`priority = 1000`).
- A richer update UI than `:packupdate`, and semver `version = "v1.*"`
  pins (blink.cmp, rustaceanvim `^9`).

Functionally replaceable, but each item is hand-written code after a
migration. Startup measured 2026-11-11 with lazy.nvim: 42.6 to 44.5 ms
over 4 headless runs (`nvim --headless --startuptime <file> +q`), so
startup time argues neither way.

kickstart.nvim moved to vim.pack in PR #2005 "Refactor/vim.pack",
merged 2026-05-06 (`gh api repos/nvim-lua/kickstart.nvim/pulls/2005`).

## Honest assessment

The genuine wins are: one less foundational dependency, native
lockfile, and alignment with where Neovim is heading. The costs are:
re-implementing the lazy-loading sugar for ~7 plugins (or accepting
eager loads), hand-managing setup ordering (theme before lualine,
mason before the LSP setup), and living with an API explicitly still
maturing in 0.12/0.13. nvim-treesitter (main branch) and blink.cmp both
need build hooks, supported via PackChanged, but that wiring is on
you.

## Suggested experiment

1. Take the startup numbers above as the baseline.
2. Branch the dotfiles repo; rewrite `setup.lua` with `vim.pack.add`
   listing every plugin (src URLs from `lazy-lock.json`), explicit
   `require(...).setup(...)` calls in dependency order, and a
   `PackChanged` autocmd for the treesitter/blink build steps.
3. Decide afterwards with data: startup delta, perceived complexity of
   the rewritten setup, and whether any lazy-load actually mattered.

## Basis

vim.pack facts: runtime source/doc of the builds named above (read
2026-06-11 and 2026-11-11). lazy.nvim usage facts: the config's own
specs. kickstart.nvim: GitHub API (2026-11-11).
