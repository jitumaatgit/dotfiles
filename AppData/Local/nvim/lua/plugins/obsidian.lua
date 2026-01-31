return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "notes",
        path = "~/notes",
      },
    },
    notes_subdir = "",
    daily_notes = {
      folder = "daily/",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      default_tags = { "daily-notes" },
      template = nil,
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ["<leader>nn"] = {
        action = function()
          return require("obsidian").commands.new_note()
        end,
        opts = { buffer = true },
      },
      ["<leader>nt"] = {
        action = function()
          return require("obsidian").commands.today()
        end,
        opts = { buffer = true },
      },
      ["<leader>ny"] = {
        action = function()
          return require("obsidian").commands.yesterday()
        end,
        opts = { buffer = true },
      },
    },
    new_notes_location = "current_dir",
    note_id_func = function(title)
      if title ~= nil then
        return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        local suffix = ""
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
        return suffix
      end
    end,
    wiki_link_func = function(opts)
      return require("obsidian.util").wiki_link_path_prefix(opts)
    end,
    preferred_link_style = "wiki",
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {},
    },
    follow_url_func = function(url)
      vim.fn.jobstart({ "cmd", "/c", "start", url })
    end,
    picker = {
      name = "snacks.nvim",
      note_mappings = {
        new = "<C-x>",
        insert_link = "<C-l>",
      },
      tag_mappings = {
        tag_note = "<C-x>",
        insert_tag = "<C-l>",
      },
    },
    sort_by = "modified",
    sort_reversed = true,
    open_notes_in = "current",
    attachments = {
      img_folder = "assets/imgs",
      img_name_func = function()
        return string.format("%s-", os.time())
      end,
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format("![%s](%s)", path.name, path)
      end,
    },
    -- Disable obsidian UI (using render-markdown.nvim instead)
    ui = { enable = false },
  },
  keys = {
    { "<leader>ns", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
    { "<leader>nb", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
    { "<leader>nl", "<cmd>ObsidianLinks<cr>", desc = "Show outgoing links" },
    { "<leader>ni", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image" },
    { "<leader>nc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
  },
}
