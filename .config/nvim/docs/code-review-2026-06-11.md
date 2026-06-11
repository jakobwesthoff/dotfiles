# Code Review: Neovim Configuration

Date: 2026-06-11

## Scope and method

This review covers every file of the Neovim configuration at
`~/dotfiles/.config/nvim`: `init.lua`, the `lua/mrjakob/` core modules
(`setup.lua`, `options.lua`, `keymaps.lua`, `autocmds.lua`, `util.lua`,
`lastpos.lua`), all 24 plugin specs under `lua/mrjakob/plugins/`,
`ftdetect/helm.lua`, `after/ftplugin/php.lua`, and `lazy-lock.json`.

Every finding is grounded in one of:

- the config source itself (cited as `file:line`),
- the installed Neovim runtime of the version actually in use
  (`NVIM v0.13.0-dev-2756+ge508aa0fa8-Homebrew`, runtime at
  `/opt/homebrew/Cellar/neovim/HEAD-e508aa0/share/nvim/runtime`),
- headless probes against that binary (`nvim --clean --headless -l`),
- the installed plugin sources under `~/.local/share/nvim/lazy/`,
- or, where a fact is only available upstream, a fetched release page or
  changelog (cited by URL).

A particular focus was checking which plugins or hand-rolled features can
now be replaced by functionality that ships natively in Neovim 0.12/0.13.

Each finding below references a todo file under `todos/` that contains the
full standalone detail, evidence, and a concrete fix proposal. The todo
file names start with a ULID; references here use the suffix only.

## Environment facts established during review

- `vim.pack` exists in this build with `add`, `update`, `get`, `del`
  (headless probe) and supports a lockfile, version constraints via
  `vim.version.range()`, and `PackChanged` events usable as build hooks
  (`runtime/lua/vim/pack.lua`).
- The experimental message/cmdline redesign formerly known as `vim._extui`
  lives at `vim._core.ui2` in this build and is enabled via
  `require('vim._core.ui2').enable()` (`runtime/lua/vim/_core/ui2.lua`).
  The `'cmdheight'` help text states `cmdheight=0` "Works better with
  `ui2` enabled" (`runtime/lua/vim/_meta/options.lua:968`).
- `vim.highlight` is a deprecation shim: every access fires
  `vim.deprecate('vim.highlight', 'vim.hl', ...)`
  (`runtime/lua/vim/_core/editor.lua:1313`,
  `runtime/lua/vim/_core/shared.lua:1413-1430`).
- The `client.supports_method(...)` dot-call is deprecated with
  removal target 0.13: `vim.deprecate('client.supports_method',
  'client:supports_method', '0.13')` (`runtime/lua/vim/lsp/client.lua:253`).
  Booting this config headless with a Lua file prints
  "client.supports_method is deprecated" (observed live).
- `vim.lsp.util.make_position_params()` without a `position_encoding`
  argument emits a warning and falls back to the first client's encoding
  (`runtime/lua/vim/lsp/util.lua:2054-2063`).
- Native unimpaired-style bracket mappings exist for diagnostics,
  quickfix, loclist, arglist, tags, buffers, and blank lines
  (`runtime/lua/vim/_core/defaults.lua:263-449`).
- Native OSC 52 clipboard support exists (`vim.ui.clipboard.osc52`
  loadable; `g:clipboard = 'osc52'` documented in
  `runtime/doc/provider.txt:271-280`).
- There is no native helm filetype detection: `vim.filetype.match`
  returns `yaml` for `*/templates/*.yaml`, `Chart.yaml`, `values.yaml`
  and `smarty` for `*/templates/*.tpl` (headless probe).
- The runtime does not bundle LSP server definitions (no `$VIMRUNTIME/lsp`
  directory in this build), so `nvim-lspconfig` remains required as the
  source of server configs.
- The config boots headless with no startup errors (3-second headless run,
  empty output, exit 0).

## Confirmed bugs

1. **`<leader>fd` is mapped twice** — `keymaps.lua:160` (document
   diagnostics) and `keymaps.lua:172` (dotfiles file search). The second
   overwrites the first; the diagnostics picker is unreachable.
   → `todos/bugs/…-duplicate-leader-fd-keymap.md`

