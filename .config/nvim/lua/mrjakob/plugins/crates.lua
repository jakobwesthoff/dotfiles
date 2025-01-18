-- Some nice to have features on Cargo Crates.io files
return {
  "saecki/crates.nvim",
  tag = "stable",
  event = { "BufRead Cargo.toml" },
  config = function()
    require("crates").setup({
      lsp = {
        enabled = true,
        -- Handled by our LspAttach Autocommand
        -- on_attach = function(client, bufnr)
        --   -- the same on_attach function as for your other lsp's
        -- end,
        actions = true,
        completion = true,
        hover = true,
      },
      completion = {
        crates = {
          enabled = true,
          max_results = 8,
          min_chars = 3,
        },
      },
    })
  end,
}
