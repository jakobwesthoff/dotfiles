# Finish modernizing the LSP setup structure (file-based configs, explicit enable, flatten spec)

Created: 2026-06-11, follow-up to the full-config code review
(`docs/code-review-2026-06-11.md`) after the question whether the LSP
setup is fully refactored to the modern (0.11+) model.

## Current state — what is already modern (verified 2026-06-11)

- **No legacy framework usage.** `grep` of the whole config: zero
  `require('lspconfig')` calls. The installed nvim-lspconfig README
  (README.md "Important" section) deprecates exactly that legacy
  framework — `require('lspconfig')` will warn, later error — while
  nvim-lspconfig itself is "NOT deprecated": it is now a pure
  collection of server configs in its `lsp/` directory (388 files in
  the installed copy; all 12 servers this config uses are present:
  bashls, clangd, docker_compose_language_service, dockerls, helm_ls,
  jsonls, lua_ls, marksman, phpactor, taplo, ts_ls, yamlls).
- **Customization via `vim.lsp.config()`** (`lsp.lua:55-93`): wildcard
  capabilities plus per-server overrides — the documented modern
  mechanism (runtime `doc/lsp.txt`, *lsp-config*).
- **Enabling via `vim.lsp.enable()`**, indirectly: mason-lspconfig v2's
  `automatic_enable` (on by default, installed
  `mason-lspconfig/lua/mason-lspconfig/init.lua:42-43` →
  `features/automatic_enable`) enables every mason-installed server.

So the suspicion "we never fully refactored" is unfounded for the
mechanics — the refactor happened (lsp.lua's comments at :49-57 and
:166-170 document it). What remains are three structural decisions the
modern model now offers.

## Remaining modernization decisions

### 1. Per-server overrides as files: `after/lsp/<server>.lua`

The runtime merges configs in this priority order
(`doc/lsp.txt` *lsp-config-merge*, read on the running build):

1. `vim.lsp.config('*')`
2. merged `lsp/<name>.lua` files across 'runtimepath' (this is where
   nvim-lspconfig's configs live)
3. merged `after/lsp/<name>.lua` files — the documented place for
   *user overrides of plugin-provided configs*
4. `vim.lsp.config('<name>', ...)` calls — highest priority

The current `vim.lsp.config("clangd"|"lua_ls"|"yamlls", ...)` calls in
`lsp.lua:70-93` work (tier 4 beats everything), but the file-based form
is the structure the runtime/nvim-lspconfig docs steer towards:

- `~/.config/nvim/after/lsp/clangd.lua` returning
  `{ cmd = { "clangd", "--query-driver=...", "--background-index" } }`
- `~/.config/nvim/after/lsp/lua_ls.lua`, `.../yamlls.lua` likewise.

Each file keeps its current explanatory comment (the clangd
query-driver rationale especially). Merge caveat: list values like
`cmd` are *replaced*, not concatenated (`vim.tbl_deep_extend` "force"
semantics per *lsp-config-merge*) — true for both the current calls
and the file form, so behavior is identical. This is a structure/taste
move, not a behavior fix; the win is that overrides live where
`:checkhealth vim.lsp` and the docs expect them, outside any plugin
spec's `config` function.

### 2. Explicit `vim.lsp.enable()` vs mason-lspconfig

mason-lspconfig's only active role in this config is
`automatic_enable` — its other feature (ensure_installed) is delegated
to mason-tool-installer (mason.lua). Two coherent end states:

- **Keep mason-lspconfig** (status quo): zero-maintenance enabling of
  whatever mason has installed. Cost: the *enabled set* is implicit —
  anything ad-hoc `:MasonInstall`ed starts attaching, and one plugin
  exists purely to call `vim.lsp.enable`.
- **Drop mason-lspconfig**, add one explicit line:
  `vim.lsp.enable({ "lua_ls", "marksman", "ts_ls", "taplo", "phpactor",
  "bashls", "dockerls", "docker_compose_language_service", "helm_ls",
  "yamlls", "jsonls", "clangd" })`.
  The list already exists in mason.lua's ensure_installed; keeping the
  two in sync is the new (small) maintenance burden.
  **Caveat to verify before doing this:** mason-tool-installer is
  currently fed lspconfig-style names (`lua_ls`, `ts_ls`, ...). The
  review noted (unverified) that this aliasing may be provided by
  mason-lspconfig's mapping; if so, dropping it means renaming
  ensure_installed entries to mason package names
  (`lua-language-server`, `typescript-language-server`, ...). Test in a
  scratch setup or check mason-tool-installer's name resolution first.

### 3. Flatten the spec structure

`lsp.lua` nests mason, mason-lspconfig, fidget, and blink as
`dependencies` of nvim-lspconfig and does all wiring in its `config`
function. In the modern model nvim-lspconfig is data-only (no
`setup()` call exists or is needed), so the `vim.lsp.config('*')`
capabilities line, the LspAttach autocmd, and diagnostics config can
live in a plain module (e.g. `lua/mrjakob/lsp.lua` required from
setup.lua) with only ordering constraint "after blink.cmp is
available". Optional; reduces the impression that nvim-lspconfig is a
framework being configured.

## Out of scope here

rust-analyzer stays outside `vim.lsp.enable` (rustaceanvim manages its
own client — see `todos/plugin-updates/*-rustaceanvim-bump-v9.md`);
crates.nvim's in-process LSP likewise.

## Basis

- Installed nvim-lspconfig README + `lsp/` directory listing
  (2026-06-11).
- Runtime `doc/lsp.txt` *lsp-config* / *lsp-config-merge* sections of
  the running build (merge priority quoted above).
- Installed mason-lspconfig source (`init.lua:42-43`,
  `settings.lua:26`).
- Config greps: no `require('lspconfig')`; current vim.lsp.config call
  sites in lsp.lua.
