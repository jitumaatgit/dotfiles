-- Fix for Git Bash on Windows - shell path escaping issue
-- Prefer $SHELL (set when launched from Git Bash); fall back to a known
-- bash.exe so `:!rm`, `:make`, etc. work even when launched from GUI.
if vim.fn.has("win32") == 1 then
  local bash = vim.env.SHELL and vim.env.SHELL:match("bash") and vim.env.SHELL
    or vim.fn.executable("C:/Users/student/scoop/apps/git/current/usr/bin/bash.exe") == 1 and "C:/Users/student/scoop/apps/git/current/usr/bin/bash.exe"
    or vim.fn.executable("C:/Program Files/Git/bin/bash.exe") == 1 and "C:/Program Files/Git/bin/bash.exe"
    or nil
  if bash then
    vim.opt.shell = bash
    vim.opt.shellcmdflag = "-c"
    vim.opt.shellquote = '"'
    vim.opt.shellxquote = '"'
  end
end

-- Configure SQLite library path for sqlite.lua
vim.g.sqlite_clib_path = vim.fn.expand("$HOME/.local/bin/sqlite3.dll")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.markdown-folding")
require("snippets")

-- Auto-move completed tasks to Completed section
require("custom.task-auto-complete").setup()

-- Filter tasks by file-level tags (requires obsidian.nvim)
require("custom.obsidian-task-filter").setup({
  picker = "telescope", -- Uses telescope for better UI
  show_completed = false,
  preview_context = 3,
})

-- Patch trouble.nvim's section.refresh so the throttle uv_check handler
-- never gets pinned at ~78% CPU via a stuck `section.fetching = true`.
-- See notes/docs/20-resources/neovim/trouble-nvim-fetch-leak-2026-07-04.md
-- (notes repo) for the full root-cause writeup.
require("custom.trouble-fetch-fix").setup()
