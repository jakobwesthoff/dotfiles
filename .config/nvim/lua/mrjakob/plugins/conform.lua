return { -- Autoformat
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[C]ode [F]ormat",
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_lsp_filetypes = { c = true, cpp = true }
      -- Override the default timeout_ms value for specific languages
      local default_timeout = 500
      local timeout_override = { php = 5000 }
      -- Disable formatting on save completely for certain languages
      local disable_filetypes = {}

      local lsp_format_opt
      if disable_lsp_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = "never"
      else
        lsp_format_opt = "fallback"
      end

      local timeout = default_timeout
      if timeout_override[vim.bo[bufnr].filetype] then
        timeout = timeout_override[vim.bo[bufnr].filetype]
      end

      if disable_filetypes[vim.bo[bufnr].filetype] then
        return {
          formatters = {},
          lsp_format = "never",
        }
      else
        return {
          timeout_ms = timeout,
          lsp_format = lsp_format_opt,
        }
      end
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      php = { "scf-docker" },
    },
    formatters = {
      ["scf-docker"] = {
        command = "/Users/jakob/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh",
        args = { "format", "--filepath-for-matcher", "$FILENAME" },
        stdin = true,
      },
    },
  },
}
