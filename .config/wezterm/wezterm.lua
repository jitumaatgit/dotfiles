local wezterm = require("wezterm")
local config = wezterm.config_builder()
-- make git bash the default shell (via Scoop)
config.default_prog = {
	"C:/Users/student/scoop/apps/git/current/bin/bash.exe",
	"--login",
	"-i",
}
-- Basics (Kitty/Tmux-like)
config.font = wezterm.font_with_fallback({
	"JetBrains Mono Nerd Font",
	"JetBrains Mono",
})
config.font_size = 12.0
config.color_scheme = "Cattpuccin Mocha" -- change to cattpuccin mocha
config.window_padding = { left = 5, right = 5, top = 5, bottom = 5 }
config.initial_cols = 120
config.initial_rows = 40
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32
config.colors = {
	tab_bar = {
		background = "#1e1e2e",

		active_tab = {
			bg_color = "#585b70",
			fg_color = "#f5e0dc",
			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = "#181825",
			fg_color = "#a6adc8",
		},

		inactive_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
			italic = true,
		},

		new_tab = {
			bg_color = "#1e1e2e",
			fg_color = "#a6adc8",
		},

		new_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
			italic = true,
		},
	},
}
config.audible_bell = "Disabled"
-- Leader key: Ctrl-b (tmux style)
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }
-- Main key assignments
config.keys = {
	-- Tabs (tmux: Ctrl-b c/n/p/&/w)
	{ key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "&", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	-- Panes (tmux: %/" / h/j/k/l / o)
	{ key = "|", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "o", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Next") },
	{ key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	-- Copy mode (tmux: [ / ])
	{ key = "[", mods = "LEADER", action = wezterm.action.CopyMode("ClearPattern") },
	{ key = "]", mods = "LEADER", action = wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }) },
	-- Zoom
	{ key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
}
-- Pane resize (tmux: Ctrl-b then M-h/j/k/l, but here LEADER + HJKL)
config.key_tables = {
	leader = {
		{ key = "H", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
		{ key = "J", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
		{ key = "K", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
		{ key = "L", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
		-- Esc or leader again to exit leader mode
		{ key = "b", mods = "CTRL", action = "PopKeyTable" }, -- Exit leader
		{ key = "Escape", action = "PopKeyTable" },
	},
}
return config
