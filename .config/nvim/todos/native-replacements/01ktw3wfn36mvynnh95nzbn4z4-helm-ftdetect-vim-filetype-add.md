# Modernize helm filetype detection: autocmd ftdetect → vim.filetype.add()

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`ftdetect/helm.lua` uses a BufRead/BufNewFile autocmd with
`vim.opt_local.filetype = "helm"` for the patterns
`*/templates/*.yaml`, `*/templates/*.tpl`, `values.yaml`, `Chart.yaml`.

Two issues:

1. **Mechanism.** The autocmd-based ftdetect pattern predates
   `vim.filetype.add()`, which is the structured detection mechanism
   since 0.8 and integrates with the priority/ordering of
   `vim.filetype.match`. (Also, when setting a filetype directly,
   `vim.bo.filetype = "helm"` is the simpler form vs creating an
   `Option` object via `vim.opt_local`.)
2. **Over-broad patterns.** The bare `values.yaml` / `Chart.yaml`
   filenames match those names in *any* directory of *any* project; a
   `values.yaml` in a non-helm repo gets filetype helm and loses yamlls
   (lsp.lua:91-93 restricts yamlls to ft `yaml` precisely to keep it
   off helm buffers).

Detection itself is still required: the running build has **no native
helm detection** — headless probe of `vim.filetype.match`:

- `mychart/templates/foo.yaml` → `yaml`
- `mychart/templates/_helpers.tpl` → `smarty`
- `Chart.yaml` / `values.yaml` → `yaml`

## Evidence / basis

- Config read: `ftdetect/helm.lua`, `lsp.lua:89-93` (yamlls filetype
  restriction documenting the helm interplay).
- Headless probe on NVIM v0.13.0-dev-2756 (results above, run
  2026-06-11).

## Fix

Replace `ftdetect/helm.lua` with a `vim.filetype.add` call (can live in
the same file; ftdetect files are sourced at startup):

```lua
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
  },
  filename = {
    -- Only treat Chart.yaml itself as helm-related YAML; values.yaml
    -- needs a context check, see below.
    ["Chart.yaml"] = "yaml",  -- decide: helm or plain yaml + schema
  },
})
```

For `values.yaml`, a function matcher can scope detection to actual
chart directories (a sibling `Chart.yaml`):

```lua
filename = {
  ["values.yaml"] = function(path, bufnr)
    if vim.uv.fs_stat(vim.fs.dirname(path) .. "/Chart.yaml") then
      return "helm"
    end
    return "yaml"
  end,
},
```

Note `vim.filetype.add` pattern keys are **Lua patterns**, not globs —
`.*/templates/.*%.yaml`, not `*/templates/*.yaml`.

## Open decision

Whether `Chart.yaml` and `values.yaml` should be ft `helm` at all: they
are plain YAML (no Go templating); helm_ls handles them as part of a
chart, yamlls would give schema-less plain YAML. The current config
makes them `helm`. Decide intentionally and encode it; the function
matcher above shows the shape for either choice.

## Verification

`:set ft?` in: a chart's `templates/*.yaml`, a chart's `values.yaml`, a
non-chart `values.yaml` (e.g. some random repo), and a `.tpl` helper.
Expected: helm, helm (or yaml per decision), yaml, helm.
