return {
  "williamboman/mason.nvim",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()

    require("mason-tool-installer").setup({
      ensure_installed = {
        -- LSP servers
        "lua_ls",
        "marksman",
        "ts_ls",
        "taplo",
        "phpactor",
        "bashls",
        "dockerls",
        "docker_compose_language_service",
        "helm_ls",
        "yamlls",
        "jsonls",
        "clangd",
        -- Formatters / linters
        "shellcheck",
        "stylua",
        "prettierd",
        -- Build tools
        "tree-sitter-cli",
      },
    })
  end,
}
