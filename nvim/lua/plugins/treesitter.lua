return {
  "nvim-treesitter/nvim-treesitter",
  -- Runs the install command when the plugin is first added/updated
  build = ":TSUpdate", 
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Add languages you use here
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
      auto_install = true,
      highlight = { enable = true },
    })
  end,
}
