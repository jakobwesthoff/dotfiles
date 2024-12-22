return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({
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
        formatter = "path.filename_first",
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

      fzf_lua.fzf_exec("fd --type d", opts)
    end

    vim.api.nvim_create_user_command("FzfDirectories", function()
      fzf_directories({})
    end, {})
  end,
}
