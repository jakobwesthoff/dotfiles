return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = false,
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "giuxtaposition/blink-cmp-copilot",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
  },
}
