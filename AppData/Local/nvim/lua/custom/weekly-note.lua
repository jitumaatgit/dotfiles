local M = {}

local VAULT_PATH = "C:/Users/student/notes"
local DAILY_NOTES_PATH = VAULT_PATH .. "/docs/30-DailyNotes"
local WEEKLY_NOTES_PATH = DAILY_NOTES_PATH .. "/WeeklyNotes"

local function get_iso_week_data(date)
	local year = date.year
	local month = date.month
	local day = date.day

	local function julian_day(y, m, d)
		local a = math.floor((14 - m) / 12)
		local y_adj = y + 4800 - a
		local m_adj = m + 12 * a - 3
		return d + math.floor((153 * m_adj + 2) / 5) + 365 * y_adj + math.floor(y_adj / 4) - math.floor(y_adj / 100) + math.floor(y_adj / 400) - 32045
	end

	local jd = julian_day(year, month, day)
	local d4 = (jd + 31741 - 1461) % 7 + 1
	local jd_monday = jd - d4 + 1
	local jd_sunday = jd_monday - 1

	local function jd_to_date_inner(jd)
		local a = jd + 32044
		local b = math.floor((4 * a + 3) / 146097)
		local c = a - math.floor(146097 * b / 4)
		local d = math.floor((4 * c + 3) / 1461)
		local e = c - math.floor(1461 * d / 4)
		local m = math.floor((5 * e + 2) / 153)
		local day = e - math.floor((153 * m + 2) / 5) + 1
		local month = m + 3 - 12 * math.floor(m / 10)
		local year = d - 4800 + math.floor(m / 10)
		return { year = year, month = month, day = day }
	end

	local function get_iso_year_week(jd)
		local jan1 = julian_day(jd_to_date_inner(jd).year, 1, 1)
		local jan1_weekday = (jan1 + 1) % 7
		local days_since_jan1 = jd - jan1
		local week_num = math.floor((days_since_jan1 + jan1_weekday) / 7) + 1
		if week_num < 1 then
			week_num = 52
		elseif week_num > 52 then
			local next_jan1 = julian_day(jd_to_date_inner(jd).year + 1, 1, 1)
			local next_jan1_weekday = (next_jan1 + 1) % 7
			if (jd - next_jan1 + next_jan1_weekday) >= 0 then
				week_num = 1
			end
		end
		return jd_to_date_inner(jd).year, week_num
	end

	local yr, week = get_iso_year_week(jd)
	local sunday_jd = jd - ((jd + 1) % 7)

	return {
		year = yr,
		week = week,
		sunday_jd = sunday_jd,
	}
end

local function jd_to_date(jd)
	local a = jd + 32044
	local b = math.floor((4 * a + 3) / 146097)
	local c = a - math.floor(146097 * b / 4)
	local d = math.floor((4 * c + 3) / 1461)
	local e = c - math.floor(1461 * d / 4)
	local m = math.floor((5 * e + 2) / 153)
	local day = e - math.floor((153 * m + 2) / 5) + 1
	local month = m + 3 - 12 * math.floor(m / 10)
	local year = d - 4800 + math.floor(m / 10)
	return { year = year, month = month, day = day }
end

local function format_date(d)
	return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
end

local function get_day_name(d)
	local days = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
	local jd = math.floor(os.time(d) / 86400 + 719163)
	local weekday = (jd + 1) % 7
	return days[weekday + 1]
end

local function get_week_dates(iso_data)
	local dates = {}
	for i = 0, 6 do
		local d = jd_to_date(iso_data.sunday_jd + i)
		table.insert(dates, {
			date = d,
			date_str = format_date(d),
			day_name = get_day_name(d),
		})
	end
	return dates
end

local function get_daily_note_path(d)
	local year = string.format("%04d", d.year)
	local month = string.format("%02d", d.month)
	return string.format("%s/%s/%s/%s.md", DAILY_NOTES_PATH, year, month, format_date(d))
end

local function extract_section(content, section_name)
	local pattern = "## " .. section_name .. "\n(.-)\n## "
	local match = content:match(pattern)
	if not match then
		pattern = "## " .. section_name .. "\n(.*)$"
		match = content:match(pattern)
	end
	return match and match:gsub("^%s+", ""):gsub("%s+$", "") or nil
end

local function extract_sleep(content)
	local sleep = content:match("%*%*Hours of Sleep:%*%*%s*(%d+%.?%d*)")
	return sleep and tonumber(sleep) or nil
end

local function extract_energy_avg(content)
	local total = 0
	local count = 0
	for focus in content:gmatch("%*%*f(%d+%.?%d*)%*%*") do
		total = total + tonumber(focus)
		count = count + 1
	end
	if count > 0 then
		return total / count
	end
	return nil
