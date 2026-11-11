-- LSP progress + notifications in the bottom-right corner.
return {
  "j-hui/fidget.nvim",
  opts = {
    notification = {
      override_vim_notify = true,
    },
  },
}
