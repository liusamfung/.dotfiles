-- Tiny "something is running" indicator for the lualine (see the component in lualine.lua).
--
--   start(render)  spinner + text while a long task runs; render(elapsed_seconds) returns the text
--   finish(ok, s)  show "✓ s" / "✗ s" for a few seconds, then disappear
--
-- Used by <leader>tS (sObject refresh) and <leader>tv (validate file), see salesforce.lua.
local M = {}

local FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local TICK_MS = 200
local HIDE_AFTER_MS = 3000
local COLORS = { running = "#e0af68", ok = "#9ece6a", err = "#f7768e" }

---@type { kind: "running"|"ok"|"err", render: (fun(elapsed: integer): string)?, text: string?, started: integer }?
local state
local timer

--- Filled by the sf_compile linter (nvim-lint.lua) when it parses the CLI answer, read by <leader>tv.
---@type { ok: boolean?, failures: integer?, error: string? }?
M.compile_result = nil

local function redraw()
	pcall(function()
		require("lualine").refresh({ place = { "statusline" }, trigger = "timer" })
	end)
end

local function stop_timer()
	if timer then
		timer:stop()
		timer:close()
		timer = nil
	end
end

---@param render fun(elapsed: integer): string
function M.start(render)
	stop_timer()
	state = { kind = "running", render = render, started = vim.uv.hrtime() }
	timer = vim.uv.new_timer()
	timer:start(0, TICK_MS, vim.schedule_wrap(redraw))
end

---@param ok boolean
---@param text string
function M.finish(ok, text)
	stop_timer()
	local mine = { kind = ok and "ok" or "err", text = text, started = vim.uv.hrtime() }
	state = mine
	redraw()
	vim.defer_fn(function()
		if state == mine then -- a newer task may have replaced it meanwhile
			state = nil
			redraw()
		end
	end, HIDE_AFTER_MS)
end

function M.running()
	return state ~= nil and state.kind == "running"
end

--- lualine component: empty string when there is nothing to show.
function M.text()
	if not state then
		return ""
	end
	if state.kind == "running" then
		local elapsed = math.floor((vim.uv.hrtime() - state.started) / 1e9)
		local frame = FRAMES[(math.floor(vim.uv.hrtime() / 1e6 / TICK_MS) % #FRAMES) + 1]
		local ok, text = pcall(state.render, elapsed)
		return frame .. " " .. (ok and text or "")
	end
	return (state.kind == "ok" and "✓ " or "✗ ") .. state.text
end

function M.color()
	return { fg = state and COLORS[state.kind] or COLORS.running }
end

return M