2. **`constrast` typo in gruvbox-material setup** —
   `gruvbox-material.lua:13` passes `constrast = "hard"`; the plugin's
   option is `contrast`, default `"medium"`
   (`gruvbox-material.nvim/lua/gruvbox-material/init.lua:6`). The theme
   renders at medium contrast while the `customize` callback fetches hard
   palette colors, so `Pmenu*`/`NormalFloat` backgrounds use hard-palette
   shades on a medium-contrast theme.
   → `todos/bugs/…-gruvbox-material-contrast-typo.md`

3. **lazydev references a plugin that is not installed** — `lsp.lua:182`
   uses `path = "luvit-meta/library"`, but no `luvit-meta` directory
   exists under `~/.local/share/nvim/lazy/` and it is absent from
   `lazy-lock.json`. The `vim.uv` type library never loads. The installed
   lazydev README recommends `path = "${3rd}/luv/library"` instead, which
   needs no extra plugin.
   → `todos/bugs/…-lazydev-missing-luvit-meta-types.md`

4. **LspAttach keymaps are global, not buffer-local** — the comment at
   `keymaps.lua:33` promises buffer-scoped registration, but none of the
   `vim.keymap.set` calls inside the `LspAttach` callback
   (`keymaps.lua:50-145`) nor the inlay-hint toggle (`lsp.lua:129-131`)
   pass `buffer = event.buf`. After the first LSP attach the mappings are
   global in every buffer. The inlay-hint toggle additionally checks
   per-buffer state but enables globally.
   → `todos/bugs/…-lsp-attach-keymaps-not-buffer-local.md`

5. **LspDetach/document-highlight autocmd defects** — `lsp.lua:106-125`:
   the detach handler is global and recreated (group `clear = true`) on
   every attach; it clears highlight autocmds for a buffer even when
   another attached client still supports documentHighlight;
   `vim.lsp.buf.clear_references()` clears the *current* buffer, not the
   detaching one; and a buffer with two highlight-capable clients gets
   duplicate CursorHold callbacks.
   → `todos/bugs/…-lsp-detach-highlight-autocmd-defects.md`

6. **`<c-e>` typed literally in lastpos.lua** — `lastpos.lua:38` runs
   `vim.cmd([[normal! G'"<c-e>]])`; `:normal` does not parse key
   notation, so the buffer receives the literal characters `<`, `c`, `-`,
   `e`, `>`. Latent: the branch only triggers when the saved position is
   near the end of the buffer.
   → `todos/bugs/…-lastpos-ctrl-e-literal-keys.md`

7. **conform's `scf-docker` formatter path does not exist** —
   `conform.lua:69` hardcodes
   `/Users/jakob/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh`,
   which is missing on this machine right now (`ls` fails). Because
   `formatters_by_ft` entries do not count as "explicit" formatters in
   conform's warning logic, PHP saves silently fall through to LSP
   formatting with no notification.
   → `todos/bugs/…-conform-scf-docker-missing-binary.md`

8. **fzf-lua `formatter` option is in the wrong place** — `fzf.lua:21`
   puts `formatter = "path.filename_first"` under `winopts.preview`;
   fzf-lua reads `formatter` from picker-level/global opts
   (`fzf-lua/lua/fzf-lua/config.lua:537-563`). The setting is silently
   ignored.
   → `todos/bugs/…-fzf-lua-formatter-option-misplaced.md`

9. **lualine inactive-section colors go stale on colorscheme change** —
   the theme function (`lualine.lua:65-84`) is re-evaluated by lualine's
   own ColorScheme autocmd, but `inactive_primary_color`
   (`lualine.lua:58-61`) and the inactive filename fg (`lualine.lua:192`)
   are computed once at setup and stored as literal hex values. Related:
   `util.getColor` returns `"#000000"` for missing attributes instead of
   nil (`util.lua:10`).
   → `todos/bugs/…-lualine-stale-theme-colors.md`

