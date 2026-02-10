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
        path = "C:/Users/student/notes",
      },
    },
    notes_subdir = "",
    daily_notes = {
      folder = "docs/30-DailyNotes",
      date_format = "%Y/%m/%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      default_tags = { "daily-notes" },
      template = "docs/50-Templates/DailyNote Template.md",
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian.util").gf_passthrough()
        end,
        opts = { desc = "Follow link", noremap = false, expr = true, buffer = true },
      },
      -- Note: <leader>nn, <leader>nt, <leader>ny are defined globally in keys table so they can be used from dashboard
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
    -- going to try `use_alias_only and see if I can still follow` formerly `wiki_link_path_prefix`
    -- `wiki_link_path_prefix` isnt even in the docs, but seems to work funtionally like `prepend_note_path`
    wiki_link_func = "use_alias_only",
    -- wiki_link_func = function(opts)
    --   return require("obsidian.util").wiki_link_path_prefix(opts)
    -- end,
    preferred_link_style = "wiki",
    templates = {
      folder = "docs/50-Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {},
    },
    follow_url_func = function(url)
      vim.fn.jobstart({ "cmd.exe", "/c", "start", "", url })
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
    -- Disable frontmatter for files in the tasks folder or kanban files to avoid conflicts with kanban.nvim
    disable_frontmatter = function(filename)
      return filename:match("[\\/]tasks[\\/]") or filename:match("^tasks[\\/]") or filename:match("kanban%.md$")
    end,
  },
  keys = {
    { "<leader>nn", "<cmd>ObsidianNew<cr>", desc = "New note" },
    { "<leader>nt", "<cmd>ObsidianToday<cr>", desc = "Open today's daily note" },
    { "<leader>ny", "<cmd>ObsidianYesterday<cr>", desc = "Open yesterday's note" },
    { "<leader>ns", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
    { "<leader>nb", "<cmd>ObsidianBacklinks<cr>", desc = "Show backlinks" },
    { "<leader>nl", "<cmd>ObsidianLinks<cr>", desc = "Show outgoing links" },
    { "<leader>ni", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image" },
    { "<leader>nc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)
    -- Smart action on <CR> in markdown files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        vim.keymap.set("n", "<CR>", function()
          local ok, actions = pcall(require, "obsidian.actions")
          if ok then
            actions.smart_action()
          else
            -- Fallback: try manual fold toggle
            local line = vim.api.nvim_win_get_cursor(0)[1]
            local foldlevel = vim.fn.foldlevel(line)
            if foldlevel > 0 then
              vim.cmd("normal! za")
            else
              -- Normal Enter behavior
              vim.cmd("normal! j")
            end
          end
        end, {
          buffer = true,
          desc = "Obsidian smart action or toggle fold",
        })
      end,
    })
  end,
}
