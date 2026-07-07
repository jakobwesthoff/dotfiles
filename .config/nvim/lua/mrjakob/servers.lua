-- =============================================================================
-- LSP server registry — the single source of truth for the language servers
-- this config uses. Every entry maps:
--
--     <lspconfig server name>  =  <mason package name | false>
--
--   * Key  — the server's nvim-lspconfig name. It is what `vim.lsp.enable()`
--            takes and the basename of the server's config under
--            nvim-lspconfig's `lsp/` directory. Look it up in the
--            nvim-lspconfig README server table or via `:checkhealth vim.lsp`.
--   * Value — the Mason package that installs the server binary. Look it up
--            with `:Mason` (press `/` to filter) or on the mason registry.
--            Use `false` for servers managed outside Mason (e.g. installed via
--            cargo/npm directly); Mason skips them, but the server is still
--            enabled and its `after/lsp/<name>.lua` config is applied.
--
-- This table is consumed in two places:
--   * lua/mrjakob/lsp.lua             enables the keys   (vim.lsp.enable)
--   * lua/mrjakob/plugins/mason.lua   installs the values (mason-tool-installer)
--
-- To add a server: add one line here. If it needs anything beyond the
-- nvim-lspconfig defaults, also create `after/lsp/<server name>.lua` returning
-- the override table (see the existing files there for the pattern).
--
-- rust-analyzer is deliberately NOT listed: rustaceanvim starts and configures
-- its own client (see lua/mrjakob/plugins/lsp.lua).
-- =============================================================================
return {
  astro = "astro-language-server",
  lua_ls = "lua-language-server",
  marksman = "marksman",
  ts_ls = "typescript-language-server",
  taplo = "taplo",
  phpactor = "phpactor",
  bashls = "bash-language-server",
  dockerls = "dockerfile-language-server",
  docker_compose_language_service = "docker-compose-language-service",
  helm_ls = "helm-ls",
  yamlls = "yaml-language-server",
  jsonls = "json-lsp",
  lemminx = "lemminx",
  clangd = "clangd",
  -- ntropy: installed via `cargo install ntropy`; no Mason package exists.
  -- The after/lsp/ntropy.lua config restricts activation to markdown files
  -- inside an ntropy vault (.ntropy or .ntropy-vault marker found up the tree).
  ntropy = false,
}
