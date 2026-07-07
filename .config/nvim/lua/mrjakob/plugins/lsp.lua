return {
  {
    -- nvim-lspconfig is used purely as a data provider: it ships the per-server
    -- base configs under its `lsp/` directory. The actual wiring (capabilities,
    -- attach behavior, diagnostics, enabling) lives in lua/mrjakob/lsp.lua, the
    -- enabled-server list in lua/mrjakob/servers.lua, and per-server overrides
    -- in after/lsp/<name>.lua. Loaded eagerly so its configs are on the
    -- runtimepath when servers attach.
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      -- LSP progress + notifications in the bottom-right corner.
      {
        "j-hui/fidget.nvim",
        opts = {
          notification = {
            override_vim_notify = true,
          },
        },
      },
      -- Provides the completion capabilities broadcast in lua/mrjakob/lsp.lua.
      "saghen/blink.cmp",
    },
  },
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- Rustacean vim for all our Rust needs
  -- INFO: We can't install rust-analyzer via Mason, as this will conflict with
  -- rustaceanvim. Therefore ensure it is installed manually for example using
  -- rustup and available in the path. This has the added benefit, of having
  -- the rust-analyzer in the version fitting our current rust installation:
  --
  -- ```shell
  -- rustup component add rust-analyzer
  -- ```
  {
    "mrcjkb/rustaceanvim",
    -- Pin to the current major to avoid surprise breaking-major upgrades.
    version = "^9",
    lazy = false, -- This plugin is already lazy
  },
}
