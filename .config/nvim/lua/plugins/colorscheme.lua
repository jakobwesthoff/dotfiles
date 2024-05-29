return {
  -- { "shaunsingh/solarized.nvim" },
  -- { "LazyVim/LazyVim", opts = {
  --   colorscheme = "solarized"
  -- } },
  --  { "overcache/NeoSolarized" },
  --  { "LazyVim/LazyVim", opts = {
  --    colorscheme = "NeoSolarized",
  --  } },
  --  { "maxmx03/solarized.nvim" },
  --  { "LazyVim/LazyVim", opts = {
  --    colorscheme = "solarized",
  --  } },
  --  { "ellisonleao/gruvbox.nvim"},
  -- { "LazyVim/LazyVim", opts = {
  --   colorscheme = "gruvbox",
  -- } },
  --  { "ishan9299/nvim-solarized-lua" },
  --  { "LazyVim/LazyVim", opts = {
  --    colorscheme = "solarized-high",
  --  } },
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_enable_italic = true
      vim.cmd.colorscheme('gruvbox-material')
    end
  }
}
