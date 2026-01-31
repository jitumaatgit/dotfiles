return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      list = {
        selection = {
          -- Don't auto-insert when navigating completion items
          auto_insert = false,
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "obsidian" },
      providers = {
        obsidian = {
          name = "obsidian",
          module = "blink.compat.source",
        },
      },
    },
  },
}
