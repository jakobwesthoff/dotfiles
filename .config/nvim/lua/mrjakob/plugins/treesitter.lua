return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    -- Ensure these parsers are installed
    require("nvim-treesitter").install({
      "bash",
      "c",
      "diff",
      "html",
      "just",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "vim",
      "vimdoc",
    })

    -- The new main branch no longer enables highlighting/indent
    -- automatically. Enable tree-sitter highlighting for every buffer
    -- that has a parser available.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
