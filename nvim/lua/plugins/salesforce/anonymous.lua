-- Execute Anonymous, Developer Console style.
--
--   toggle_editor()  <leader>te  floating editor on <project>/.sfdx/anonymous.apex (git ignores .sfdx)
--   run(selection)   <leader><CR> inside it: runs the buffer or the Visual selection with `sf apex run --json`
--   toggle_output()  <leader>tE  shows / hides the output of the last run
--   pick_history()   <leader>tl  every run made here (code, result, log), kept in .sfdx/anonymous-history
--   pick_log()       <leader>tL  the debug logs the org has saved (only exist while a trace flag is active)
--
-- The CLI is run ONCE and its answer is kept in memory, so switching between "Debug Only" and the full log
-- never executes the Apex again. When the run ends the output window opens by itself, focused, so it can be
-- scrolled right away. `d` switches the view, `q` closes it and brings the editor back.
local M = {}

local status = require("plugins.salesforce.status")

local editor = { win = nil, cursor = nil }
---@type { win: integer?, buf: integer?, last: { ok: boolean, header: string, log: string?, from_run: boolean? }?, mode: "debug"|"full" }
local output = { win = nil, buf = nil, last = nil, mode = "debug" }
local ns = vim.api.nvim_create_namespace("sf_anonymous")

-- Output --------------------------------------------------------------------------------------------------

--- Log events worth showing in "Debug Only". A line that starts with a time and an event opens a new entry;
--- lines without one continue the previous entry (multi-line System.debug messages).
---@param log string
---@return { text: string, hl: string? }[]
local function debug_entries(log)
	local entries, current = {}, nil
	for line in (log .. "\n"):gmatch("(.-)\n") do
		local event, rest = line:match("^%d+:%d+:%d+%.%d+ %(%d+%)|([%w_]+)(.*)$")
		if event then
			current = nil
			if event == "USER_DEBUG" then
				local lnum, level, msg = rest:match("^|%[(%d+)%]|(%w+)|(.*)$")
				if lnum then
					local hl = (level == "WARN" and "DiagnosticWarn") or (level == "ERROR" and "DiagnosticError") or nil
					current =
						{ text = ("[%s] %s%s"):format(lnum, level == "DEBUG" and "" or level .. " ", msg), hl = hl }
				end
			elseif event == "EXCEPTION_THROWN" or event == "FATAL_ERROR" then
				current = { text = ("%s %s"):format(event, rest:gsub("^|", ""):gsub("|", " ")), hl = "DiagnosticError" }
			end
			if current then
				table.insert(entries, current)
			end
		elseif current then
			current.text = current.text .. "\n" .. line
		end
	end
	return entries
end

local NO_LOG = "(no log: the CLI returns none when a run fails)"

