-- ========================================================================== --
--  BOOTSTRAP: AUTO-INSTALL LAZY.NVIM
--  This block runs every time you reboot/reset the laptop.
--  It checks if lazy.nvim exists; if not, it clones it.
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
--  LAZY.NVIM SETUP
--  Tells lazy.nvim to load all configuration files from the 'lua/plugins' folder.
-- ========================================================================== --
require("lazy").setup({
    -- The key 'spec' tells lazy to look inside this directory for plugin files.
    { import = "plugins" }, 
}, {
    -- Configuration options for lazy.nvim
    install = { colorscheme = { "tokyonight", "default" } },
    change_detection = {
        enabled = true,
        notify = false,
    },
})
-- ========================================================================== --
--  LOAD CONFIGURATIONS
--  Require all files in lua/config.
-- ========================================================================== --
require("config.keymaps")
