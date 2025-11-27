return {
  "folke/tokyonight.nvim",
  -- Load this first, before anything else, so the colors are set immediately.
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme tokyonight]])
  end,
}
