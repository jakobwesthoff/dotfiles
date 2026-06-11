# Harden the conform `scf-docker` PHP formatter (path missing, fails silently)

Created: 2026-06-11, from the full-config code review
(`docs/code-review-2026-06-11.md`).

## Problem

`lua/mrjakob/plugins/conform.lua:67-73` defines a custom formatter:

```lua
["scf-docker"] = {
  command = "/Users/jakob/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh",
  args = { "format", "--filepath-for-matcher", "$FILENAME" },
  stdin = true,
},
```

At review time that path does not exist on this machine (`ls` returned
"No such file or directory"). The failure mode is fully silent:

- conform marks the formatter unavailable;
- the "Formatter ... unavailable" warning fires only for *explicit*
  formatters, and `formatters_by_ft` entries don't count as explicit
  (installed conform source, `lua/conform/init.lua:460-465`:
  `warn = not opts.quiet and has_explicit_formatters`);
- `format_on_save` returns `lsp_format = "fallback"` for PHP
  (conform.lua:28-33), so saves quietly fall through to phpactor's LSP
  formatting or no-op.

The `timeout_override = { php = 5000 }` (conform.lua:24) is dead weight
while the formatter is unavailable.

## Evidence / basis

- Config read: `conform.lua:17-73`.
- `ls /Users/jakob/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh`
  → missing (run during review, 2026-06-11).
- Installed conform source: `init.lua:460-465` (warning condition).

## Fix

Two independent improvements; pick per preference:

1. **Make the absence loud.** Add a `condition` plus a one-time notice:

```lua
["scf-docker"] = {
  command = "/Users/jakob/Development/gitlab/ekkogmbh/scf/scripts/docker-wrapper.sh",
  args = { "format", "--filepath-for-matcher", "$FILENAME" },
  stdin = true,
  condition = function(self, ctx)
    if vim.fn.executable(self.command) == 1 then return true end
    vim.notify_once("scf-docker formatter missing: " .. self.command, vim.log.levels.WARN)
    return false
  end,
},
```

(Check conform's `condition` callback signature against the installed
version when implementing; conform also supports `command` as a
function.)

2. **Stop hardcoding one checkout path.** Resolve the wrapper relative
   to the project the PHP file lives in, e.g.:

```lua
command = function(self, ctx)
  local root = vim.fs.root(ctx.filename, ".git")
  return root and (root .. "/scripts/docker-wrapper.sh") or "docker-wrapper-missing"
end,
```

This makes the formatter work in any checkout of the scf project and
naturally unavailable elsewhere. Decide whether the formatter should
apply to *all* PHP files (current state) or only files inside that
project; the `condition` callback can enforce the latter.
