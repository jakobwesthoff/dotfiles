-- At which column count start to make the elements smaller or hide certain
-- elements?
local lualine_trunc_margin = 80

-- Measure the window the statusline is drawn for, not the whole terminal:
-- with per-window statuslines (globalstatus = false) a vertical split makes
-- each statusline far narrower than vim.o.columns.
local function truncateCondition()
  return vim.api.nvim_win_get_width(0) >= lualine_trunc_margin
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
  if vim.api.nvim_win_get_width(0) < lualine_trunc_margin then
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

-- Macro recording indicator. reg_recording() returns the active register name
-- ("q", "a", ...) while a macro is being recorded and "" otherwise, so the
-- component renders only mid-recording.
local function macroRecording()
  return "@" .. vim.fn.reg_recording()
end

local function isRecording()
  return vim.fn.reg_recording() ~= ""
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- The accent cells use the editor background as their text color so it
    -- reads against the bright mode color. With a transparent background
    -- Normal has no bg attribute, so fall back to black (a usable contrast
    -- against the accent) instead of leaving the text at the default light fg.
    local function normalBg()
      return require("mrjakob.util").getColor("Normal", "bg") or "#000000"
    end

    -- "Primary" accent color for inactive statusline cells. Defined as a
    -- function so lualine re-evaluates it on every draw: lualine re-runs its
    -- highlight resolution on ColorScheme/background changes, keeping the
    -- color in sync with the active palette instead of freezing the value
    -- captured at setup time.
    local function inactive_primary_color()
      return {
        fg = normalBg(),
        bg = require("mrjakob.util").getColor("Grey", "fg"),
      }
    end

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
            bg = normalBg(),
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
        lualine_b = {
          {
            -- Lives in its own section so lualine wraps it in the same
            -- diagonal section separators as the mode cell. The red accent
            -- with the editor background as text color mirrors the mode cells.
            macroRecording,
            cond = isRecording,
            color = function()
              return {
                fg = normalBg(),
                bg = require("mrjakob.util").getColor("Red", "fg"),
                gui = "bold",
              }
            end,
            -- A custom-colored component does not pick up the section
            -- separator automatically (same quirk worked around for the
            -- window number in the inactive section), so set the diagonal
            -- explicitly to match the mode cell.
            separator = {
              right = "\u{e0bc}",
            },
          },
        },
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
            color = function()
              return { fg = require("mrjakob.util").getColor("Grey", "fg") }
            end,
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

    -- lualine's refresh timer is too coarse to toggle the recording cell
    -- promptly, and on RecordingLeave the register is still set when the event
    -- fires. Schedule the refresh so it runs after Neovim has cleared the
    -- state, otherwise the indicator lingers for one frame after recording
    -- stops.
    vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
      callback = function()
        vim.schedule(function()
          require("lualine").refresh()
        end)
      end,
    })
  end,
}
