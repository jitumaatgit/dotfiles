return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  cond = vim.g.neovide == nil,
  opts = {
    legacy_computing_symbols_support = true,

    -- Disable trail in some cases:
    -- .. for tiny horizontal/vertical movements
    min_horizontal_distance_smear = 4,
    -- min_vertical_distance_smear = 3,
    -- .. in insert mode, it looks pretty bad :/
    smear_insert_mode = false,
    -- .. in cmdline, as it prevents builtin behavior where I can write 2
    -- commands and still see the result of the first command.
    -- (which is very useful when editing hl or exploring options)
    smear_to_cmd = true,
    hide_target_hack = false,
    never_draw_over_target = false, -- for no termguicolors set true
    cursor_color = "none",
    time_interval = 11,
    stiffness = 0.6,
    trailing_stiffness = 0.3,
    damping = 0.9,
    distance_stop_animating = 0.3,
  },
  specs = {
    -- disable mini.animate cursor
    {
      "nvim-mini/mini.animate",
      optional = true,
      opts = {
        cursor = { enable = false },
      },
    },
  },
}
