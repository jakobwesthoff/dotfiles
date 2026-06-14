-- Detect helm charts as the `helm` filetype. Neovim has no native helm
-- detection, so register it via vim.filetype.add (pattern keys are Lua
-- patterns, not globs). ftdetect files are sourced at startup.
vim.filetype.add({
  pattern = {
    -- Templated manifests and helper templates live under templates/.
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
  },
  filename = {
    -- Chart.yaml only exists at a chart root, so it is unambiguous.
    ["Chart.yaml"] = "helm",
    -- values.yaml is a common name; only treat it as helm when it sits
    -- next to a Chart.yaml, otherwise leave it as plain yaml so yamlls
    -- still attaches in unrelated projects.
    ["values.yaml"] = function(path)
      if vim.uv.fs_stat(vim.fs.dirname(path) .. "/Chart.yaml") then
        return "helm"
      end
      return "yaml"
    end,
  },
})
