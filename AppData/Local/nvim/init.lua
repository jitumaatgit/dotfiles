-- Fix for Git Bash on Windows - shell path escaping issue
if vim.fn.has('win32') == 1 and vim.env.SHELL and vim.env.SHELL:match('bash') then
  vim.opt.shell = vim.env.SHELL
  vim.opt.shellcmdflag = '-c'
  vim.opt.shellquote = '"'
  vim.opt.shellxquote = '"'
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