end

local function extract_mood_avg(content)
	local total = 0
	local count = 0
	for mood in content:gmatch("%*%*m(%d+%.?%d*)%*%*") do
		total = total + tonumber(mood)
		count = count + 1
	end
	if count > 0 then
		return total / count
	end
	return nil
end

local function read_daily_note(path)
	local file = io.open(path, "r")
	if not file then return nil end
	local content = file:read("*a")
	file:close()
	return content
end

local function ensure_dir(path)
	local cmd = string.format('mkdir -p "%s"', path)
	os.execute(cmd)
end

local function calculate_week_stats(week_dates)
	local total_sleep = 0
	local sleep_count = 0
	local total_energy = 0
	local energy_count = 0
	local total_mood = 0
	local mood_count = 0

	for _, d in ipairs(week_dates) do
		local path = get_daily_note_path(d.date)
		local content = read_daily_note(path)
		if content then
			local sleep = extract_sleep(content)
			if sleep then
				total_sleep = total_sleep + sleep
				sleep_count = sleep_count + 1
			end
			local energy = extract_energy_avg(content)
			if energy then
				total_energy = total_energy + energy
				energy_count = energy_count + 1
			end
			local mood = extract_mood_avg(content)
			if mood then
				total_mood = total_mood + mood
				mood_count = mood_count + 1
			end
		end
	end

	local sleep_avg = sleep_count > 0 and (total_sleep / sleep_count) or nil
	local energy_avg = energy_count > 0 and (total_energy / energy_count) or nil
	local mood_avg = mood_count > 0 and (total_mood / mood_count) or nil

	return sleep_avg, energy_avg, mood_avg
end

