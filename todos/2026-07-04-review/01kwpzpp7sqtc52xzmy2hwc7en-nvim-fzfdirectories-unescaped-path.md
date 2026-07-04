# nvim: FzfDirectories default action breaks on directory names with spaces

**Area**: nvim
**File**: /Users/jakob/dotfiles/.config/nvim/lua/mrjakob/plugins/fzf.lua:41-45

## Current state

The `FzfDirectories` picker (bound to `<leader>fp`, keymaps.lua:103) feeds
`fd --type d` output into fzf and opens the selection in Oil:

```lua
opts.actions = {
  ["default"] = function(selected)
    vim.cmd("Oil --float " .. cwd .. "/" .. selected[1])
  end,
}
```

## Problem

The path is concatenated into the Ex command unescaped. `:Oil` is defined
with `nargs = "*"` and takes `args.fargs[1]` as the path (installed
oil.nvim, `lua/oil/init.lua:1185` and `:1170`), and `fargs` splits on
unescaped whitespace. Any directory whose relative path contains a space
(e.g. anything under a macOS `Application Support`-style name, or project
dirs like `My Project/assets`) therefore arrives as multiple arguments:
after `--float` is stripped, Oil opens only the first whitespace-delimited
fragment — a wrong or nonexistent path. `fd` emits such paths verbatim, so
the picker happily lists entries its own action cannot open. Other special
characters that `:command` argument parsing interprets (`%`, `#`, `|`)
misbehave the same way.

## Grounding

- fzf.lua:43 (unescaped concatenation), :54 (`fzf_exec("fd --type d", ...)`).
- Installed oil.nvim `lua/oil/init.lua:1182-1186`: `nvim_create_user_command`
  with `nargs = "*"`; `:1170`: `local path = args.fargs[1]`.
- `:h fnameescape()`: "Escape {string} for use as file name command
  argument. All characters that have a special meaning, such as `'%'` and
  `'|'` are escaped with a backslash."

## Proposed change

Escape the argument:

```lua
vim.cmd("Oil --float " .. vim.fn.fnameescape(cwd .. "/" .. selected[1]))
```

(or equivalently `require("oil").open_float(cwd .. "/" .. selected[1])`,
which bypasses Ex argument parsing entirely).
