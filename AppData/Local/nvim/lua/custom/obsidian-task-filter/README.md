# Obsidian Task Filter

A Neovim plugin that extends [obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim) to filter tasks by file-level tags.

## Features

- Filter tasks by file-level tags (AND logic - all specified tags must be present)
- Support for multiple tags in a single query
- Works with inline tags (`#tag`) and YAML frontmatter tags
- Shows tasks in your preferred picker (telescope, fzf-lua, or vim.ui.select)
- Displays task context in preview
- Configurable task patterns and display formats
- Pattern caching for improved performance

## Installation

### Using lazy.nvim

```lua
{
  "yourusername/obsidian-task-filter",
  dependencies = {
    "obsidian-nvim/obsidian.nvim",
    -- Optional: telescope or fzf-lua for better picker UI
    "nvim-telescope/telescope.nvim",
    -- or
    -- "ibhagwan/fzf-lua",
  },
  config = function()
    require("obsidian-task-filter").setup({
      -- Your configuration here
    })
  end,
}
```

### Using packer.nvim

```lua
use {
  "yourusername/obsidian-task-filter",
  requires = {
    "obsidian-nvim/obsidian.nvim",
    -- Optional picker dependencies
  },
  config = function()
    require("obsidian-task-filter").setup()
  end,
}
```

### Manual Installation

Copy the `lua/obsidian-task-filter` directory to your Neovim configuration:

**Linux/macOS:**
```bash
cp -r lua/obsidian-task-filter ~/.config/nvim/lua/
```

**Windows:**
```powershell
# Copy to your Neovim lua directory
Copy-Item -Path "lua\obsidian-task-filter" -Destination "$env:LOCALAPPDATA\nvim\lua\custom" -Recurse
```

Or manually copy to: `C:\Users\student\AppData\Local\nvim\lua\custom\obsidian-task-filter`

Then add to your init.lua:

```lua
require("obsidian-task-filter").setup()
```

## Usage

### Commands

#### `:ObsidianTasksByTag [tag1] [tag2] ...`

Filter tasks by file-level tags.

Examples:
```vim
" Show tasks from files tagged with 'work'
:ObsidianTasksByTag work

" Show tasks from files tagged with both 'work' AND 'urgent'
:ObsidianTasksByTag work urgent

" Show tasks from files tagged with 'work', 'urgent', AND 'meeting'
:ObsidianTasksByTag work urgent meeting
```

If no tags are provided, you'll be prompted to enter tags interactively.

### Keybindings (in picker)

- `<CR>` (Enter): Open the file and jump to the task
- Navigation: Use your picker's normal navigation keys

## Configuration

### Default Configuration

```lua
require("obsidian-task-filter").setup({
  -- Which picker to use
  -- Options: "telescope", "fzf-lua", or nil (uses vim.ui.select)
  picker = nil,
  
  -- Task patterns for matching different task states
  task_patterns = {
    incomplete = "^%s*%- %[%s%]",      -- - [ ]
    in_progress = "^%s*%- %[/\]",      -- - [/]
    completed = "^%s*%- %[x\]",        -- - [x]
  },
  
  -- Show completed tasks?
  show_completed = false,
  
  -- Number of context lines to show in preview
  preview_context = 3,
  
  -- Display format for tasks
  -- Available placeholders:
  --   {filename} - Name of the file
  --   {line}     - Line number
  --   {tags}     - Comma-separated list of tags
  --   {task}     - Task text (without checkbox)
  format = "{filename}:{line} [{tags}] {task}",
})
```

### Example Configurations

#### Using Telescope with Snacks Picker (Recommended for LazyVim users)

If you use LazyVim or snacks.nvim as your default picker but need telescope for obsidian.nvim:

```lua
-- lua/plugins/telescope.lua
-- Install telescope but don't define keybindings (snacks handles those)
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- No keys defined - telescope loads only when obsidian needs it
  opts = {
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  },
}
```

```lua
-- lua/plugins/obsidian.lua
require("obsidian").setup({
  -- ... other config ...
  picker = {
    name = "telescope.nvim", -- obsidian uses telescope
    -- ... mappings ...
  },
})
```

