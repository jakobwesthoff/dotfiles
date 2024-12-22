local gruvbox_material_transparent = true

return {
  "f4z3r/gruvbox-material.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local search_flip_search_opts = nil
    local search_flip_inc_search_opts = nil
    local search_flip_flipped = false

    require("gruvbox-material").setup({
      constrast = "hard",

      background = {
        transparent = gruvbox_material_transparent,
      },
      customize = function(group, opts)
        local colors = require("gruvbox-material.colors").get(vim.o.background, "hard")
        -- print(vim.inspect(colors))

        if group == "CursorLineNr" then
          opts.link = nil
          opts.fg = colors.orange
          opts.bold = true
          return opts
        end

        -- Paren Matches should be orange without background
        if group == "MatchParen" or group == "MatchParenCur" or group == "MatchWord" then
          opts.link = nil
          opts.fg = colors.orange
          opts.bg = nil
          opts.bold = true
          return opts
        end

        -- Change background for completion and hover popups
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
          -- opts.fg = colors.bg0
        end

        -- Change partial cmp matches
        if group == "CmpItemAbbrMatch" or group == "CmpItemAbbrMatchFuzzy" then
          opts.fg = colors.orange
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
    -- AUTO CHANGE MARKER: LIGHT/DARK
    vim.opt.background = "dark"
    vim.cmd.colorscheme("gruvbox-material")
  end,
}
