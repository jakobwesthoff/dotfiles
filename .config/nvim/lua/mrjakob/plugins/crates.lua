-- Some nice to have features on Cargo Crates.io files
return {
  "saecki/crates.nvim",
  -- Follow upstream's stable release channel only rather than tracking
  -- the default branch.
  tag = "stable",
  event = { "BufRead Cargo.toml" },
  config = function()
    require("crates").setup({
      -- crates' in-process language server: code actions, completion and
      -- hover for Cargo.toml through the regular LSP keymaps.
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    })
  end,
}
