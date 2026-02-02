-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("i", "kk", "<Esc>")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("n", "gj", [[/^#\+ .*<CR>]], { desc = "Next markdown heading" })
vim.keymap.set("n", "gk", [[?^#\+ .*<CR>]], { desc = "Previous markdown heading" })
-- Pressing Esc clears search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
