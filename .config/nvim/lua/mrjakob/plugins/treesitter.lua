-- Parsers installed up front. Any other language gets its parser on demand
-- the first time a buffer of that filetype opens (see the FileType autocmd).
local ensure_installed = {
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
}

-- Tree-sitter folding, set window-local in every window showing `buf`. Only
-- buffers where tree-sitter actually runs get it, so buffers without a parser
-- keep 'foldmethod' "manual" and `zf` keeps working there.
local function enable_folds(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    -- `vim.wo[win][0]` addresses the buffer shown in `win`; only bufnr 0 is
    -- accepted there.
    vim.wo[win][0].foldmethod = "expr"
    vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end
end

-- A parser that does not match its queries makes vim.treesitter.start throw.
-- Surface that instead of leaving the buffer silently without highlighting.
local function start(buf, lang)
  local ok, err = pcall(vim.treesitter.start, buf, lang)
  if not ok then
    vim.notify_once(("tree-sitter failed to start for %s: %s"):format(lang, err), vim.log.levels.WARN)
    return
  end
  enable_folds(buf)
end

return {
  "nvim-treesitter/nvim-treesitter",
  -- Track the `main` rewrite branch; `master` is frozen and the config
  -- uses the new-branch API.
  branch = "main",
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    ts.setup()

    -- Parsers on the runtimepath take precedence by order, so a parser left
    -- inside a plugin directory (for example build output from an older
    -- branch of nvim-treesitter) shadows the one nvim-treesitter installs and
    -- fails against its queries. nvim-treesitter installs into
    -- stdpath("data")/site, and Neovim ships its own under $VIMRUNTIME, so a
    -- parser under the lazy.nvim plugin root is always such a leftover.
    local plugin_root = vim.fn.stdpath("data") .. "/lazy/"
    local leftovers = vim.tbl_filter(function(path)
      return vim.startswith(path, plugin_root)
    end, vim.api.nvim_get_runtime_file("parser/*.so", true))
    if #leftovers > 0 then
      -- Deferred so the warning reaches the message UI set up at the end of
      -- startup instead of the bare startup screen.
      vim.schedule(function()
        vim.notify(
          "tree-sitter parsers inside plugin directories shadow the installed ones; delete them and run :TSUpdate:\n"
            .. table.concat(leftovers, "\n"),
          vim.log.levels.WARN
        )
      end)
    end

    -- nvim-treesitter counts a language as installed when either its parser
    -- or its queries exist, so a language whose queries survived without the
    -- parser is skipped by install() and :TSUpdate. Decide by the parser file
    -- instead and force the install for anything missing.
    local installed_parsers = require("nvim-treesitter.config").get_installed("parsers")
    local missing = vim.tbl_filter(function(lang)
      return not vim.list_contains(installed_parsers, lang)
    end, ensure_installed)
    if #missing > 0 then
      ts.install(missing, { force = true })
    end

    -- The main branch provides neither auto_install nor automatic
    -- highlighting. This autocmd handles both: install a missing parser on
    -- demand, then start tree-sitter highlighting and folding.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
        local has_grammar = require("nvim-treesitter.parsers")[lang] ~= nil
        local has_parser = vim.list_contains(require("nvim-treesitter.config").get_installed("parsers"), lang)

        -- Languages nvim-treesitter knows always run on its own parser, the
        -- one its queries are written against. Everything else runs on
        -- whatever parser the runtimepath offers (Neovim bundles a few).
        if not has_grammar or has_parser then
          if vim.treesitter.language.add(lang) then
            start(ev.buf, lang)
          end
          return
        end

        -- install() is asynchronous: starting on the next line would run
        -- before the parser exists, leaving the first buffer of a freshly
        -- installed language unhighlighted until it is reloaded. Await the
        -- install and start in its callback instead.
        ts.install({ lang }, { force = true }):await(function()
          -- The buffer may have been wiped during the async install.
          if vim.api.nvim_buf_is_valid(ev.buf) and vim.treesitter.language.add(lang) then
            start(ev.buf, lang)
          end
        end)
      end,
    })
  end,
}
