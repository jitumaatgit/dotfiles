local wezterm = require 'wezterm'
local config = wezterm.config_builder()
-- Basics (Kitty/Tmux-like)
config.font = wezterm.font 'JetBrains Mono Nerd Font' -- Install if needed
config.color_scheme = 'OneDark' -- Or 'Tokyo Night'
config.window_padding = { left = 5, right = 5, top = 5, bottom = 5 }
config.initial_cols = 120
config.initial_rows = 40
config.window_opacity = 0.95
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
config.audible_bell = 'Disabled'
-- Leader key: Ctrl-b (tmux style)
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
-- Main key assignments
config.keys = {
  -- Tabs (tmux: Ctrl-b c/n/p/&/w)
  { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab {} },
  { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) },
  { key = '&', mods = 'LEADER', action = wezterm.action.SpawnTab {} }, -- Reuse c for new, & to close current?
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentTab { confirm = true } },
  -- Panes (tmux: %/" / h/j/k/l / o)
  { key = '|', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'o', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Next' },
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },
  -- Copy mode (tmux: [ / ])
  { key = '[', mods = 'LEADER', action = wezterm.action.CopyMode 'ClearPattern' },
  { key = ']', mods = 'LEADER', action = wezterm.action { CopyTo = 'ClipboardAndPrimarySelection' } },
  -- Zoom
  { key = 'z', mods = 'LEADER', action = wezterm.action.TogglePaneZoomState },
}
-- Pane resize (tmux: Ctrl-b then M-h/j/k/l, but here LEADER + HJKL)
config.key_tables = {
  leader = {
    { key = 'H', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
    { key = 'J', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
    { key = 'K', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
    { key = 'L', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
    -- Esc or leader again to exit leader mode
    { key = 'b', mods = 'CTRL', action = nil }, -- Exit leader
    { key = 'Escape', action = nil },
  },
}
return config
