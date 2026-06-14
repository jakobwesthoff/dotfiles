-- =============================================================================
-- LSP wiring — the behavior shared by every language server.
--
-- Required once from lua/mrjakob/setup.lua, after lazy.nvim has loaded the
-- plugins (so blink.cmp and nvim-lspconfig are available). This file holds the
-- cross-cutting setup only; the two other concerns live elsewhere:
--
--   * WHICH servers to enable      -> lua/mrjakob/servers.lua
--   * per-server SETTINGS overrides -> after/lsp/<server name>.lua
-- =============================================================================

-- Advertise blink.cmp's completion capabilities to every server. The "*"
-- wildcard config is merged into every server's resolved config, so this is
-- the one place capabilities need to be set.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- On attach, give servers that support inlay hints a buffer-local toggle.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("mrjakob-lsp-attach", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      vim.keymap.set("n", "<leader>uh", function()
        local buf = vim.api.nvim_get_current_buf()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
      end, { buffer = event.buf, desc = "Toggle [U]i Inlay [H]ints" })
    end
  end,
})

-- Diagnostic symbols in the sign column (gutter).
local signs = { ERROR = "", WARN = "", INFO = "", HINT = "" }
local diagnostic_signs = {}
for type, icon in pairs(signs) do
  diagnostic_signs[vim.diagnostic.severity[type]] = icon
end
-- Inline virtual_text/virtual_lines are intentionally left off: diagnostics
-- are surfaced through the gutter signs, the `gl` float on demand, the lualine
-- component, and [d/]d navigation, which keeps buffer text uncluttered.
vim.diagnostic.config({ signs = { text = diagnostic_signs } })

-- Enable every server from the registry. nvim-lspconfig supplies each server's
-- base config (its lsp/<name>.lua on the runtimepath); our after/lsp/<name>.lua
-- files and the "*" config above layer on top via the documented merge order.
vim.lsp.enable(vim.tbl_keys(require("mrjakob.servers")))
