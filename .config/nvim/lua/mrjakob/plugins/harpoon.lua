return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    -- We may want to change the "harpoon" leader to something different than
    -- the leader key
    local our_leader = "<leader>"
    local function keymap_set(mode, key, fn, desc)
      vim.keymap.set(mode, our_leader .. key, fn, { desc = desc })
    end

    keymap_set("n", "a", function()
      harpoon:list():add()
    end, "[A]dd Harpoon")

    keymap_set("n", "l", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, "[L]ist Harpoons")

    -- Harpoon to targets
    keymap_set("n", "q", function()
      harpoon:list():select(1)
    end, "[q] Harpoon to 1")
    keymap_set("n", "w", function()
      harpoon:list():select(2)
    end, "[q] Harpoon to 2")
    keymap_set("n", "e", function()
      harpoon:list():select(3)
    end, "[q] Harpoon to 3")
    keymap_set("n", "r", function()
      harpoon:list():select(4)
    end, "[e] Harpoon to 4")
    keymap_set("n", "t", function()
      harpoon:list():select(5)
    end, "[q] Harpoon to 5")

    -- Toggle previous & next buffers stored within Harpoon list
    -- We map the ü instead of the [ as the langmap does not work here. No idea why.
    keymap_set("n", "ü", function()
      harpoon:list():prev()
    end, "[[] Hardpoon to Previous")
    keymap_set("n", "]", function()
      harpoon:list():next()
    end, "[]] Harpoon to Next")
  end,
}
