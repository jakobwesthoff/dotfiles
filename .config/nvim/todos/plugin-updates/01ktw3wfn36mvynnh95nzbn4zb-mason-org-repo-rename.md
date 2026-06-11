# Update mason plugin specs to the mason-org GitHub organization

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

Three spec references still use the old GitHub account:

- `lua/mrjakob/plugins/lsp.lua:6`: `"williamboman/mason.nvim"`
- `lua/mrjakob/plugins/lsp.lua:7`: `"williamboman/mason-lspconfig.nvim"`
- `lua/mrjakob/plugins/mason.lua:2`: `"williamboman/mason.nvim"`

The project moved to the `mason-org` GitHub organization; the canonical
repo is `https://github.com/mason-org/mason.nvim` (fetched 2026-06-11;
upstream release at that time: v2.3.1). The installed clones still point
at the old URLs (`git remote -v` shows
`https://github.com/williamboman/mason.nvim.git`), which works only via
GitHub's rename redirect. Redirects are fragile: they break permanently
if the old account name ever hosts a repo with the same name.

Installed state at review time (not stale, just old URLs):
mason.nvim at the `stable` tag, commit dated 2026-01-07;
mason-lspconfig.nvim `stable-40-ga979821`, commit dated 2026-03-20.

## Evidence / basis

- Config reads at the three lines above.
- `git -C ~/.local/share/nvim/lazy/mason.nvim remote -v` and the same
  for mason-lspconfig (run 2026-06-11).
- https://github.com/mason-org/mason.nvim fetched 2026-06-11 (canonical
  location, v2.3.1).
- The config comment at `lsp.lua:167-169` about mason-lspconfig's
  `automatic_enable` defaulting to true was verified against the
  installed copy (`mason-lspconfig/lua/mason-lspconfig/settings.lua:26`)
  — accurate, no change needed there.

## Fix

Rename the three spec strings to `mason-org/mason.nvim` and
`mason-org/mason-lspconfig.nvim`. lazy.nvim treats the changed slug as
a different source and re-clones (or updates the remote) on the next
sync; `lazy-lock.json` keys stay the same (they are plugin directory
names, not slugs).

Note: `WhoIsSethDaniel/mason-tool-installer.nvim` (mason.lua:4) was not
part of the move; leave it.

## Verification

`:Lazy sync`, then
`git -C ~/.local/share/nvim/lazy/mason.nvim remote -v` shows the
mason-org URL and `:checkhealth mason` is clean.
