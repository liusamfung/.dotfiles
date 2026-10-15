------------------------------------------------------------
-- Clipboard Sound
-- Plays a sound whenever the clipboard actually changes.
------------------------------------------------------------

local POLLING_INTERVAL = 0.05 -- 100 ms

local lastChange = hs.pasteboard.changeCount()

local watcher = hs.timer.new(POLLING_INTERVAL, function()
	local current = hs.pasteboard.changeCount()

	if current ~= lastChange then
		lastChange = current

		-- Play the built-in macOS sound
		hs.sound.getByName("Submarine"):play()
	end
end)

watcher:start()
