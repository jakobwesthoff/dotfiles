return {
  {
    "echasnovski/mini.ai",
    opts = {},
  },
  {
    "echasnovski/mini.bracketed",
    -- mini keeps owning buffer/diagnostic/location/quickfix even though
    -- Neovim 0.11 ships native bracket maps for them: mini adds counts,
    -- wraparound, and Visual/Operator-pending modes that the native maps
    -- lack. The global u/<C-R> undo-state remap (the `undo` target) is also
    -- kept on purpose so [u/]u can walk the undo history.
    opts = {
      -- ]t/[t are owned by todo-comments (normal mode) and native tag
      -- navigation; disable mini's treesitter motion so those keys are not
      -- claimed across Visual/Operator-pending mode as well.
      treesitter = { suffix = "" },
    },
  },
}
