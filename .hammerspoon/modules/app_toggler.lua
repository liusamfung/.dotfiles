-- ~/.hammerspoon/modules/app_toggler.lua

local M = {}

----------------------------------------------------------------------
-- Configuration
----------------------------------------------------------------------

-- How long we wait before considering an application truly frontmost.
-- This prevents the temporary Hammerspoon focus change caused by:
--
--     open "hammerspoon://..."
--
local STABLE_DELAY = 0.12

local HAMMERSPOON_BUNDLE_ID = "org.hammerspoon.Hammerspoon"

----------------------------------------------------------------------
-- Applications that need a command to create a window/document when
-- the process is running but has zero usable windows.
--
-- The default behavior is Cmd+N.
--
-- Add applications here if Cmd+N isn't the correct command.
----------------------------------------------------------------------

local NEW_WINDOW_KEYS = {
	["Notes"] = { mods = { "cmd" }, key = "n" },
	["Safari"] = { mods = { "cmd" }, key = "n" },
	["Google Chrome"] = { mods = { "cmd" }, key = "n" },
	["Terminal"] = { mods = { "cmd" }, key = "n" },
	["iTerm2"] = { mods = { "cmd" }, key = "n" },
}

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------

local stableFrontmost = nil
local pendingTimer = nil

----------------------------------------------------------------------
-- Get current frontmost application state
----------------------------------------------------------------------

local function getFrontmostState()
	local app = hs.application.frontmostApplication()

	if not app then
		return nil
	end

	local bundleID = app:bundleID()

	if not bundleID then
		return nil
	end

	local window = hs.window.frontmostWindow()

	local windowID = nil

	if window then
		local windowApp = window:application()

		if windowApp and windowApp:pid() == app:pid() then
			windowID = window:id()
		end
	end

	return {
		app = app,
		pid = app:pid(),
		bundleID = bundleID,
		windowID = windowID,
	}
end

----------------------------------------------------------------------
-- Update stable frontmost application
----------------------------------------------------------------------

local function updateStableFrontmost()
	local state = getFrontmostState()

	if not state then
		return
	end

	-- Hammerspoon itself must never become the stable application.
	--
	-- This is the important part that prevents:
	--
	--     User App
	--        ↓
	--     Kanata
	--        ↓
	--     open hammerspoon://...
	--        ↓
	--     Hammerspoon becomes frontmost temporarily
	--
	-- from corrupting our state.
	if state.bundleID == HAMMERSPOON_BUNDLE_ID then
		return
	end

	stableFrontmost = state
end

----------------------------------------------------------------------
-- Schedule a stable frontmost update
----------------------------------------------------------------------

local function scheduleStableFrontmostUpdate()
	if pendingTimer then
		pendingTimer:stop()
		pendingTimer = nil
	end

	pendingTimer = hs.timer.doAfter(STABLE_DELAY, function()
		pendingTimer = nil
		updateStableFrontmost()
	end)
end

----------------------------------------------------------------------
-- Get all application windows
----------------------------------------------------------------------

local function getAppWindows(app)
	if not app then
		return {}
	end

	local windows = app:allWindows()

	if not windows then
		return {}
	end

	return windows
end

----------------------------------------------------------------------
-- Find a usable window
--
-- A usable window is:
--
--     * not minimized
--     * visible
--
----------------------------------------------------------------------

local function getUsableWindow(app)
	local windows = getAppWindows(app)

	for _, window in ipairs(windows) do
		if not window:isMinimized() and window:isVisible() then
			return window
		end
	end

	return nil
end

----------------------------------------------------------------------
-- Find a minimized window
----------------------------------------------------------------------

local function getMinimizedWindow(app)
	local windows = getAppWindows(app)

	for _, window in ipairs(windows) do
		if window:isMinimized() then
			return window
		end
	end

	return nil
end

----------------------------------------------------------------------
-- Check whether the application has a usable window
----------------------------------------------------------------------

local function hasUsableWindow(app)
	return getUsableWindow(app) ~= nil
end

----------------------------------------------------------------------
-- Create a new window/document
----------------------------------------------------------------------

local function createNewWindow(appName, app)
	local config = NEW_WINDOW_KEYS[appName]

	-- Make absolutely sure the application is active first.
	app:unhide()
	app:activate()

	-- Give macOS a moment to finish activation.
	hs.timer.doAfter(0.05, function()
		-- If another mechanism already created/restored a window,
		-- don't create an unnecessary second one.
		if hasUsableWindow(app) then
			updateStableFrontmost()
			return
		end

		-- Application-specific shortcut.
		--
		-- Most macOS applications use Cmd+N for:
		--
		--     New Window
		--     New Document
		--     New Note
		--
		if config then
			hs.eventtap.keyStroke(config.mods, config.key, 0)
		else
			-- Generic fallback.
			hs.eventtap.keyStroke({ "cmd" }, "n", 0)
		end

		-- Give the application time to create the window.
		hs.timer.doAfter(STABLE_DELAY, function()
			updateStableFrontmost()
		end)
	end)
