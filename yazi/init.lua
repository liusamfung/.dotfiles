-- require("no-status"):setup() -- https://github.com/yazi-rs/plugins/tree/main/no-status.yazi
require("easyjump"):setup() -- https://github.com/mikavilpas/easyjump.yazi
require("starship"):setup() -- https://github.com/Rolv-Apneseth/starship.yazi
require("duckdb"):setup() -- https://github.com/wylie102/duckdb.yazi
require("git"):setup() -- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("folder-rules"):setup()
require("restore"):setup({ -- https://github.com/boydaihungst/restore.yazi
	show_confirm = true,
})
require("recycle-bin"):setup({ -- https://github.com/uhs-robert/recycle-bin.yazi
	trash_dir = "/Users/liusam/.local/share/Trash/files", -- Uncomment to use specific directory
}) -- https://github.com/uhs-robert/recycle-bin.yazi
-- https://yazi-rs.github.io/docs/tips/#user-group-in-status
Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Line({
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	})
end, 500, Status.RIGHT)

Status:children_add(function(self)
	local current_dir_url = cx.active.current.cwd
	local current_dir_path = tostring(current_dir_url)
	local home_path = "/Users/liusam"
	local display_path
	if string.sub(current_dir_path, 1, #home_path) == home_path then
		display_path = string.gsub(current_dir_path, "^" .. home_path, "~", 1)
	else
		display_path = current_dir_path
	end
	local output = display_path
	local h = self._current.hovered
	if h and h.link_to then
		output = output .. " -> " .. tostring(h.link_to)
	end
	return output .. " | "
end, 1, Status.LEFT)