10. **Custom showMessage handler maps log levels incorrectly** —
    `lsp.lua:154` indexes `vim.log.levels[message_type]` with the numeric
    LSP MessageType; `vim.log.levels` has string keys, so the level is
    always nil for non-error messages (headless probe confirmed). The
    whole override is redundant with the 0.13 default handler; see
    "Native replacements" below.

## Deprecated API usage (will break on 0.13)

- `vim.highlight.on_yank()` at `autocmds.lua:6` → `vim.hl.on_yank()`.
  → `todos/deprecations/…-vim-highlight-on-yank.md`
- `client.supports_method(...)` dot-calls at `lsp.lua:105`, `lsp.lua:128`,
  and `keymaps.lua:106` → `client:supports_method(...)`. Removal target
  is 0.13, the version in use.
  → `todos/deprecations/…-client-supports-method-colon-call.md`
- `vim.lsp.util.make_position_params()` without `position_encoding` at
  `keymaps.lua:51`, `keymaps.lua:83`, `keymaps.lua:117`. These three call
  sites disappear entirely with the fzf-lua `jump1` refactor below.

## Native replacements now available

1. **The custom gd/gI/gD logic is fzf-lua's default behavior** —
   fzf-lua ships `jump1 = true, jump1_action = actions.file_edit` for all
   LSP pickers (`fzf-lua/lua/fzf-lua/defaults.lua:1485-1486`): single
   result jumps directly, multiple results open the picker. The ~80 lines
   of `vim.lsp.buf_request` plumbing in `keymaps.lua:50-132` reimplement
   exactly that, and carry their own bugs (dead `result.result` unwrap —
   handlers receive the result already unwrapped per `:help lsp-handler`;
   ignored `err`; single-`Location` results not normalized;
   `vim.lsp.buf.definition(params)` passes position params where an opts
   table is expected, per `runtime/lua/vim/lsp/buf.lua:296-304`). All
   three mappings can become one-liners like the existing `gr`.
   → `todos/native-replacements/…-lsp-goto-keymaps-fzf-jump1.md`

2. **Manual OSC 52 autocmd vs native clipboard support** —
   `autocmds.lua:11-34` reimplements what the TUI does natively
   (auto-detection per `runtime/doc/provider.txt:271-280`, forceable via
   `vim.g.clipboard = 'osc52'`). The manual version misses non-yank
   register writes, loses linewise regtype, writes to a hardcoded channel
   2, and has no paste support.
   → `todos/native-replacements/…-osc52-native-clipboard.md`

3. **`ftdetect/helm.lua` → `vim.filetype.add()`** — detection is still
   needed (no native helm filetype, verified by probe), but the
   autocmd-based ftdetect predates `vim.filetype.add()`, which also
   allows scoping the overly broad bare `values.yaml`/`Chart.yaml`
   patterns.
   → `todos/native-replacements/…-helm-ftdetect-vim-filetype-add.md`

4. **`window/showMessage` override duplicates the 0.13 default** — the
   runtime default handler already routes server messages through
   `vim.notify` with the client name and a correctly mapped log level
   (`runtime/lua/vim/lsp/handlers.lua:32-44`, `:618-620`). The override
   at `lsp.lua:140-157` only adds the message-type name to the text and
   introduces the log-level bug described above.
   → `todos/native-replacements/…-remove-window-showmessage-override.md`

5. **mini.bracketed partially overlaps native 0.11+ bracket maps** —
   native defaults cover `b`, `d`, `l`, `q` (plus arglist, tags, blank
   lines); mini.bracketed overrides them and changes `]t`/`[t` semantics
   from tags to treesitter; `keymaps.lua:180-185` then re-overrides
   normal-mode `]t`/`[t` for todo-comments. Three owners for one mapping
   across modes. mini.bracketed's `undo` target also remaps `u` and
   `<C-R>` globally.
   → `todos/native-replacements/…-mini-bracketed-vs-native-bracket-maps.md`

6. **undotree → fzf-lua's built-in undotree picker** — answers the FIXME
   at `keymaps.lua:188`. fzf-lua ships an `undotree` provider with an
   undo-diff previewer (`fzf-lua/lua/fzf-lua/init.lua:268`,
   `providers/undotree.lua`). One plugin less, consistent picker UI.
   → `todos/native-replacements/…-undotree-to-fzf-lua-undotree.md`

