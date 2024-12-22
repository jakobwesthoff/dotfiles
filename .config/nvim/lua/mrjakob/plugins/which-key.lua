return { -- Useful plugin to show you pending keybinds.
  "folke/which-key.nvim",
  event = "VimEnter", -- Sets the loading event to 'VimEnter'
  opts = {
    preset = "helix",
    delay = 0,
    win = {
      height = {
        max = math.huge,
      },
    },
    icons = {
      rules = false,
      breadcrumb = " ", -- symbol used in the command line area that shows your active key combo
      separator = "󱦰  ", -- symbol used between a key and it's label
      group = "󰹍 ", -- symbol prepended to a group
    },
    -- Document existing key chains
    spec = {
      { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>r", group = "[R]ename" },
      { "<leader>f", group = "[F]ind" },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>u", group = "[U]i" },
      { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
    },
  },
}
