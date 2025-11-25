-- ========================================================================== --
--  BOOTSTRAP: AUTO-INSTALL LAZY.NVIM
--  This block runs every time you reboot/reset the laptop.
--  It checks if lazy.nvim exists; if not, it clones it.
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.api.nvim_echo({ { "⬇️  Bootstrapping Lazy.nvim & Plugins...", "MoreMsg" } }, true, {})
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
--  PLUGIN SETUP
-- ========================================================================== --
require("lazy").setup({
  -- 1. THEME (So you know it worked immediately)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- 2. TREESITTER (Better Syntax Highlighting)
  -- Note: Requires 'gcc' which we installed via Scoop in your setup.ps1
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function() 
      require("nvim-treesitter.configs").setup({
        -- Add languages you use here
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
        auto_install = true,
        highlight = { enable = true },
      })
    end
  },

  -- 3. TELESCOPE (Fuzzy Finder)
  {
    "nvim-telescope/telescope.nvim", 
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- 4. WHICH-KEY (Helps you learn keybindings)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  }
})

-- ========================================================================== --
--  BASIC SETTINGS (Sane Defaults)
-- ========================================================================== --
vim.g.mapleader = " "              -- Set Space as Leader Key
vim.g.maplocalleader = "\\"

vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.clipboard = "unnamedplus"  -- Sync with Windows System Clipboard
vim.opt.tabstop = 4                -- 4 spaces for tabs
vim.opt.shiftwidth = 4
vim.opt.expandtab = true           -- Convert tabs to spaces
vim.opt.ignorecase = true          -- Ignore case when searching...
vim.opt.smartcase = true           -- ...unless you type a capital
vim.opt.termguicolors = true       -- True color support

-- ========================================================================== --
--  KEYBINDINGS (Examples)
-- ========================================================================== --
-- Find files using Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope Find Files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope Live Grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope Buffers' })

-- Quick Save
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save File' })