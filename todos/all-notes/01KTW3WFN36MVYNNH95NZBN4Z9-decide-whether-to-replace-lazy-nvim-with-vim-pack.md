---
title: "Decide whether to replace lazy.nvim with vim.pack"
kind: investigation
component: config
status: needs-discussion
horizon: someday
origin: review
---
# Decide whether to replace lazy.nvim with vim.pack

The Neovim config (`.config/nvim`) manages its plugins with lazy.nvim.
Neovim ships its own plugin manager, `vim.pack`, since 0.12. Raised in
the 2026-06-11 config code review and re-checked in the 2026-11-11
modernization review. Switching would drop a core dependency and
follow where Neovim is heading, at the cost of rewriting the plugin
setup by hand. Parked on 2026-11-11: lazy.nvim works and nothing pushes
a switch yet.

## Context

What `vim.pack` offers, checked on NVIM v0.13.0-dev-2082 (2026-11-11):

- `vim.pack.add`, `update`, `get` and `del`, plus the `:packupdate` and
  `:packdel` commands (`runtime/doc/news.txt`).
- A lockfile meant for version control, whose location `'packlockfile'`
  sets, so it can live in the dotfiles repo (`runtime/doc/pack.txt`,
  `vim.pack-lockfile`).
- Versions as a branch, tag or `vim.version.range()` semver range.
- Build hooks through the `PackChanged` autocmd event.
- `add(..., { load = false })`, the building block for hand-written
  lazy loading.

What lazy.nvim does for this config that would become hand-written code,
from the specs in `.config/nvim/lua/mrjakob/plugins/` (21 files):

- Lazy loading on event, key, filetype or command for about 7 plugins:
  conform, autopairs, crates, which-key, lazydev, template-string,
  todo-comments and nvim-highlight-colors. Each becomes an autocmd plus
  `packadd` and `setup()`, or loads at startup.
- Dependency order: the colorscheme before lualine (`priority = 1000`),
  mason before the LSP setup, nvim-web-devicons installed with its
  users.
- `opts` calling `setup()` automatically.
- Version pins: blink.cmp `v1.*` (its prebuilt fuzzy binary needs a
  release tag), rustaceanvim `^9`. Both map to `vim.version.range()`.
- The build step of nvim-treesitter (`build = ":TSUpdate"`), which would
  move into a `PackChanged` hook.

Startup with lazy.nvim: 42.6 to 44.5 ms over 4 headless runs
(`nvim --headless --startuptime <file> +q`, 2026-11-11), so speed argues
neither way. kickstart.nvim moved to `vim.pack` in PR #2005, merged
2026-05-06 (`https://github.com/nvim-lua/kickstart.nvim/pull/2005`).

## Options

- **Stay on lazy.nvim.** No work; keeps the declarative specs.
- **Migrate.** On a branch, rewrite `setup.lua` with one `vim.pack.add`
  listing every plugin (sources from `lazy-lock.json`), explicit
  `setup()` calls in dependency order, a `PackChanged` hook for
  nvim-treesitter, and either hand-written lazy loading or eager loads.
  Decide on the branch by startup delta and how readable the rewritten
  setup is.

## Decisions

- 2026-11-11, user: stay on lazy.nvim for now; park until a trigger
  below.

## Revisit when

- lazy.nvim stops being maintained.
- `vim.pack` gets a stable API or declarative lazy loading.
- The Neovim config gets rewritten anyway.
