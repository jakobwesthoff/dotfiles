-- Detect helm charts as the `helm` filetype. Neovim has no native helm
-- detection, so register it via vim.filetype.add (pattern keys are Lua
-- patterns, not globs). ftdetect files are sourced at startup.

-- Templated manifests and helper templates live under a chart's templates/
-- directory. Other tools use templates/ directories for plain YAML too
-- (Ansible roles, CI templates), so only claim the file when a Chart.yaml
-- sits somewhere above it. Returning nil leaves the file to the regular
-- detection.
local function helm_if_in_chart(path)
  if vim.fs.root(path, "Chart.yaml") then
    return "helm"
  end
end

vim.filetype.add({
  pattern = {
    [".*/templates/.*%.ya?ml"] = helm_if_in_chart,
    [".*/templates/.*%.tpl"] = helm_if_in_chart,
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
