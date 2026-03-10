return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.install").compilers = { "zig" }
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })
    require("nvim-treesitter").install({
      "lua",
      "regex",
      "sql",
      "json",
      "csv",
      "javascript",
      "html",
      "markdown",
      "markdown_inline",
      "elixir",
      "powershell",
      "python",
      "yaml",
      "bash",
    })
  end,
}