local function render()
	local buf, last = output.buf, output.last
	if not (buf and vim.api.nvim_buf_is_valid(buf) and last) then
		return
	end

	local lines, marks = {}, {}
	local function add(text, hl)
		for _, l in ipairs(vim.split(text, "\n", { plain = true })) do
			table.insert(lines, l)
			if hl then
				table.insert(marks, { #lines - 1, hl })
			end
		end
	end

	add(last.header, last.ok and "DiagnosticOk" or "DiagnosticError")
	add("")
	if output.mode == "full" then
		add(last.log or NO_LOG, last.log == nil and "Comment" or nil)
	elseif not last.log then
		add(NO_LOG, "Comment")
	else
		local entries = debug_entries(last.log)
		if #entries == 0 then
			add("(no System.debug output)", "Comment")
		end
		for _, entry in ipairs(entries) do
			add(entry.text, entry.hl)
		end
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(buf, ns, m[1], 0, { line_hl_group = m[2] })
	end

	-- the full log is highlighted by the sflog parser; the filtered view is not a log any more
	if output.mode == "full" and last.log then
		vim.bo[buf].filetype = "sflog"
	else
		pcall(vim.treesitter.stop, buf)
		vim.bo[buf].filetype = ""
	end

	if output.win and vim.api.nvim_win_is_valid(output.win) then
		vim.api.nvim_win_set_config(output.win, {
			title = output.mode == "debug" and " Output: Debug Only " or " Output: Full log ",
			title_pos = "center",
		})
	end
end

local function output_is_open()
	return output.win ~= nil and vim.api.nvim_win_is_valid(output.win)
end

local function close_output()
	if output_is_open() then
		vim.api.nvim_win_close(output.win, true)
	end
	output.win = nil
end

---@param title string
---@param footer string
---@param size { [1]: number, [2]: number } proportions of the editor: { width, height }
local function float_config(title, footer, size)
	local width = math.floor(vim.o.columns * size[1])
	local height = math.floor(vim.o.lines * size[2])
	return {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2) - 1,
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
		footer = footer,
		footer_pos = "center",
	}
end

local OUTPUT_SIZE = { 0.9, 0.85 }
local EDITOR_SIZE = { 0.75, 0.65 }

local function open_output()
	if not output.last then
		return vim.notify("No Execute Anonymous output yet", vim.log.levels.INFO)
	end
	close_output()

	output.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[output.buf].bufhidden = "wipe"
	vim.bo[output.buf].swapfile = false
	output.win = vim.api.nvim_open_win(
		output.buf,
		true,
		float_config(
			" Output ",
			output.last.from_run and " d  debug only / full log     q  back to the editor "
				or " d  debug only / full log     q  close ",
			OUTPUT_SIZE
		)
	)
	vim.wo[output.win].wrap = true
	vim.wo[output.win].linebreak = true
	render()

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = output.buf, desc = "SF: " .. desc })
	end
	map("d", function()
		output.mode = output.mode == "debug" and "full" or "debug"
		render()
		vim.api.nvim_win_set_cursor(output.win, { 1, 0 })
	end, "toggle Debug Only / full log")
	map("q", function()
		close_output()
		if output.last.from_run then
			M.toggle_editor() -- keep iterating: the snippet comes back
		end
	end, "close the output (and go back to the editor after a run)")
end

function M.toggle_output()
	if output_is_open() then
		return close_output()
	end
	open_output()
end

-- History of runs (<leader>tl) --------------------------------------------------------------------------------

local MAX_HISTORY = 30

---@param root string
local function history_dir(root)
	return root:gsub("/$", "") .. "/.sfdx/anonymous-history"
end

--- Keeps every run (code, result and log), failures included, in <project>/.sfdx/anonymous-history, newest 30.
---@param root string
---@param code string
---@param result { ok: boolean, header: string, log: string? }
local function save_history(root, code, result)
	local dir = history_dir(root)
	vim.fn.mkdir(dir, "p")
	local now = os.time()
	local name = ("%s-%03d.json"):format(os.date("%Y%m%d-%H%M%S", now), math.floor(vim.uv.hrtime() / 1e6) % 1000)
	pcall(function()
		local entry =
			vim.json.encode({ time = now, code = code, ok = result.ok, header = result.header, log = result.log })
		vim.fn.writefile({ entry }, dir .. "/" .. name)
	end)
	local files = vim.fn.glob(dir .. "/*.json", false, true)
	table.sort(files)
	for i = 1, #files - MAX_HISTORY do
		vim.fn.delete(files[i])
	end
end

---@param code string
local function load_into_editor(code)
	if not (editor.win and vim.api.nvim_win_is_valid(editor.win)) then
		M.toggle_editor()
	end
	if editor.win and vim.api.nvim_win_is_valid(editor.win) then
		vim.api.nvim_buf_set_lines(
			vim.api.nvim_win_get_buf(editor.win),
			0,
			-1,
			false,
			vim.split(code, "\n", { plain = true })
		)
	end
end

