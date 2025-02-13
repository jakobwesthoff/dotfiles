-- For yaml files in a "helm-like" environment use the helm ft
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*/templates/*.yaml", "*/templates/*.tpl", "values.yaml", "Chart.yaml" },
  callback = function()
    vim.opt_local.filetype = "helm"
  end,
})
