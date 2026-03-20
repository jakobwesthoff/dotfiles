return {
  "saghen/blink.cmp",
  -- use a release tag to download pre-built binaries
  version = "v1.*",

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "default",
      -- Map C-Z in conjunction with C-Y for completion, as we are on a QWRTZ
      -- keyboard.
      ["<C-Z>"] = { "accept", "fallback" },
    },

    appearance = {
      nerd_font_variant = "mono",
    },

    completion = {
      menu = {
        border = "rounded",
      },
      ghost_text = {
        enabled = true,
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = "rounded",
          desired_min_width = 30,
        },
      },
    },

    signature = { enabled = true },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
