-- ntropy LSP — Markdown note system (https://github.com/jakobwesthoff/ntropy)
--
-- Only activates for markdown files that live inside an ntropy vault. Vault
-- detection walks up the directory tree looking for either a `.ntropy/`
-- directory (the vault root itself) or a `.ntropy-vault` pointer file. If
-- neither is found, `on_dir` is never called and the server stays dormant,
-- leaving non-vault markdown files unaffected.
--
-- Install the binary: cargo install ntropy
return {
  cmd = { "ntropy", "lsp" },
  filetypes = { "markdown" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { ".ntropy", ".ntropy-vault" })
    if root then
      on_dir(root)
    end
  end,
}