7. **zen-mode.nvim → snacks.zen** — snacks (already installed for
   indent guides) ships a zen module whose `toggles` config replaces the
   manual `Snacks.indent.disable()/enable()` callbacks in
   `zen-mode.lua:26-33`.
   → `todos/native-replacements/…-zen-mode-to-snacks-zen.md`

## Evaluations (experiments, not yet decisions)

- **lazy.nvim → vim.pack** — `vim.pack` in this build has the pieces a
  migration needs (lockfile, version ranges, `PackChanged` build hooks)
  but no event/keys/ft lazy-loading layer. The todo lays out a concrete
  migration map and what would be given up.
  → `todos/experiments/…-vim-pack-migration-evaluation.md`
- **ui2 experimental message UI** — directly relevant to this config's
  `cmdheight = 0` (`options.lua:65`) and the fidget
  `override_vim_notify` setup.
  → `todos/experiments/…-ui2-experimental-message-ui.md`

## Outdated plugin references

- **mason moved to the mason-org GitHub organization** — specs still say
  `williamboman/...` (`lsp.lua:6-7`, `mason.lua:2`); the redirect works
  today but the canonical repo is `mason-org/mason.nvim` (v2.3.1
  upstream, verified 2026-06-11).
  → `todos/plugin-updates/…-mason-org-repo-rename.md`
- **rustaceanvim pinned `^5`, upstream at v9.0.5** — installed v5.26.0 is
  from 2025-03-31. Breaking changes for 6/7/8/9 are enumerated in the
  todo; for this config only 6.0.0's "don't auto-register LSP client
  capabilities" is material.
  → `todos/plugin-updates/…-rustaceanvim-bump-v9.md`
- **blink.cmp one patch release behind** — installed v1.10.1, latest
  tag v1.10.2 within the existing `v1.*` pin; plain `:Lazy update`.
  → `todos/plugin-updates/…-blink-cmp-update-v1-10-2.md`
- **dressing.nvim is archived** — its README recommends snacks.nvim. The
  documented reason for keeping it (snacks.input cursor starts at column
  0 with default text) is still valid: the installed snacks source sets
  the default text without positioning the cursor
  (`snacks.nvim/lua/snacks/input.lua:234-236`). Keep, re-check
  periodically, consider filing the issue upstream.
  → `todos/plugin-updates/…-dressing-snacks-input-reevaluation.md`

## Enhancements

- **treesitter first-open race** — `treesitter.lua:51-55` calls the async
  `install()` and then `vim.treesitter.start()` immediately; the first
  buffer of a newly installed language gets no highlighting. `install()`
  returns a task with `:await()`.
  → `todos/enhancements/…-treesitter-first-open-race.md`
- **treesitter folds/indent not enabled** — both are documented one-liners
  in the installed nvim-treesitter README (folds provided by Neovim,
  indent by the plugin, marked experimental).
  → `todos/enhancements/…-treesitter-folds-and-indent.md`
- **lualine truncation uses terminal width, not window width** — with
  `globalstatus = false`, narrow splits still render the wide variant
  (`lualine.lua:5-7`).
  → `todos/enhancements/…-lualine-window-width-truncation.md`
- **lazy-loading tuning** — template-string (eager, but only supports 9
  filetypes), todo-comments, highlight-colors, undotree (`cmd =`), the
  redundant `lazy = false` + `ft = "markdown"` combination in
  obsidian.lua, and snacks' recommended `priority = 1000, lazy = false`.
  → `todos/enhancements/…-lazy-loading-tuning.md`
- **`maplocalleader` is never set** — only `mapleader` is
  (`setup.lua:2`).
  → `todos/enhancements/…-set-maplocalleader.md`
- **Inline diagnostics display** — currently signs + on-demand `gl`
  float only; native `virtual_text`/`virtual_lines` (0.11+) are an
  available alternative to evaluate.
  → `todos/enhancements/…-diagnostics-display-evaluation.md`

## Cleanups