local function get_inbox_notes(week_dates)
	local inbox_notes = {}
	local start_time = os.time(week_dates[1].date)
	local end_time = os.time(week_dates[#week_dates].date) + 86400

	local glob_result = vim.fn.glob(VAULT_PATH .. "/*.md", false, true)
	for _, filepath in ipairs(glob_result) do
		local mtime = vim.fn.getftime(filepath)
		if mtime >= start_time and mtime <= end_time then
			local name = vim.fn.fnamemodify(filepath, ":t:r")
			table.insert(inbox_notes, name)
		end
	end

	table.sort(inbox_notes)
	return inbox_notes
end

local function generate_weekly_note_content(iso_data, week_dates)
	local lines = {}
	local sleep_avg, energy_avg, mood_avg = calculate_week_stats(week_dates)
	local inbox_notes = get_inbox_notes(week_dates)

	table.insert(lines, "---")
	table.insert(lines, string.format('id: "%d-W%02d"', iso_data.year, iso_data.week))
	table.insert(lines, "aliases: []")
	table.insert(lines, "tags: []")
	table.insert(lines, "---")
	table.insert(lines, "")
	table.insert(lines, string.format("# Weekly Note Week %d", iso_data.week))
	table.insert(lines, "")

	table.insert(lines, "## Startup")
	table.insert(lines, "")
	table.insert(lines, "- [ ] move files to appropriate PARA folders.")
	table.insert(lines, "- [ ] add time sensitive tasks to calendar")
	table.insert(lines, "- [ ] clear email inbox")
	table.insert(lines, "- [ ] look ahead and behind 1 week on calendar, edit as needed")
	table.insert(lines, "- [ ] go through this weeks daily notes.")
	table.insert(lines, "- [ ] Set Goals")
	table.insert(lines, "- [ ] Move Items from backlog into todo that will help accomplish goals")
	table.insert(lines, "")

	table.insert(lines, "---")
	table.insert(lines, "## Health dashboard")
	table.insert(lines, "")
	table.insert(lines, "```")
	table.insert(lines, string.format("Week of %d-W%02d", iso_data.year, iso_data.week))
	if sleep_avg then
		table.insert(lines, string.format("- Sleep avg: %.1f/7 hours", sleep_avg))
	else
		table.insert(lines, "- Sleep avg: _/7 hours")
	end
	table.insert(lines, "- Top 3 completion: _/7 days")
	table.insert(lines, "- Housing applications: _")
	if mood_avg then
		table.insert(lines, string.format("- Mood avg: %.1f/5", mood_avg))
	else
		table.insert(lines, "- Mood avg: _/5")
	end
	if energy_avg then
		table.insert(lines, string.format("- Energy avg: %.1f/10", energy_avg))
	else
		table.insert(lines, "- Energy avg: _/10")
	end
	table.insert(lines, "- Health issues: [Y/N]")
	table.insert(lines, "- Week rating: _/10")
	table.insert(lines, "```")
	table.insert(lines, "")

	table.insert(lines, "---")
	table.insert(lines, "## Week at a Glance")
	table.insert(lines, "")

	for _, d in ipairs(week_dates) do
		local link_path = string.format("30-DailyNotes/%04d/%02d/%s", d.date.year, d.date.month, d.date_str)
		local link_text = string.format("- [[%s|%s %s]]", link_path, d.day_name, d.date_str)
		table.insert(lines, link_text)
	end

	table.insert(lines, "")

	table.insert(lines, "---")
	table.insert(lines, "## Log Digest")
	table.insert(lines, "")

	for _, d in ipairs(week_dates) do
		local path = get_daily_note_path(d.date)
		local content = read_daily_note(path)
		if content then
			local log_section = extract_section(content, "Log")
			if log_section and log_section ~= "" then
				table.insert(lines, string.format("### %s (%s)", d.day_name, d.date_str))
				table.insert(lines, log_section)
				table.insert(lines, "")
			end
		end
	end

	table.insert(lines, "---")
	table.insert(lines, "## Tangent Parking Lot")
	table.insert(lines, "")

	for _, d in ipairs(week_dates) do
		local path = get_daily_note_path(d.date)
		local content = read_daily_note(path)
		if content then
			local tangent_section = extract_section(content, "Tangent Parking Lot")
			if tangent_section and tangent_section ~= "" then
				table.insert(lines, string.format("### %s (%s)", d.day_name, d.date_str))
				table.insert(lines, tangent_section)
				table.insert(lines, "")
			end
		end
	end

	table.insert(lines, "---")
	table.insert(lines, "## Inbox")
	table.insert(lines, "")
	table.insert(lines, "Notes created this week that need to be PARA filed:")
	table.insert(lines, "")
	if #inbox_notes > 0 then
		for _, note in ipairs(inbox_notes) do
			table.insert(lines, string.format("- [[%s]]", note))
		end
	else
		table.insert(lines, "- (none)")
	end
	table.insert(lines, "")

	table.insert(lines, "---")
	table.insert(lines, "## End Of Week Review")
	table.insert(lines, "- What did I get done this week versus what I planned to get done?")
	table.insert(lines, "- What unexpectedly arose this week that blocked my productivity?")
	table.insert(lines, "- What worked well?")
	table.insert(lines, "- Where did I get stuck?")
	table.insert(lines, "- What did I learn?")
	table.insert(lines, "- Am I showing up for the key people in my life (spouses, boss, close friends, close family)?")
	table.insert(lines, "- When did I feel most energized?")
	table.insert(lines, "")

	table.insert(lines, "---")
	table.insert(lines, "## Planned Tasks")
	table.insert(lines, "Actions that will ensure I make progress on my goals")
	table.insert(lines, "")
	table.insert(lines, "- ")

	return table.concat(lines, "\n")
end

function M.create_weekly_note(opts)
	local today = os.date("*t")
	local iso_data = get_iso_week_data(today)

	if opts and opts.week and opts.year then
		iso_data.week = tonumber(opts.week)
		iso_data.year = tonumber(opts.year)
	end

	local year_dir = string.format("%s/%04d", WEEKLY_NOTES_PATH, iso_data.year)
	ensure_dir(year_dir)

	local filename = string.format("%04d-W%02d.md", iso_data.year, iso_data.week)
	local filepath = string.format("%s/%s", year_dir, filename)

	local file = io.open(filepath, "r")
	if file then
		file:close()
		vim.cmd("edit " .. filepath)
		return
	end

	local week_dates = get_week_dates(iso_data)
	local content = generate_weekly_note_content(iso_data, week_dates)

	file = io.open(filepath, "w")
	if file then
		file:write(content)
		file:close()
		vim.cmd("edit " .. filepath)
	else
		vim.notify("Failed to create weekly note", vim.log.levels.ERROR)
	end
end

function M.create_weekly_note_for_date(date_str)
	local year, month, day = date_str:match("(%d+)%-(%d+)%-(%d+)")
	if not year then
		vim.notify("Invalid date format. Use YYYY-MM-DD", vim.log.levels.ERROR)
		return
	end

	local date = {
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
	}

	local iso_data = get_iso_week_data(date)
	M.create_weekly_note({ week = iso_data.week, year = iso_data.year })
end

vim.api.nvim_create_user_command("ObsidianWeekly", function(args)
	if args.args and args.args ~= "" then
		M.create_weekly_note_for_date(args.args)
	else
		M.create_weekly_note()
	end
end, { nargs = "?", desc = "Create or open weekly note" })

return M