--- <leader>tl: the runs made with Execute Anonymous, newest first. Enter shows the result in the output window
--- (Debug Only / full log); ctrl-e puts that code back in the editor.
function M.pick_history()
	local sf_ok, root = pcall(require("sf.util").get_sf_root)
	if not sf_ok then
		return vim.notify("Not inside a Salesforce project", vim.log.levels.WARN)
	end
	if not pcall(require, "fzf-lua") then
		return vim.notify("fzf-lua is needed to pick a run", vim.log.levels.ERROR)
	end

	local files = vim.fn.glob(history_dir(root) .. "/*.json", false, true)
	table.sort(files, function(a, b)
		return a > b
	end)
	local rows, by_row = {}, {}
	for i, file in ipairs(files) do
		local ok, entry = pcall(function()
			return vim.json.decode(table.concat(vim.fn.readfile(file), "\n"))
		end)
		if ok and type(entry) == "table" then
			local first = ""
			for line in (entry.code or ""):gmatch("[^\n]+") do
				local trimmed = vim.trim(line)
				if trimmed ~= "" and not trimmed:match("^//") then
					first = trimmed
					break
				end
			end
			local row = ("%2d  %s  %s  %s"):format(
				i,
				os.date("%Y-%m-%d %H:%M:%S", entry.time),
				entry.ok and "✓" or "✗",
				first:sub(1, 70)
			)
			table.insert(rows, row)
			by_row[row] = entry
		end
	end
	if #rows == 0 then
		return vim.notify("No Execute Anonymous runs yet. Run something with <leader>te first.", vim.log.levels.INFO)
	end

	require("fzf-lua").fzf_exec(rows, {
		prompt = "Anonymous runs> ",
		fzf_opts = { ["--header"] = "enter: output    ctrl-e: put the code back in the editor" },
		winopts = { height = 0.6, width = 0.8, preview = { layout = "vertical", vertical = "down:45%" } },
		preview = function(items)
			local entry = by_row[items[1]]
			return entry and (entry.code or "") or ""
		end,
		actions = {
			["default"] = function(selected)
				local entry = by_row[selected[1]]
				if not entry then
					return
				end
				output.last = {
					ok = entry.ok,
					header = ("Run of %s\n%s"):format(os.date("%Y-%m-%d %H:%M:%S", entry.time), entry.header),
					log = entry.log,
				}
				open_output()
			end,
			["ctrl-e"] = function(selected)
				local entry = by_row[selected[1]]
				if entry then
					load_into_editor(entry.code or "")
				end
			end,
		},
	})
end

-- Running ---------------------------------------------------------------------------------------------------

--- Turns the CLI's answer into { ok, header, log }.
---@param obj vim.SystemCompleted
local function parse_result(obj)
	local ok, decoded = pcall(vim.json.decode, obj.stdout or "")
	if not ok or type(decoded) ~= "table" then
		local err = vim.trim(obj.stderr or "")
		return { ok = false, header = "✗ sf returned no JSON" .. (err ~= "" and (": " .. err) or "") }
	end

	local result = decoded.result
	if type(result) == "table" and result.success == true then
		return { ok = true, header = "✓ Executed successfully", log = result.logs }
	end
	if type(result) == "table" and result.compiled == false then
		local where = ("line %s, column %s"):format(result.line, result.column)
		return {
			ok = false,
			header = ("✗ Compilation failed at %s\n%s"):format(where, result.compileProblem or ""),
			log = result.logs,
		}
	end
	if type(result) == "table" and result.success == false then
		local stack = result.exceptionStackTrace
		local text = (result.exceptionMessage or "") .. ((stack and stack ~= "") and ("\n" .. stack) or "")
		return { ok = false, header = "✗ Execution failed\n" .. text, log = result.logs }
	end
	-- errors come as { message = "Compilation failed at Line 2 column 9 with the error:\n\n..." }
	local message = (decoded.message or "sf failed"):gsub("\n\n+", "\n")
	return { ok = false, header = "✗ " .. message }
end

--- The Visual selection (call it while still in Visual mode), preceded by blank lines so the line numbers of
--- the log (`[3]`) and of compile errors match the lines of the editor and not the lines of the fragment.
---@return string padded the text to run
---@return string raw only the selected text (what the history keeps)
local function selection_text()
	local from, to = vim.fn.getpos("v"), vim.fn.getpos(".")
	local region = vim.fn.getregion(from, to, { type = vim.fn.mode() })
	local first_line = math.min(from[2], to[2])
	local raw = table.concat(region, "\n")
	return ("\n"):rep(first_line - 1) .. raw, raw
