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
      menu = {},
      ghost_text = {
        enabled = true,
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          desired_min_width = 30,
        },
      },
    },

    signature = { enabled = true },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      -- lazydev completes module names in require() and ---@module for the
      -- Neovim config and plugins. Lua buffers only; the rest keep the
      -- default sources.
      per_filetype = {
        lua = { inherit_defaults = true, "lazydev" },
      },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- Rank its module names above the LSP's generic suggestions.
          score_offset = 100,
        },
      },
    },
  },
}
