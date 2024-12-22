return {
  "saghen/blink.cmp",
  -- use a release tag to download pre-built binaries
  version = "v0.7.6",

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    impersonate_nvim_cmp = true,
    keymap = {
      preset = "default",
      -- Map C-Z in conjunction with C-Y for completion, as we are on a QWRTZ
      -- keyboard.
      ["<C-Z>"] = { "accept", "fallback" },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    completion = {
      menu = {
        border = "rounded",
      },
      ghost_text = {
        enabled = true,
      },
      trigger = {
        -- Disable if preset super-tab is used
        show_in_snippet = true,
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        -- update_delay_ms = 0,

        window = {
          border = "rounded",
          desired_min_width = 30,
          -- direction_priority = {
          --   menu_north = { "s", "n", "e", "w" },
          --   menu_south = { "n", "s", "e", "w" },
          -- },
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },

  config = function(_, opts)
    local U = require("mrjakob.util")
    U.newColorWithBase("CmpGhostText", "NonText")
    require("blink-cmp").setup(opts)
  end,
}