end

---@param selection boolean run only the Visual selection instead of the whole buffer
function M.run(selection)
	local sf_ok, root = pcall(require("sf.util").get_sf_root)
	if not sf_ok then
		return vim.notify("Not inside a Salesforce project", vim.log.levels.WARN)
	end
	local org_ok, org = pcall(function()
		return require("sf").get_target_org()
	end)
	if not org_ok or org == "" then
		return vim.notify("Target_org empty! Select one with <leader>tot", vim.log.levels.WARN)
	end
	if status.running() then
		return vim.notify("Another SF task is still running", vim.log.levels.WARN)
	end

	local file, temporary, code
	if selection then
		local text, raw = selection_text()
		if vim.trim(text) == "" then
			return vim.notify("Empty selection", vim.log.levels.WARN)
		end
		file = vim.fn.tempname() .. ".apex"
		temporary = true
		code = raw
		vim.fn.writefile(vim.split(text, "\n", { plain = true }), file)
	else
		vim.cmd("silent noautocmd write") -- noautocmd: no prettier on a half-written snippet
		file = vim.api.nvim_buf_get_name(0)
		code = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	end

	-- the editor and any previous output must not cover what is coming
	close_output()
	if editor.win and vim.api.nvim_win_is_valid(editor.win) then
		M.toggle_editor()
	end

	status.start(function(elapsed)
		return ("anonymous %ds"):format(elapsed)
	end)
	vim.system(
		{ "sf", "apex", "run", "--file", file, "-o", org, "--json" },
		{ cwd = root, text = true },
		vim.schedule_wrap(function(obj)
			if temporary then
				vim.fn.delete(file)
			end
			output.last = parse_result(obj)
			output.last.from_run = true
			save_history(root, code, output.last)
			status.finish(output.last.ok, "anonymous")
			open_output()
		end)
	)
end

-- Saved logs (<leader>tL) -------------------------------------------------------------------------------------

--- "2026-10-18T17:01:40+0000" (UTC, as Salesforce returns it) -> "2026-10-18 12:01:40" in the local time zone.
---@param iso string
---@return string
local function utc_to_local(iso)
	local y, mo, d, h, mi, sec = iso:match("^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
	if not y then
		return iso
	end
	local as_local = os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = sec, isdst = false })
	-- os.time reads the table as local time; the difference between local and UTC clocks corrects that
	local offset = os.time(os.date("*t", as_local)) - os.time(os.date("!*t", as_local))
	return os.date("%Y-%m-%d %H:%M:%S", as_local + offset) --[[@as string]]
end
M._utc_to_local = utc_to_local

