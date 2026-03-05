return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
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
						function()
							return "󰅣 " .. require("sf").get_target_org()
							-- return "󰅟 " .. require("sf").get_target_org()
						end,
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
