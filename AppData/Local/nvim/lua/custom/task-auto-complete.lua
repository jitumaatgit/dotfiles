local M = {}

-- Configuration
M.config = {
  timestamp_format = "> Completed: %Y-%m-%d %H:%M",
  completed_headings = { "completed", "done", "finished" },
  daily_notes_folder = "30%-DailyNotes",
  log_heading = "log",
}

-- Check if file is in DailyNotes folder
local function is_daily_notes_file(filepath)
  if not filepath then return false end
  return filepath:match(M.config.daily_notes_folder) ~= nil
end

-- Find completed section (case-insensitive) - works with any heading level
local function find_completed_section(lines)
  for i, line in ipairs(lines) do
    if line:match("^#+") then
      local heading_text = line:lower():gsub("^#+%s*", ""):gsub("%s*$", "")
      for _, keyword in ipairs(M.config.completed_headings) do
        if heading_text == keyword then
          return i, line
        end
      end
    end
  end
  return nil, nil
end

-- Find Log section (case-insensitive) - works with any heading level
local function find_log_section(lines)
  for i, line in ipairs(lines) do
    if line:match("^#+") then
      local heading_text = line:lower():gsub("^#+%s*", ""):gsub("%s*$", "")
      if heading_text == M.config.log_heading then
        return i
      end
    end
  end
  return nil
end

-- Find the best position for Completed section
local function find_completed_section_position(lines, filepath)
  local completed_line, _ = find_completed_section(lines)
  if completed_line then
    return completed_line, false -- Section exists
  end

  -- Need to create section
  local is_daily = is_daily_notes_file(filepath)
  
  if is_daily then
    -- For DailyNotes: place above Log section
    local log_line = find_log_section(lines)
    if log_line then
      return log_line, true -- Insert before Log
    end
  end

  -- Default: end of file
  return #lines + 1, true
end

-- Extract task group (task + nested subtasks)
local function extract_task_group(lines, start_line)
  local task_group = {}
  local base_indent = nil
  local end_line = start_line

  -- Get the checked task line
  local task_line = lines[start_line]
  table.insert(task_group, task_line)

  -- Determine base indentation level
  base_indent = task_line:match("^(%s*)")

  -- Look for nested subtasks
  for i = start_line + 1, #lines do
    local line = lines[i]
    local indent = line:match("^(%s*)")
    
    -- Check if this line is more indented (subtask) or empty line
    if #indent > #base_indent then
      table.insert(task_group, line)
      end_line = i
    elseif line:match("^%s*$") then
      -- Empty line - include it if it's within the task group
      table.insert(task_group, line)
      end_line = i
    else
      -- Less or equal indent - task group ends
      break
    end
  end

  return task_group, end_line
end

-- Add timestamp inline to the task line
local function add_timestamp_inline(task_line)
  local timestamp = os.date(M.config.timestamp_format)
  -- Append timestamp to the end of the task line
  return task_line .. " " .. timestamp
end

-- Main function to process checkbox completion
function M.process_checkbox_completion()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  
  -- Only process markdown files
  if not filepath:match("%.md$") then
    return
  end

  -- Get current cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line_num = cursor[1]
  
  -- Get all lines
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local current_line = lines[current_line_num]
  
  -- Check if current line is a completed task with "- [x]" format (no dash or other formats)
  if not current_line:match("^%s*%-%s*%[[xX]%]") then
    return
  end

  -- Check if we already processed this line (avoid duplicate processing)
  if current_line:match("> Completed:") then
    return
  end

  -- Extract the entire task group
  local task_group, end_line = extract_task_group(lines, current_line_num)
  
  -- Add timestamp inline to first line (the task line)
  task_group[1] = add_timestamp_inline(task_group[1])

  -- Find or create Completed section
  local completed_pos, needs_creation = find_completed_section_position(lines, filepath)
  
  -- If section needs to be created, add the heading
  if needs_creation then
    if is_daily_notes_file(filepath) and completed_pos <= #lines then
      -- Insert before Log section (no blank line)
      table.insert(lines, completed_pos, "## Completed")
      completed_pos = completed_pos + 1
    else
      -- Add at end (no blank line)
      table.insert(lines, "## Completed")
      completed_pos = #lines + 1
    end
  else
    -- Move past the heading line
    completed_pos = completed_pos + 1
  end

  -- Insert task group at the beginning of Completed section (oldest first)
  -- We insert after the heading, so tasks accumulate from top
  -- Filter out blank lines to prevent gaps between tasks
  for i = #task_group, 1, -1 do
    if task_group[i]:match("^%s*$") == nil then
      table.insert(lines, completed_pos, task_group[i])
    end
  end

  -- Remove original task group (in reverse order to maintain indices)
  local remove_start = current_line_num
  local remove_end = end_line
  
  for i = remove_end, remove_start, -1 do
    table.remove(lines, i)
  end

  -- Update buffer
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  
  -- Save the buffer
  vim.cmd("silent write")
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  -- Create autocommand for TextChanged
  vim.api.nvim_create_autocmd("TextChanged", {
    pattern = "*.md",
    callback = function()
      -- Debounce to avoid triggering on every keystroke
      vim.defer_fn(function()
        M.process_checkbox_completion()
      end, 100)
    end,
    desc = "Auto-move completed tasks to Completed section",
  })
end

return M
