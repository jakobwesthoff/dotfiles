return {
  "nvim-treesitter/nvim-treesitter",
  -- Track the `main` rewrite branch; `master` is frozen and the config
  -- uses the new-branch API.
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    -- Ensure these parsers are installed
    require("nvim-treesitter").install({
      "bash",
      "c",
      "css",
      "diff",
      "git_rebase",
      "gitcommit",
      "gitignore",
      "html",
      "javascript",
      "json",
      "just",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "rust",
      "ssh_config",
      "tmux",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
    })

    -- The new main branch no longer provides auto_install or automatic
    -- highlighting. This autocmd handles both: if a parser is missing,
    -- install it on demand, then enable tree-sitter highlighting.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

        -- Tree-sitter based folding for this window. foldexpr() returns 0 for
        -- buffers without a parser, so setting it here is harmless for
        -- filetypes that never start tree-sitter.
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

        if pcall(vim.treesitter.language.inspect, lang) then
          pcall(vim.treesitter.start, ev.buf, lang)
          return
        end

        -- A missing parser is installed on demand, but install() is
        -- asynchronous: starting highlighting on the next line would run before
        -- the parser exists, leaving the first buffer of a freshly installed
        -- language unhighlighted until it is reloaded. Await the install and
        -- start in its callback instead. The parsers[lang] guard skips
        -- languages that have no grammar, avoiding "unsupported language" noise.
        if require("nvim-treesitter.parsers")[lang] then
          require("nvim-treesitter").install({ lang }):await(function()
            -- The buffer may have been wiped during the async install.
            if vim.api.nvim_buf_is_valid(ev.buf) then
              pcall(vim.treesitter.start, ev.buf, lang)
            end
          end)
        end
      end,
    })
  end,
}
