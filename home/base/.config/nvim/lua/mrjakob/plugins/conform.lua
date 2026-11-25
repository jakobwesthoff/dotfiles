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
      mode = { "n", "x" },
      desc = "[C]ode [F]ormat",
    },
  },
  opts = {
    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype

      -- Filetypes that are never formatted on save. Returning nothing skips
      -- the format (conform's recipe for per-filetype opt-outs).
      local ignore_filetypes = {}
      if ignore_filetypes[ft] then
        return
      end

      -- Languages without a well standardized coding style get no LSP
      -- formatting as a fallback when no conform formatter is configured.
      local no_lsp_fallback = { c = true, cpp = true }
      -- Formatters slower than the default timeout.
      local timeout_override = { php = 5000 }

      return {
        timeout_ms = timeout_override[ft] or 500,
        lsp_format = no_lsp_fallback[ft] and "never" or "fallback",
      }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      php = { "scf-docker" },
      yaml = { "prettierd" },
      cpp = { "clang-format" },
      c = { "clang-format" },
    },
    formatters = {
      ["scf-docker"] = {
        command = "/Users/jakob/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh",
        args = { "format", "--filepath-for-matcher", "$FILENAME" },
        stdin = true,
        -- Without this guard a missing wrapper makes the formatter silently
        -- unavailable (no warning fires for formatters_by_ft entries) and PHP
        -- saves quietly fall through to LSP formatting. Surface it instead.
        condition = function(self, ctx)
          if vim.fn.executable(self.command) == 1 then
            return true
          end
          vim.notify_once("scf-docker formatter missing: " .. self.command, vim.log.levels.WARN)
          return false
        end,
      },
    },
  },
}
