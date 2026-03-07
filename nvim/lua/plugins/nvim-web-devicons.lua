return {
	-- Run :NvimWebDeviconsHiTest to see all icons and their highlighting.
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			--It can be override_by_filename also. Check documentation
			override_by_filename = {
				["config"] = {
					icon = " ",
					color = "#6d8086",
					name = "Config",
				},
			},
			override_by_extension = {
				["apex"] = {
					icon = "",
					color = "#00A1E0",
					name = "ApexFile",
				},
				["cls"] = {
					icon = "",
					color = "#00A1E0",
					name = "ApexFile",
				},
				["trigger"] = {
					icon = "",
					color = "#00A1E0",
					name = "ApexFile",
				},
				["soql"] = {
					icon = "",
					color = "#00A1E0",
					name = "SOQL",
				},
				["code-workspace"] = {
					icon = " ",
					color = "#cbcb41",
					name = "JsonAdd",
				},
			},
		},
	},
}
