# Lazy-loading hygiene across plugin specs

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`). One topic: each spec's load trigger
matching how the plugin is actually used. All facts verified against
the installed plugin sources / config on 2026-06-11.

## Per-plugin items

1. **obsidian.lua:3-4 — `lazy = false` and `ft = "markdown"` together.**
   lazy.nvim computes laziness from `event/keys/ft/cmd` only when
   `plugin.lazy == nil` (installed lazy.nvim,
   `lua/lazy/core/plugin.lua:233-243`); explicit `lazy = false` wins.
   Current effect: eager load at startup, the `ft` handler is inert.
   Decide one: `ft = "markdown"` alone (lazy; obsidian commands
   unavailable until a markdown buffer opens) or `lazy = false` alone
   (eager; commands always available). The pair as written is
   misleading about what actually happens.

2. **template-string.lua — eager load for a 9-filetype plugin.**
   The plugin only acts on `html, typescript, javascript,
   typescriptreact, javascriptreact, vue, svelte, python, cs`
   (installed template-string.nvim README.md:50). Add
   `ft = { "html", "typescript", "javascript", "typescriptreact",
   "javascriptreact", "vue", "svelte", "python", "cs" }`.

3. **todo.lua — no trigger; all call sites are lazy-safe.**
   Every use lives inside closures (`keymaps.lua:176-185`), so
   `event = "VeryLazy"` works. Note the plugin also provides buffer
   highlighting of TODO comments — `VeryLazy` still covers buffers
   opened at startup since highlighting attaches on events after load;
   verify visually that TODO highlights still appear in a file opened
   directly from the shell.

4. **highlight-colors.lua — no trigger; also uses `config` where `opts`
   suffices.** `event = { "BufReadPre", "BufNewFile" }` plus
   `opts = { render = "virtual", virtual_symbol = "󰧞" }` replaces the
   `config = function()` block.

5. **undotree.lua — `lazy = false` for a command-only plugin.**
   Only entry point is `<leader>uu` → `:UndotreeToggle`
   (keymaps.lua:189-191). If the plugin survives the fzf-lua undotree
   evaluation (`todos/native-replacements/*-undotree-to-fzf-lua-undotree.md`),
   use `cmd = "UndotreeToggle"`.

6. **snacks.lua — missing `priority = 1000, lazy = false`.**
   Upstream README recommends both (installed snacks README.md:74-75).
   With only `indent` enabled the practical impact today is low, but it
   matters as soon as more snacks modules are enabled (e.g. the zen
   consolidation todo).

## Explicit non-items (checked, leave as-is)

- **oil.nvim eager load**: upstream README recommends *against*
  lazy-loading oil ("Lazy loading is not recommended because it is very
  tricky to make it work correctly", installed oil README.md:44-45).
- **conform / autopairs / ts-autotag / flash / crates / which-key /
  zen-mode / lazydev**: already have appropriate triggers.
- **fzf-lua, lualine, gruvbox-material, treesitter, lsp stack**: needed
  at startup (keymaps.lua requires fzf-lua at source time; colorscheme
  and statusline are startup UI; FileType/LSP wiring must exist before
  first buffer).

## Honest framing

This config is small; the startup win is likely milliseconds. The real
value is specs that *say what they mean* (obsidian's contradictory
pair, undotree's eager load) rather than raw speed. Measure with
`nvim --startuptime /tmp/st.log` before/after if speed is the
motivation.
