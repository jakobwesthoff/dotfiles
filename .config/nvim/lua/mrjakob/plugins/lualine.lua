-- At which column count start to make the elements smaller or hide certain
-- elements?
local lualine_trunc_margin = 80

local function truncateCondition()
  return vim.o.columns >= lualine_trunc_margin
end

-- Used for shortening Mode in smaller terminals
local mode_map = {
  ["NORMAL"] = "N",
  ["INSERT"] = "I",
  ["VISUAL"] = "V",
  ["V-LINE"] = "VL",
  ["V-BLOCK"] = "VB",
  ["COMMAND"] = "C",
  ["TERMINAL"] = "T",
  ["REPLACE"] = "R",
}

local function formatMode(str)
  if vim.o.columns < lualine_trunc_margin then
    return mode_map[str] or str
  end
  return str
end

local function getColumnPosition()
  local col = "%v"
  local max_col = "%{virtcol('$')-1}"
  if not truncateCondition() then
    return string.format("%s", col)
  else
    return string.format("%s\u{23ae}%s", col, max_col)
  end
end

local function getRowPosition()
  local row = "%l"
  local max_row = "%L"
  if not truncateCondition() then
    return string.format("%s", row)
  else
    return string.format("%s\u{23ae}%s", row, max_row)
  end
end

local function getWindowNumber()
  return vim.api.nvim_win_get_number(0)
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Needs to be done within the setup function, as this depends on the theme
    -- "Primary" accent color to be used for inactive statusline cells
    local inactive_primary_color = {
      fg = require("mrjakob.util").getColor("Normal", "bg"),
      bg = require("mrjakob.util").getColor("Grey", "fg"),
    }

    require("lualine").setup({
      options = {
        theme = function()
          -- Replace the default mapping of "Mode" colors with something I like
          -- better ;)
          local colors = {
            normal = require("mrjakob.util").getColor("Yellow", "fg"),
            insert = require("mrjakob.util").getColor("Green", "fg"),
            visual = require("mrjakob.util").getColor("Purple", "fg"),
            replace = require("mrjakob.util").getColor("Red", "fg"),
            command = require("mrjakob.util").getColor("Orange", "fg"),
            bg = require("mrjakob.util").getColor("Normal", "bg"),
          }

          local base = require("lualine.themes.auto")
          base.normal.a = { fg = colors.bg, bg = colors.normal, gui = "bold" }
          base.insert.a = { fg = colors.bg, bg = colors.insert, gui = "bold" }
          base.visual.a = { fg = colors.bg, bg = colors.visual, gui = "bold" }
          base.replace.a = { fg = colors.bg, bg = colors.replace, gui = "bold" }
          base.command.a = { fg = colors.bg, bg = colors.command, gui = "bold" }
          return base
        end,
        section_separators = {
          -- Full diagonal dividers bottom left to top right
          left = "\u{e0bc}",
          right = "\u{e0ba}",
        },
        component_separators = {
          -- Hairline diagonal dividers bottom left to top right
          left = "\u{e0bd}",
          right = "\u{e0bb}",
        },
        globalstatus = false,
        icons_enabled = true,
      },
      sections = {
        lualine_a = {
          {
            "mode",
            fmt = formatMode,
          },
        },
        lualine_b = {},
        lualine_c = {
          {
            "diagnostics",
            -- Override with "fat" symbols
            -- symbols = {
            -- error = " ",
            -- hint = " ",
            -- info = " ",
            -- warn = " ",
            -- },
            -- cond = truncateCondition,
            separator = "",
          },
          {
            -- Center filename section
            function()
              return "%="
            end,
            separator = "",
          },
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = {
              left = 1,
              right = 0,
            },
          },
          {
            "filename",
            file_status = true,
            path = 1,
            shorting_target = 40,
            symbols = {
              modified = "󰐖 ", -- Show when file is modified
              readonly = " ", -- Show when file is readonly
              unnamed = "[No Name]", -- Show when Buffer has no name
              newfile = "[New]", -- Show when file hasn't been saved yet
            },
          },
        },
        lualine_x = {},
        lualine_y = {
          {
            "branch",
            cond = truncateCondition,
          },
        },
        lualine_z = {
          getColumnPosition,
          getRowPosition,
        },
      },
      inactive_sections = {
        lualine_a = {
          {
            getWindowNumber,
            color = inactive_primary_color,
            separator = {
              -- The base configuration is ignored here for some reason I don't
              -- know. However this fixes the right diagonal separator
              right = "\u{e0bc}",
            },
          },
        },
        lualine_b = {},
        lualine_c = {
          {
            -- Center filename section
            function()
              return "%="
            end,
            separator = "",
          },
          {
            "filename",
            file_status = true,
            path = 1,
            shorting_target = 40,
            symbols = {
              modified = "󰐖 ", -- Show when file is modified
              readonly = " ", -- Show when file is readonly
              unnamed = "[No Name]", -- Show when Buffer has no name
              newfile = "[New]", -- Show when file hasn't been saved yet
            },
            color = { fg = require("mrjakob.util").getColor("Grey", "fg") },
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            getColumnPosition,
            color = inactive_primary_color,
          },
          {
            getRowPosition,
            color = inactive_primary_color,
          },
        },
      },
      extensions = {
        "oil",
      },
    })
  end,
}
