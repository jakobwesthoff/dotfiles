return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "bash-language-server",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "json-lsp",
        "lua-language-server",
        "markdownlint",
        "marksman",
        "prettier",
        "rust-analyzer",
        "shellcheck",
        "shfmt",
        "stylua",
        "typescript-language-server",
        "yaml-language-server",
        "shellcheck",
      },
      auto_update = true,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 0,
    },
  },
}