--- Lists the debug logs the org has saved (they exist only while a trace flag is active for the user), with
--- the time in the local zone, and opens the chosen one in the output window (Debug Only / full log).
function M.pick_log()
	local sf_ok, root = pcall(require("sf.util").get_sf_root)
	if not sf_ok then
		return vim.notify("Not inside a Salesforce project", vim.log.levels.WARN)
	end
	local org_ok, org = pcall(function()
		return require("sf").get_target_org()
	end)
	if not org_ok or org == "" then
		return vim.notify("Target_org empty! Select one with <leader>tot", vim.log.levels.WARN)
	end
	if not pcall(require, "fzf-lua") then
		return vim.notify("fzf-lua is needed to pick a log", vim.log.levels.ERROR)
	end

	vim.notify("Listing the org's debug logs...")
	vim.system(
		{ "sf", "apex", "list", "log", "-o", org, "--json" },
		{ cwd = root, text = true },
		vim.schedule_wrap(function(obj)
			local ok, decoded = pcall(vim.json.decode, obj.stdout or "")
			local logs = ok and type(decoded) == "table" and decoded.result
			if type(logs) ~= "table" then
				return vim.notify("Could not list the logs: " .. vim.trim(obj.stderr or ""), vim.log.levels.ERROR)
			end
			if #logs == 0 then
				return vim.notify(
					"The org has no saved debug logs. They are only saved while a trace flag is active for your user.",
					vim.log.levels.WARN
				)
			end

			local rows, by_row = {}, {}
			for _, log in ipairs(logs) do
				local operation = tostring(log.Operation or ""):gsub("/+$", ""):match("[^/]+$") or ""
				local row = ("%s | %6d B | %s | %s | %s"):format(
					utc_to_local(log.StartTime or ""),
					log.LogLength or 0,
					operation,
					(log.LogUser and log.LogUser.Name) or "?",
					log.Status or ""
				)
				table.insert(rows, row)
				by_row[row] = log
			end

			require("fzf-lua").fzf_exec(rows, {
				prompt = "Apex logs> ",
				winopts = { height = 0.6, width = 0.8, preview = { layout = "vertical", vertical = "down:40%" } },
				preview = function(items)
					local log = by_row[items[1]]
					return log
							and ("Id: %s\nStart (UTC): %s\nDuration: %s ms\nOperation: %s\nApplication: %s\nStatus: %s"):format(
								log.Id,
								log.StartTime,
								log.DurationMilliseconds,
								log.Operation,
								log.Application,
								log.Status
							)
						or ""
				end,
				actions = {
					["default"] = function(selected)
						local log = by_row[selected[1]]
						if not log then
							return
						end
						vim.notify("Downloading the log...")
						vim.system(
							{ "sf", "apex", "get", "log", "-i", log.Id, "-o", org, "--json" },
							{ cwd = root, text = true },
							vim.schedule_wrap(function(got)
								local got_ok, body = pcall(vim.json.decode, got.stdout or "")
								local text = got_ok and vim.tbl_get(body, "result", 1, "log")
								if type(text) ~= "string" then
									return vim.notify("Could not download the log", vim.log.levels.ERROR)
								end
								output.last = {
									ok = true,
									header = ("✓ Saved log %s (%s)"):format(
										utc_to_local(log.StartTime or ""),
										log.Id
									),
									log = text,
								}
								open_output()
							end)
						)
					end,
				},
			})
		end)
	)
end

-- Editor ------------------------------------------------------------------------------------------------------

function M.toggle_editor()
	if editor.win and vim.api.nvim_win_is_valid(editor.win) then
		editor.cursor = vim.api.nvim_win_get_cursor(editor.win)
		local buf = vim.api.nvim_win_get_buf(editor.win)
		if vim.bo[buf].modified then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("silent noautocmd write")
			end)
		end
		vim.api.nvim_win_close(editor.win, true)
		editor.win = nil
		return
	end

	local ok, root = pcall(require("sf.util").get_sf_root)
	if not ok then
		return vim.notify("Not inside a Salesforce project", vim.log.levels.WARN)
	end
	local path = root:gsub("/$", "") .. "/.sfdx/anonymous.apex"
	if not vim.uv.fs_stat(path) then
		vim.fn.mkdir(vim.fs.dirname(path), "p")
		vim.fn.writefile({
			"// Execute Anonymous. <leader><CR> runs the whole buffer (or the Visual selection). q hides this window.",
			"System.debug('Hello');",
		}, path)
	end

	local buf = vim.fn.bufadd(path)
	vim.fn.bufload(buf)
	vim.bo[buf].buflisted = false
	vim.bo[buf].filetype = "apex"

	editor.win = vim.api.nvim_open_win(
		buf,
		true,
		float_config(" Execute Anonymous ", " <leader><CR> run   q / <leader>te hide ", EDITOR_SIZE)
	)
	vim.wo[editor.win].number = true
	vim.wo[editor.win].signcolumn = "no"
	if editor.cursor then
		pcall(vim.api.nvim_win_set_cursor, editor.win, editor.cursor)
	end

	local function map(modes, lhs, rhs, desc)
		vim.keymap.set(modes, lhs, rhs, { buffer = buf, desc = "SF: " .. desc })
	end
	-- A plain <CR> deliberately does nothing special: running code in the org must not happen by accident.
	map("n", "<leader><CR>", function()
		M.run(false)
	end, "execute the whole snippet")
	map("x", "<leader><CR>", function()
		M.run(true)
	end, "execute the selection")
	map("n", "q", M.toggle_editor, "hide the Execute Anonymous window")
end

return M
