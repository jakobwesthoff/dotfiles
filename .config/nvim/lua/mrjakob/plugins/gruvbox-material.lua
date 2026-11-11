local gruvbox_material_transparent = true

return {
  "f4z3r/gruvbox-material.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("gruvbox-material").setup({
      contrast = "hard",

      background = {
        transparent = gruvbox_material_transparent,
      },
      customize = function(group, opts)
        local colors = require("gruvbox-material.colors").get(vim.o.background, "hard")

        if group == "CursorLineNr" then
          opts.link = nil
          opts.fg = colors.orange
          opts.bold = true
          return opts
        end

        -- Paren Matches should be orange without background
        if group == "MatchParen" then
          opts.link = nil
          opts.fg = colors.orange
          opts.bg = nil
          opts.bold = true
          return opts
        end

        -- Change background for completion and hover popups. The transparent
        -- background mode clears these, so they are set back to bg3 here.
        if
          group == "Pmenu"
          or group == "PmenuExtra"
          or group == "PmenuThumb"
          or group == "PmenuSbar"
          or group == "PmenuKind"
          or group == "NormalFloat"
        then
          opts.bg = colors.bg3
        end

        -- Change completion selection line
        if group == "PmenuSel" then
          opts.bg = colors.yellow
        end

        -- Set search and incsearch to more appropriate colors
        if group == "Search" then
          opts.bg = colors.aqua
        end
        if group == "IncSearch" then
          opts.bg = colors.orange
        end

        return opts
      end,
    })
    -- TODO: The light theme needs work
    vim.opt.background = "dark"
    vim.cmd.colorscheme("gruvbox-material")
  end,
}
