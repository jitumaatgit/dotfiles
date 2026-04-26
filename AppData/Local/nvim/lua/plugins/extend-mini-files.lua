return {
  "nvim-mini/mini.files",
  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (directory of current file)",
    },
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
    {
      "<leader>fm",
      function()
        require("mini.files").open(LazyVim.root(), true)
      end,
      desc = "Open mini.files (root)",
    },
  },
  opts = {
    windows = {
      width_focus = 40,
      width_nofocus = 20,
      width_preview = 70,
      preview = true,
    },
  },
  config = function(_, opts)
    require("mini.files").setup(opts)

    local git_ns = vim.api.nvim_create_namespace("minifiles_git")

    local show_dotfiles = true
    local filter_show = function()
      return true
    end
    local filter_hide = function(fs_entry)
      return not vim.startswith(fs_entry.name, ".")
    end

    local toggle_dotfiles = function()
      show_dotfiles = not show_dotfiles
      MiniFiles.refresh({ content = { filter = show_dotfiles and filter_show or filter_hide } })
    end

    local yank_path = function()
      local path = (MiniFiles.get_fs_entry() or {}).path
      if path == nil then
        return vim.notify("Cursor is not on valid entry")
      end
      vim.fn.setreg(vim.v.register, path)
    end

    local ui_open = function()
      local entry = MiniFiles.get_fs_entry()
      if entry then
        vim.ui.open(entry.path)
      end
    end

    local set_cwd = function()
      local path = (MiniFiles.get_fs_entry() or {}).path
      if path == nil then
        return vim.notify("Cursor is not on valid entry")
      end
      vim.fn.chdir(vim.fs.dirname(path))
    end

    local map_split = function(buf_id, lhs, direction)
      local rhs = function()
        local cur_target = MiniFiles.get_explorer_state().target_window
        local new_target = vim.api.nvim_win_call(cur_target, function()
          vim.cmd(direction .. " split")
          return vim.api.nvim_get_current_win()
        end)
        MiniFiles.set_target_window(new_target)
      end
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "Split " .. direction })
    end

    local git_sign_map = {
      ["A "] = { text = "++", hl = "MiniFilesGitAdded" },
      ["M "] = { text = "✓", hl = "MiniFilesGitStaged" },
      [" M"] = { text = "✗", hl = "MiniFilesGitModified" },
      ["AM"] = { text = "✗", hl = "MiniFilesGitModified" },
      ["??"] = { text = "?", hl = "MiniFilesGitUntracked" },
      ["R "] = { text = "↕", hl = "MiniFilesGitRenamed" },
      [" D"] = { text = "▼", hl = "MiniFilesGitDeleted" },
      ["D "] = { text = "▼", hl = "MiniFilesGitDeleted" },
      ["MM"] = { text = "✗", hl = "MiniFilesGitModified" },
      ["AD"] = { text = "▼", hl = "MiniFilesGitDeleted" },
      ["RM"] = { text = "↕", hl = "MiniFilesGitRenamed" },
    }

    local git_status = function(dir)
      local repo = vim.fs.find(".git", { path = dir, upward = true, type = "directory" })[1]
      if repo == nil then
        return {}
      end
      local root = vim.fs.dirname(repo)
      local ok, out = pcall(vim.fn.systemlist, {
        "git",
        "-C",
        root,
        "status",
        "--porcelain=v1",
        "--",
        ".",
      })
      if not ok or vim.v.shell_error ~= 0 then
        return {}
      end
      local result = {}
      for _, line in ipairs(out) do
        if line ~= "" then
          local code = line:sub(1, 2)
          local name = line:sub(4)
          if code:sub(2, 2) == "R" then
            name = name:match("-> (.+)$") or name
          end
          result[name] = git_sign_map[code] or { text = "·", hl = "MiniFilesGitOther" }
        end
      end
      return result, root
    end

    local set_git_extmarks = function(buf_id)
      vim.api.nvim_buf_clear_namespace(buf_id, git_ns, 0, -1)
      local dir = vim.fs.dirname(tostring(vim.api.nvim_buf_get_name(buf_id):gsub("minifiles://", "")))
      local status, root = git_status(dir)
      if root == nil then
        return
      end
      for i = 1, vim.api.nvim_buf_line_count(buf_id) do
        local entry = MiniFiles.get_fs_entry(buf_id, i)
        if entry then
          local rel = vim.fs.dirname(entry.path:sub(#root + 2))
          if rel == "" then
            rel = "."
          end
          local key = rel == "." and entry.name or (rel .. "/" .. entry.name)
          local s = status[key] or status[entry.name]
          if s then
            vim.api.nvim_buf_set_extmark(buf_id, git_ns, i - 1, 0, {
              virt_text = { { " " .. s.text, s.hl } },
              virt_text_pos = "eol_right",
              hl_mode = "combine",
            })
          end
        end
      end
    end

    local define_git_highlights = function()
      local hi = vim.api.nvim_set_hl
      hi(0, "MiniFilesGitAdded", { link = "GitSignsAdd" })
      hi(0, "MiniFilesGitStaged", { link = "GitSignsStaged" })
      hi(0, "MiniFilesGitModified", { link = "GitSignsChange" })
      hi(0, "MiniFilesGitUntracked", { link = "GitSignsUntracked" })
      hi(0, "MiniFilesGitRenamed", { link = "GitSignsRename" })
      hi(0, "MiniFilesGitDeleted", { link = "GitSignsDelete" })
      hi(0, "MiniFilesGitOther", { link = "DiagnosticWarn" })
    end
    define_git_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = define_git_highlights })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id
        vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle dotfiles" })
        vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })
        vim.keymap.set("n", "gX", ui_open, { buffer = buf_id, desc = "OS open" })
        vim.keymap.set("n", "g~", set_cwd, { buffer = buf_id, desc = "Set cwd" })
        map_split(buf_id, "<C-s>", "belowright horizontal")
        map_split(buf_id, "<C-v>", "belowright vertical")
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesExplorerOpen",
      callback = function()
        local set_mark = function(id, path, desc)
          MiniFiles.set_bookmark(id, path, { desc = desc })
        end
        set_mark("c", vim.fn.stdpath("config"), "Config")
        set_mark("w", vim.fn.getcwd, "Working directory")
        set_mark("~", "~", "Home")
        set_mark("d", "~/notes/docs/30-DailyNotes", "Daily Notes")
        set_mark("a", "~/notes/docs/10-Areas", "Areas")
        set_mark("r", "~/notes/docs/20-Resources", "Resources")
        set_mark("p", "~/notes/docs/00-Projects", "Projects")
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferUpdate",
      callback = function(args)
        vim.schedule(function()
          set_git_extmarks(args.data.buf_id)
        end)
      end,
    })
  end,
}
