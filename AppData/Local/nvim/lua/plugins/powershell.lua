local navic = require("nvim-navic")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "ps1",
  callback = function()
    require("lspconfig").powershell_es.setup({
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
      shell = "powershell.exe",
      on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end,
    })
  end,
})

return {}
