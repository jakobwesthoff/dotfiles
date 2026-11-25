-- Override of nvim-lspconfig's lua_ls config (merged on top of its defaults).
return {
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = { disable = { "missing-fields" } },
    },
  },
}
