-- Override of nvim-lspconfig's yamlls config (merged on top of its defaults).
-- Restrict yamlls to the "yaml" filetype so it never attaches to helm
-- templates (filetype "helm" via ftdetect/helm.lua).
return {
  filetypes = { "yaml" },
}
