# nvim: stale Mason packages installed that no config references (astro-ls, lemminx)

**Area**: nvim
**File**: /Users/jakob/dotfiles/.config/nvim/lua/mrjakob/servers.lua (server registry) and lua/mrjakob/plugins/mason.lua (tools list); the stale state lives in ~/.local/share/nvim/mason/

## Current state

`ls ~/.local/share/nvim/mason/bin/` (2026-07-04) shows two binaries whose
packages appear neither in the server registry (servers.lua) nor in the
`tools` list (mason.lua):

- `astro-ls` (Mason package `astro-language-server`)
- `lemminx` (XML language server, Mason package `lemminx`)

Every other installed binary maps to a current entry (e.g.
`docker-langserver` is the binary of `dockerfile-language-server`,
`vscode-json-language-server` of `json-lsp`, `tree-sitter` of
`tree-sitter-cli`).

## Problem / opportunity

Leftovers from previously configured servers. mason-tool-installer only
installs `ensure_installed`; it never removes packages on its own, so these
sit unused on disk and show up in `:Mason` as installed. Purely
housekeeping — nothing is enabled for them (`vim.lsp.enable` only receives
the servers.lua keys), so they never start.

## Grounding

- `ls ~/.local/share/nvim/mason/bin/` output vs. servers.lua:28-45 and
  mason.lua:20-25 (compared 2026-07-04).
- mason-tool-installer ships a cleanup command for exactly this:
  `:MasonToolsClean` — "removes all packages that are not listed in your
  configuration" (installed copy,
  `~/.local/share/nvim/lazy/mason-tool-installer.nvim/plugin/mason-tool-installer.lua:20`,
  wiring `clean` from `lua/mason-tool-installer/init.lua:368,394`).

## Proposed change

Run `:MasonToolsClean` once inside Neovim (or uninstall `astro-ls` and
`lemminx` via `:Mason`). Re-check `ls ~/.local/share/nvim/mason/bin/`
afterwards. No repository file change needed unless either server should
actually be configured, in which case add it to servers.lua instead.
