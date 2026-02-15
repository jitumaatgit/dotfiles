-- Force fold highlights (loaded in init.lua after config.lazy)
-- Must be loaded after colorscheme to prevent overrides

-- Treesitter markdown heading highlights (preserved when folding with foldtext="")
-- These override the default treesitter groups to add backgrounds
-- H1: Blue
vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { bg = "#313244", fg = "#89b4fa", bold = true })
-- H2: Green
vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { bg = "#313244", fg = "#a6e3a1", bold = true })
-- H3: Yellow
vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { bg = "#313244", fg = "#f9e2af", bold = true })
-- H4: Peach
vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { bg = "#313244", fg = "#fab387", bold = true })
-- H5: Pink
vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { bg = "#313244", fg = "#f38ba8", bold = true })
-- H6: Mauve
vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { bg = "#313244", fg = "#cba6f7", bold = true })

-- Fold highlights for non-heading content
vim.api.nvim_set_hl(0, "Folded", { bg = "#313244", fg = "#313244" })
vim.api.nvim_set_hl(0, "FoldColumn", { bg = "#313244", fg = "#313244" })

-- Re-apply after colorscheme changes to prevent overrides
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { bg = "#313244", fg = "#89b4fa", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { bg = "#313244", fg = "#a6e3a1", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { bg = "#313244", fg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { bg = "#313244", fg = "#fab387", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { bg = "#313244", fg = "#f38ba8", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { bg = "#313244", fg = "#cba6f7", bold = true })
    vim.api.nvim_set_hl(0, "Folded", { bg = "#313244", fg = "#313244" })
    vim.api.nvim_set_hl(0, "FoldColumn", { bg = "#313244", fg = "#313244" })
  end,
})
