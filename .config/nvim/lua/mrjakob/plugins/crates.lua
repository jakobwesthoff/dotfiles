-- Some nice to have features on Cargo Crates.io files
return {
  "saecki/crates.nvim",
  tag = "stable",
  event = { "BufRead Cargo.toml" },
  config = function()
    require("crates").setup({
      completion = {
        cmp = {
          enabled = true,
        },
      },
    })
  end,
}