end

----------------------------------------------------------------------
-- Restore a minimized window
----------------------------------------------------------------------

local function restoreMinimizedWindow(app)
	local window = getMinimizedWindow(app)

	if not window then
		return false
	end

	app:unhide()
	app:activate()

	hs.timer.doAfter(0.05, function()
		window:unminimize()
		window:focus()

		hs.timer.doAfter(STABLE_DELAY, function()
			updateStableFrontmost()
		end)
	end)

	return true
end

----------------------------------------------------------------------
-- Check whether this application was the user's REAL previous app
----------------------------------------------------------------------

local function isStableTarget(app)
	if not app or not stableFrontmost then
		return false
	end

	return stableFrontmost.bundleID == app:bundleID()
end

----------------------------------------------------------------------
-- Application watcher
----------------------------------------------------------------------

M.watcher = hs.application.watcher.new(function(appName, event, app)
	if event == hs.application.watcher.activated then
		scheduleStableFrontmostUpdate()
	end
end)

M.watcher:start()

----------------------------------------------------------------------
-- Main toggle function
----------------------------------------------------------------------

function M.toggle(appName)
	if not appName or appName == "" then
		return
	end

	local app = hs.application.get(appName)

	------------------------------------------------------------------
	-- CASE 1
	--
	-- Application isn't running.
	--
	-- Launch it from scratch.
	------------------------------------------------------------------

	if not app then
		hs.application.launchOrFocus(appName)

		hs.timer.doAfter(STABLE_DELAY + 0.05, function()
			updateStableFrontmost()
		end)

		return
	end

	------------------------------------------------------------------
	-- CASE 2
	--
	-- Application is explicitly hidden.
	--
	-- Show it.
	------------------------------------------------------------------

	if app:isHidden() then
		app:unhide()
		app:activate()

		hs.timer.doAfter(STABLE_DELAY, function()
			updateStableFrontmost()
		end)

		return
	end

	------------------------------------------------------------------
	-- CASE 3
	--
	-- Application has a minimized window.
	--
	-- Restore it instead of creating another window.
	------------------------------------------------------------------

	local usableWindow = getUsableWindow(app)

	if not usableWindow then
		local restored = restoreMinimizedWindow(app)

		if restored then
			return
		end
	end

	------------------------------------------------------------------
	-- CASE 4
	--
	-- Application is running but has ZERO windows.
	--
	-- This is the important fix for applications such as Notes.
	--
	-- Example:
	--
	--     Notes process is alive
	--     Notes has zero windows
	--     app:activate() alone does NOT create a Note
	--
	-- Therefore:
	--
	--     activate
	--         ↓
	--     Cmd+N
	--         ↓
	--     new Note/window
	--
	------------------------------------------------------------------

	if not hasUsableWindow(app) then
		createNewWindow(appName, app)
		return
	end

	------------------------------------------------------------------
	-- CASE 5
	--
	-- Application has a real visible window.
	--
	-- Now we can perform the actual scratchpad toggle.
	--
	-- IMPORTANT:
	--
	-- We DO NOT use:
	--
	--     hs.application.frontmostApplication()
	--
	-- here.
	--
	-- That value can temporarily be Hammerspoon because of the
	-- hammerspoon:// URL invocation.
	--
	-- Instead we use stableFrontmost, which was captured before
	-- Hammerspoon received the URL.
	------------------------------------------------------------------

	if isStableTarget(app) then
		----------------------------------------------------------------
		-- The user was already working in this application.
		--
		-- Hide it.
		----------------------------------------------------------------

		app:hide()

		hs.timer.doAfter(STABLE_DELAY, function()
			updateStableFrontmost()
		end)

		return
	end

	------------------------------------------------------------------
	-- CASE 6
	--
	-- Application is running, has a visible window, but it wasn't
	-- the application the user was previously working in.
	--
	-- Bring it to the front.
	------------------------------------------------------------------

	app:activate()

	hs.timer.doAfter(STABLE_DELAY, function()
		updateStableFrontmost()
	end)
end

----------------------------------------------------------------------
-- URL Scheme
----------------------------------------------------------------------

hs.urlevent.bind("toggleapp", function(eventName, params)
	if not params or not params.name then
		return
	end

	M.toggle(params.name)
end)

----------------------------------------------------------------------
-- Initialize stable state after Hammerspoon starts
----------------------------------------------------------------------

hs.timer.doAfter(STABLE_DELAY, function()
	updateStableFrontmost()
end)

return M
