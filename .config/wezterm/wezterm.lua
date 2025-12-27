local wezterm = require("wezterm")
local act = wezterm.action
local utils = require("utils")
local config = wezterm.config_builder()
-- make git bash the default shell (via Scoop)
config.default_prog = {
	"C:/Users/student/scoop/apps/git/current/bin/bash.exe",
	"--login",
	"-i",
}
-- appearance settings
config.font = wezterm.font_with_fallback({
	"Cascadia Code",
	"JetBrains Mono",
})
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.font_size = 12.0
config.adjust_window_size_when_changing_font_size = false
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.color_scheme = "Catppuccin Mocha"
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.initial_cols = 120
config.initial_rows = 40
config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32
config.inactive_pane_hsb = {
	saturation = 0.7,
	brightness = 0.7,
}
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
config.hyperlink_rules = {
	-- Matches: a URL in parens: (URL)
	{
		regex = "\\((\\w+://\\S+)\\)",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in brackets: [URL]
	{
		regex = "\\[(\\w+://\\S+)\\]",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in curly braces: {URL}
	{
		regex = "\\{(\\w+://\\S+)\\}",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in angle brackets: <URL>
	{
		regex = "<(\\w+://\\S+)>",
		format = "$1",
		highlight = 1,
	},
	-- Then handle URLs not wrapped in brackets
	{
		-- Before
		--regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
		--format = '$0',
		-- After
		regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
		format = "$1",
		highlight = 1,
	},
	-- implicit mailto link
	{
		regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
		format = "mailto:$0",
	},
}
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://github.com/$1/$3",
})

-- local merged_config = utils.merge_tables(config, local_config) - not used yet, from https://github.com/yutkat/dotfiles/blob/main/.config/wezterm/wezterm.lua

-- show which key table is active in the status area
---@diagnostic disable-next-line: unused-local
wezterm.on("update-right-status", function(window, pane)
	local name = window:active_key_table()
	if name then
		name = "TABLE: " .. name
	end
	window:set_right_status(name or "")
end)

config.audible_bell = "Disabled"
-- Keybinds
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }
-- Main key assignments
config.keys = {
	-- Tabs
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "&", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	-- Panes
	{
		key = "!",
		mods = "LEADER | SHIFT",
		---@diagnostic disable-next-line: unused-local
		action = wezterm.action_callback(function(win, pane)
			---@diagnostic disable-next-line: unused-local
			local tab, window = pane:move_to_new_tab()
		end),
	},
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "o", mods = "LEADER", action = act.ActivatePaneDirection("Next") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "+", mods = "LEADER|ALT|SHIFT", action = "IncreaseFontSize" },
	{ key = "=", mods = "LEADER|ALT", action = "ResetFontSize" },
	{ key = "-", mods = "LEADER|ALT", action = "DecreaseFontSize" },
	-- launchers
	{ key = "a", mods = "LEADER", action = act.ShowLauncher },
	{ key = " ", mods = "LEADER", action = act.ShowTabNavigator },
	-- Copy mode
	{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "]", mods = "LEADER", action = act({ CopyTo = "ClipboardAndPrimarySelection" }) },
	-- Zoom
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	-- edit tab name
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of the text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- CTRL+Space, followed by 'r' will put us in resize-pane
	-- mode until we cancel that mode.
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
		}),
	},
	-- CTRL+Space followed by 'a' will put us in activate_pane
	-- mode until we press some other key or until 1 second passes
	-- {
	-- 	key = "a",
	-- 	mods = "LEADER",
	-- 	action = act.ActivateKeyTable({
	-- 		name = "activate_pane",
	-- 		timeout_milliseconds = 1000,
	-- 	}),
	-- },
	{
		key = ".", -- Pause Mode
		mods = "LEADER",
		action = act.Multiple({
			act.ScrollByLine(-1),
			act.ActivateCopyMode,
			act.ClearSelection,
		}),
	},
	{
		key = "s",
		mods = "LEADER",
		action = act.PaneSelect({
			alphabet = "1234567890",
		}),
	},
}

-- Pane resize
config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
		-- Esc or leader again to exit leader mode
		{ key = "Space", mods = "CTRL", action = "PopKeyTable" }, -- Exit leader
		{ key = "Escape", action = "PopKeyTable" },
	},
}

return config
