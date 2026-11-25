return {
  {
    -- Loaded at startup without a lazy-load trigger: mason's setup puts its
    -- bin directory on PATH, which lua/mrjakob/lsp.lua relies on when it
    -- enables the servers.
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      -- Mason installs two groups of packages:
      --
      --   1. The LSP server binaries, taken straight from the server registry
      --      (lua/mrjakob/servers.lua) so the install list can never drift from
      --      the enabled list. Add a server there, not here.
      --
      --   2. Standalone CLI tools (formatters, linters, build tooling) that are
      --      not language servers. Add those to `tools` below, using the Mason
      --      package name (look it up with `:Mason`).
      local servers = require("mrjakob.servers")

      local tools = {
        "shellcheck",
        "stylua",
        "prettierd",
        "tree-sitter-cli",
      }

      -- Servers with value `false` are managed outside Mason (e.g. via cargo);
      -- filter them out so mason-tool-installer only sees valid package names.
      local mason_packages = vim.tbl_filter(function(v)
        return v ~= false
      end, vim.tbl_values(servers))
      local ensure_installed = vim.list_extend(mason_packages, tools)

      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
      })
    end,
  },
}
