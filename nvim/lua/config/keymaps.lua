-- ========================================================================== --
--  KEYBINDINGS (Examples)
-- ========================================================================== --
vim.keymap.set('i', 'jj', '<Esc>')
-- Find files using Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope Find Files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope Live Grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope Buffers' })

-- Quick Save
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save File' })