```lua
-- init.lua
require("obsidian-task-filter").setup({
  picker = "telescope", -- Use telescope for task filtering
})
```

This setup allows:
- **snacks.nvim** to handle your daily picker needs (`<leader>ff`, `<leader>fg`, etc.)
- **telescope.nvim** to handle obsidian.nvim and task-filter operations
- Both coexist without conflicts

#### With Telescope (Standalone)

```lua
require("obsidian-task-filter").setup({
  picker = "telescope",
  show_completed = false,
  preview_context = 5,
  format = "{filename}:{line} {task}",
})
```

#### With fzf-lua

```lua
require("obsidian-task-filter").setup({
  picker = "fzf-lua",
  show_completed = true, -- Include completed tasks
  format = "[{tags}] {task}",
})
```

#### Minimal (vim.ui.select)

```lua
require("obsidian-task-filter").setup({
  -- Uses vim.ui.select, no additional dependencies needed
})
```

### Advanced: Custom Keybinding

Add a keybinding to quickly filter by your most common tag:

```lua
vim.keymap.set("n", "<leader>tw", function()
  vim.cmd("ObsidianTasksByTag work")
end, { desc = "Show work tasks" })

vim.keymap.set("n", "<leader>tp", function()
  vim.cmd("ObsidianTasksByTag personal")
end, { desc = "Show personal tasks" })
```

### Advanced: Interactive Tag Selection with Telescope

If you want a more interactive tag selection experience, you can use this function:

```lua
local function select_tags_and_show_tasks()
  local ok, obsidian = pcall(require, "obsidian")
  if not ok then
    return
  end
  
  local client = obsidian.get_client()
  client:list_tags_async(nil, function(tags)
    require("telescope.pickers").new({}, {
      prompt_title = "Select Tags (multi-select with <Tab>)",
      finder = require("telescope.finders").new_table({
        results = tags,
      }),
      sorter = require("telescope.config").values.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        
        actions.select_default:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local selections = picker:get_multi_selection()
          
          if #selections == 0 then
            selections = { action_state.get_selected_entry() }
          end
          
          local selected_tags = {}
          for _, selection in ipairs(selections) do
            table.insert(selected_tags, selection.value)
          end
          
          actions.close(prompt_bufnr)
          require("obsidian-task-filter").filter_tasks_by_tags(selected_tags)
        end)
        
        return true
      end,
    }):find()
  end)
end

vim.keymap.set("n", "<leader>ot", select_tags_and_show_tasks, { desc = "Select tags and show tasks" })
```

## How It Works

1. **Tag Discovery**: Uses obsidian.nvim's `find_tags_async()` to locate all files containing the specified tags
2. **File Filtering**: Filters for files that contain **ALL** specified tags (AND logic)
3. **Task Extraction**: Reads each matching file and extracts task lines (matching `- [ ]`, `- [/]`, `- [x]` patterns)
4. **Pattern Caching**: Task patterns are compiled once and cached for faster matching
5. **Display**: Shows tasks in your configured picker with file context

## Requirements

- Neovim >= 0.8.0
- [obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim) (required)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (optional, for better UI)
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) (optional, alternative picker)

## Tag Format Support

This plugin supports all tag formats that obsidian.nvim supports:

**Inline tags:**
```markdown
This is a note with #work and #urgent tags.
```

**YAML frontmatter (list):**
```yaml
---
tags:
  - work
  - urgent
---
```

**YAML frontmatter (inline):**
```yaml
---
tags: work urgent
---
```

## Task Format Support

The following task formats are recognized:

```markdown
- [ ] Incomplete task
- [/] In progress task (if enabled)
- [x] Completed task (if show_completed is true)
- [X] Completed task (alternative checkbox)
```

## Limitations

- Currently uses AND logic for multiple tags (all must be present)
- Searches entire vault each time (may be slow on very large vaults)
- No persistent saved queries

## Future Enhancements

- OR logic option for tags
- Caching for better performance
- Saved queries/filters
- Exclude tags (e.g., `-archive`)
- Sort options (by date, priority, etc.)
- Due date filtering

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Built for use with [obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim)
- Inspired by the [obsidian-tasks](https://github.com/obsidian-tasks-group/obsidian-tasks) plugin for Obsidian
