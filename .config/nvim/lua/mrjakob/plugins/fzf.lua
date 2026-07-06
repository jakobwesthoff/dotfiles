return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({
      -- Register fzf-lua as the vim.ui.select provider
      ui_select = {},
      -- Uncomment to display paths filename-first across all file pickers,
      -- e.g. `init.lua  lua/mrjakob/` instead of the default `lua/mrjakob/init.lua`.
      -- This belongs at the top level; fzf-lua does not read it from `winopts`.
      -- formatter = "path.filename_first",
      fzf_opts = { ["--wrap"] = true },
      fzf_colors = {
        ["pointer"] = { "fg", { "Red" } },
        ["hl"] = { "fg", { "Red" } },
        ["hl+"] = { "fg", { "Red" } },
        ["fg+"] = { "fg", { "White" } },
        ["prompt"] = { "fg", { "Blue" } },
        ["query"] = { "fg", { "Yellow" } },
      },
      winopts = {
        preview = {
          wrap = "wrap",
        },
      },
    })

    local function fzf_directories(opts)
      local fzf_lua = require("fzf-lua")
      local fzf_path = require("fzf-lua.path")
      opts = opts or {}

      local cwd = vim.fn.getcwd()
      opts.prompt = fzf_path.shorten(cwd) .. "> "
      opts.cwd = cwd

      -- opts.fn_transform = function(x)
      --   return fzf_lua.utils.ansi_codes.magenta(x)
      -- end
      --
      opts.actions = {
        ["default"] = function(selected)
          vim.cmd("Oil --float " .. cwd .. "/" .. selected[1])
        end,
      }

      -- The directory listing is built from `fd`; without it fzf_exec would
      -- open an empty picker with no indication why.
      if vim.fn.executable("fd") ~= 1 then
        vim.notify("fd is not installed; FzfDirectories unavailable", vim.log.levels.WARN)
        return
      end

      fzf_lua.fzf_exec("fd --type d", opts)
    end

    vim.api.nvim_create_user_command("FzfDirectories", function()
      fzf_directories({})
    end, {})
  end,
}
