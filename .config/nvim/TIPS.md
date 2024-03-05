# Tips of the Day

## Scope

Things I should use more often within my NeoVim setup or things I use seldomly
and therefore need to write them down somewhere.

Most likely this document will contain information I collect, while switching
from my old setup to the new neovim one.

## Inline LSP diagnostic messages

To toggle the inline diagnostic messages `<leader>ud` can be used within *lazyVim*.

### Alternative functions for toggling

**Taken from:** [https://github.com/neovim/nvim-lspconfig/issues/662]

```lua
-- Command to toggle inline diagnostics
vim.api.nvim_create_user_command(
  'DiagnosticsToggleVirtualText',
  function()
    local current_value = vim.diagnostic.config().virtual_text
    if current_value then
      vim.diagnostic.config({virtual_text = false})
    else
      vim.diagnostic.config({virtual_text = true})
    end
  end,
  {}
)

-- Command to toggle diagnostics
vim.api.nvim_create_user_command(
  'DiagnosticsToggle',
  function()
    local current_value = vim.diagnostic.is_disabled()
    if current_value then
      vim.diagnostic.enable()
    else
      vim.diagnostic.disable()
    end
  end,
  {}
)
```

## Wrapping to textwidth

**Taken from:** [https://vi.stackexchange.com/a/39800]
It seems the usual `gq` in VisualMode doesn't work anymore in NeoVim. There are
however two different ways of fixing that:

1. Use `gw` instead
2. Use the following autocmd (no idea if that has other implications)

```lua
-- Use internal formatting for bindings like gq. 
 vim.api.nvim_create_autocmd('LspAttach', { 
   callback = function(args) 
     vim.bo[args.buf].formatexpr = nil 
   end, 
 })
```

## Wrong treesitter highlighting

If it seems the treesitter highlighting is kind of *off*, or even less good,
then the original highlighting, then you are most likely using the 0.9.x
version of neovim instead of the Nightly.

**Solution:** Use nightly version.

macOS:

```sh
  brew install neovim --HEAD
```