- **Stale which-key groups from kickstart** — `<leader>d`, `<leader>r`,
  `<leader>w`, `<leader>h` (`which-key.lua:21-26`) have no member
  mappings in this config; `<leader>r`/`<leader>w` are direct harpoon
  mappings, so the group labels are wrong.
  → `todos/cleanups/…-which-key-stale-groups.md`
- **fidget winblend workaround block** — the comment at `lsp.lua:11-43`
  states the underlying Neovim bug was fixed for 0.12; the running
  version is 0.13-dev, and the workaround opts are already commented
  out. The block can be resolved per its own TODO.
  → `todos/cleanups/…-fidget-workaround-removal.md`
- **Typos / dead code / small inconsistencies sweep** — harpoon keymap
  descriptions ("[q] Harpoon to 2", "[e] Harpoon to 4", "Hardpoon"),
  `options.lua` "cursor cursor" typo, langmap keymaps living in
  options.lua, dead `if not hl` guard in `util.lua`, redundant
  `border = "rounded"` in blink-cmp.lua (blink falls back to
  `vim.o.winborder`), x-mode `<C-BS>` mapping with no effect, `gra`
  unmapped only in normal mode, `ts-autotag` `config = true` spelling,
  duplicated OSC52 comment paragraph, missing `fd` executable guard in
  `FzfDirectories`, shellcheck listed under "LSP servers" in mason.lua.
  → `todos/cleanups/…-typos-dead-code-sweep.md`
- **Version-pin audit** — full inventory of `version`/`tag`/`branch`
  pins; the one undocumented pin is crates.nvim's `tag = "stable"`,
  and rustaceanvim's `^5` is stale (separate todo).
  → `todos/cleanups/…-version-pin-audit.md`

## Assessed and deliberately kept as-is

- **blink.cmp vs native `vim.lsp.completion`** — native autocompletion
  exists (`runtime/lua/vim/lsp/completion.lua`) and LSP snippet items
  expand via `vim.snippet`, but switching would lose the buffer and path
  sources, ghost text, automatic signature help, per-keypress triggering
  (native fires on server trigger characters), and auto-shown
  documentation. For this config's feature set blink stays.
- **vim-sleuth vs builtin editorconfig** — not equivalent: the builtin
  (`runtime/lua/editorconfig.lua`) only applies declared `.editorconfig`
  settings; sleuth infers indentation heuristically from buffer content.
  Complementary, keep both behaviors.
- **nvim-lspconfig** — still required: this build bundles no LSP server
  definitions (no `$VIMRUNTIME/lsp` directory).
- **lastpos.lua and the yank-highlight autocmd** — no native equivalent
  exists in this build's defaults (grep of `_core/defaults.lua`); both
  stay (modulo the `<c-e>` bug above).
- **oil.nvim eager loading** — upstream README explicitly recommends
  against lazy-loading oil.
- **dressing.nvim** — see "Outdated plugin references"; the keep-rationale
  in `dressing.lua:1-9` was re-verified against current snacks source and
  still holds.
- **The `vim.lsp.config("*")` + per-server `vim.lsp.config()` +
  mason-lspconfig `automatic_enable` pattern in lsp.lua** — matches the
  current recommended setup; `automatic_enable` defaults to true in the
  installed mason-lspconfig. No legacy `require('lspconfig')` calls
  exist anywhere in the config (grep verified); the installed
  nvim-lspconfig README confirms the plugin itself is not deprecated —
  only that legacy framework is. Remaining *structural* modernization
  options (file-based `after/lsp/<server>.lua` overrides, explicit
  `vim.lsp.enable()` vs mason-lspconfig, flattening the spec) are
  written up in
  `todos/native-replacements/…-lsp-config-structure-modernization.md`.

## Priority recommendation

Highest value first:

1. The two silent-misbehavior bugs: `constrast` typo, `<leader>fd`
   duplicate.
2. The 0.13 deprecations (`vim.highlight`, `supports_method` dot-call) —
   these warn today and the dot-call's removal target is the running
   version.
3. The fzf-lua `jump1` refactor — deletes ~80 lines including two of the
   deprecation call sites and four latent bugs.
4. lazydev luvit-meta fix (restores `vim.uv` completion in config work).
5. Remove the showMessage override (restores correct notify levels).
6. Everything else per todo files.
