-- Salesforce status (plugins/salesforce/status.lua). pcall: if that folder is removed the component just disappears.
local function sf_status()
	local ok, status = pcall(require, "plugins.salesforce.status")
	return ok and status or nil
end

return {
	{
		"nvim-lualine/lualine.nvim",
		event = { "BufReadPost", "BufNewFile", "VeryLazy" },
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		-- init = function()
		-- 	local recording_register = vim.fn.reg_recording()
		-- 	if recording_register == "" then
		-- 		return ""
		-- 	else
		-- 		return "󰑋  Recording @" .. recording_register
		-- 	end
		-- end,
		opts = {
			options = {
				icons_enabled = true,
				-- theme = "horizon",
				-- theme = "seoul256",
				theme = "tomorrow_night",
				component_separators = "",
				section_separators = "",
				disabled_filetypes = {
					-- statusline = {},
					statusline = { "dashboard", "alpha", "snacks_dashboard" },
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				always_show_tabline = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
					refresh_time = 16, -- ~60fps
					events = {
						"WinEnter",
						"BufEnter",
						"BufWritePost",
						"SessionLoadPost",
						"FileChangedShellPost",
						"VimResized",
						"Filetype",
						"CursorMoved",
						"CursorMovedI",
						"ModeChanged",
					},
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					{
						"diff",
						symbols = {
							added = "󰐕",
							modified = "󰏫 ",
							removed = "󰍵",
						},
					},
					{
						function()
							local recording_register = vim.fn.reg_recording()
							if recording_register == "" then
								return ""
							else
								return "Recording @" .. recording_register
							end
						end,
					},
				},
				lualine_c = {
					{
						"diagnostics",
						symbols = {
							error = "󰀦 ",
							warn = "󰙎",
							info = "󰋽 ",
							hint = "󰛨 ",
						},
					},
				},
				lualine_x = {
					{
						-- Spinner / progress / check for <leader>tS and <leader>tv (plugins/salesforce/status.lua)
						function()
							local status = sf_status()
							return status and status.text() or ""
						end,
						cond = function()
							local status = sf_status()
							return status ~= nil and status.text() ~= ""
						end,
						color = function()
							local status = sf_status()
							return status and status.color() or nil
						end,
					},
					{
						function()
							-- Si quieres llamar directamente al web-devicons
							-- local devicons = require("nvim-web-devicons")
							-- local icon, hl = devicons.get_icon("ApexFile", "cls", { default = true })
							-- return icon .. " " .. require("sf").get_target_org()

							-- return "󰅣 " .. require("sf").get_target_org()
							-- get_target_org() raises an error while the org list is still loading (or outside
							-- a project): show nothing instead of failing on every redraw.
							local ok, org = pcall(function()
								return require("sf").get_target_org()
							end)
							return ok and org and org ~= "" and ("󰅟 " .. org) or ""
						end,
						color = { fg = "#00A1E0" },
					},
				},
				lualine_y = { "progress" },
				lualine_z = {
					{
						function()
							return " " .. os.date("%R")
						end,
					},
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = { "encoding", "fileformat" },
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {},
		},
	},
}
