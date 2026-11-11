return {
  {
    "nvim-mini/mini.ai",
    opts = {
      -- mini's default next/last variants (an/in/al/il) take over Neovim's
      -- own an/in (tree-sitter incremental selection) and al/il (whole
      -- buffer, line without surrounding whitespace). Moving mini's variants
      -- to capital letters keeps both: e.g. `ciN)` changes inside the next
      -- parentheses, `van` grows the selection node by node.
      mappings = {
        around_next = "aN",
        inside_next = "iN",
        around_last = "aL",
        inside_last = "iL",
      },
    },
  },
  {
    "nvim-mini/mini.bracketed",
    -- mini keeps owning buffer/diagnostic/location/quickfix even though
    -- Neovim 0.11 ships native bracket maps for them: mini adds counts,
    -- wraparound, and Visual/Operator-pending modes that the native maps
    -- lack. The global u/<C-R> undo-state remap (the `undo` target) is also
    -- kept on purpose so [u/]u can walk the undo history.
    --
    -- The `comment` target (suffix c) is kept for jumping between comment
    -- blocks. It takes [c/]c from diff mode (previous/next change) and
    -- [C/]C from Neovim's multicursor jumps.
    opts = {
      -- ]t/[t are owned by todo-comments (normal mode) and native tag
      -- navigation; disable mini's treesitter motion so those keys are not
      -- claimed across Visual/Operator-pending mode as well.
      treesitter = { suffix = "" },
    },
  },
}
