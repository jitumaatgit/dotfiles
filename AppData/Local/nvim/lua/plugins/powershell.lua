vim.api.nvim_create_autocmd("FileType", {
  pattern = "ps1",
  callback = function()
    require("lspconfig").powershell_es.setup({
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
      shell = "powershell.exe",
    })
  end,
})
