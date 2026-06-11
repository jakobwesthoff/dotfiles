# Used Plugins & Tooling Overview

Snapshot date: 2026-06-11. One line per item: what it does and what we
use it for. Specs live in `lua/mrjakob/plugins/`.

## Plugin management

- **lazy.nvim** — plugin manager; bootstrapped in `setup.lua`, lockfile
  `lazy-lock.json`.

## Appearance / UI

- **gruvbox-material.nvim** (f4z3r fork) — colorscheme; transparent
  background plus custom highlight tweaks (cursorline number, paren
  matching, popup backgrounds, search colors).
- **lualine.nvim** — statusline; custom mode colors from the theme
  palette, per-window statuslines with window numbers (used by the
  `<Leader>1-6` window jumps), responsive truncation.
- **nvim-web-devicons** — filetype icons (dependency of lualine,
  fzf-lua, oil).
- **which-key.nvim** — popup showing pending keybindings and leader
  groups.
- **snacks.nvim** — plugin collection; we only enable its `indent`
  module for current-scope indent guides.
- **zen-mode.nvim** — distraction-free editing on `<leader>z` (width
  100, disables indent guides while active).
- **fidget.nvim** — LSP progress display bottom-right; also renders all
  `vim.notify` messages (`override_vim_notify = true`).
- **dressing.nvim** — styled `vim.ui.input` (LSP rename prompt).
  Archived upstream; kept because snacks.input has a cursor-placement
  bug with default text (documented in the spec).
- **nvim-highlight-colors** — shows color values (hex etc.) as virtual
  swatches next to the code.

## Navigation / search

- **fzf-lua** — fuzzy finder for everything: files, grep, buffers,
  help, LSP pickers; also the `vim.ui.select` provider; custom
  `FzfDirectories` command opening results in oil.
- **oil.nvim** — file manager as editable buffer; `-` opens the parent
  directory in a float.
- **flash.nvim** — jump motions: `s` jump, `S` treesitter node select,
  `R` treesitter search in operator/visual mode.
- **harpoon (harpoon2 branch)** — pin frequently used files;
  `<leader>a` add, `<leader>l` list, `<leader>q/w/e/r/t` jump to pins
  1-5.
- **todo-comments.nvim** — highlights TODO/FIXME/HACK comments;
  `]t`/`[t` navigation and an fzf picker on `<leader>ft`.
- **taproot.nvim** (own plugin) — automatic project-root detection and
  `cd`, LSP-first with file-marker fallback.

## Editing

- **mini.ai** — richer `a`/`i` textobjects (arguments, function calls,
  …).
- **mini.bracketed** — `[`/`]` navigation targets (comments, files,
  indent, undo states, …).
- **vim-sleuth** — heuristically sets buffer indent settings from file
  content.
- **nvim-autopairs** — auto-insert closing brackets/quotes in insert
  mode.
- **nvim-ts-autotag** — auto-close/rename HTML/JSX tags via
  treesitter.
- **template-string.nvim** — auto-converts quotes to template strings
  when typing `${}` in JS/TS-family files.
- **undotree** — visual undo-history tree on `<leader>uu`.

## Treesitter

- **nvim-treesitter (main branch)** — parser installation and
  management; highlighting is started per FileType autocmd with
  on-demand parser install. ~25 parsers ensure-installed.

## LSP & completion stack

- **nvim-lspconfig** — collection of per-server base configs (its
  `lsp/` directory; the legacy `require('lspconfig')` framework is not
  used). Customization happens natively via `vim.lsp.config()` in
  `lsp.lua`.
- **mason.nvim** — installer for LSP servers, formatters, linters
  (`:Mason`).
- **mason-lspconfig.nvim** — auto-enables installed servers via
  `vim.lsp.enable()` (`automatic_enable`).
- **mason-tool-installer.nvim** — declarative `ensure_installed` list
  (servers + tools, see below).
- **blink.cmp** — completion engine: LSP, path, snippets, buffer
  sources; ghost text, signature help, auto documentation. `<C-Z>`
  accept (QWERTZ-friendly).
- **lazydev.nvim** — lua_ls workspace setup for Neovim config/plugin
  development (API completion in Lua files).
- **rustaceanvim** — Rust: configures and manages rust-analyzer itself
  (outside mason/lspconfig) plus extra `:RustLsp` tooling.
  rust-analyzer comes from `rustup component add rust-analyzer`.
- **crates.nvim** — Cargo.toml assistance: version completion, hover,
  update actions via its in-process LSP.
- **conform.nvim** — formatting on save and `<leader>cf`, with
  LSP fallback.
- **plenary.nvim** — Lua utility library (dependency of harpoon,
  obsidian, todo-comments).

## Notes

- **obsidian.nvim** (obsidian-nvim community fork) — Obsidian vault
  integration (wiki links, completion via blink) for the private vault
  in iCloud.

## Language servers (mason `ensure_installed`)

| Server | Language |
|---|---|
| lua_ls | Lua |
| marksman | Markdown |
| ts_ls | TypeScript/JavaScript |
| taplo | TOML |
| phpactor | PHP |
| bashls | Bash (uses shellcheck for diagnostics) |
| dockerls | Dockerfile |
| docker_compose_language_service | docker-compose |
| helm_ls | Helm charts |
| yamlls | YAML (restricted to ft `yaml`, keeps off helm) |
| jsonls | JSON |
| clangd | C/C++ (incl. embedded cross-compilers via `--query-driver`) |
| rust-analyzer | Rust — via rustup, *not* mason (rustaceanvim requirement) |

## Other tools (mason / conform)

- **stylua** — Lua formatter.
- **prettierd / prettier** — JS/TS/JSON/YAML formatter (daemon first,
  fallback CLI).
- **clang-format** — C/C++ formatter (format-on-save disabled for
  c/cpp; manual only).
- **scf-docker** — project-specific PHP formatter via the scf repo's
  docker wrapper script.
- **shellcheck** — shell linter (consumed by bashls).
- **tree-sitter-cli** — parser build tool for nvim-treesitter.

## Homegrown modules (`lua/mrjakob/`)

- **setup.lua** — leader key, lazy.nvim bootstrap, module loading.
- **options.lua** — core options (incl. QWERTZ `ü`/`+` → `[`/`]`
  langmap, `cmdheight=0`, `winborder="rounded"`).
- **keymaps.lua** — general and LSP keymaps (fzf-backed pickers).
- **autocmds.lua** — yank highlight; manual OSC 52 clipboard escape on
  yank.
- **lastpos.lua** — restore cursor position when reopening files.
- **util.lua** — highlight-group color helpers for theming.
- **ftdetect/helm.lua** — helm filetype detection for chart files.
- **after/ftplugin/php.lua** — `$` in iskeyword for phpactor
  completion.
