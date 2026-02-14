-- Telescope is installed but has no keybindings
-- It's only used by obsidian.nvim and obsidian-task-filter for their pickers
-- Your default picker (snacks) handles <leader>ff, <leader>fg, etc.
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- No keys defined - telescope is only loaded when obsidian/my module calls it
  opts = {
    defaults = {
      layout_strategy = "ivy",
      layout_config = {
        height = 0.30,
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  },
}
