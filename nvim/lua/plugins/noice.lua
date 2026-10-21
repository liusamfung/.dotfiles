return {
	-- I have a problems with sf.nvim when that fetch json. Noice.nvim parse
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		keys = {
			{ "<leader>n", "<cmd>Noice snacks<cr>", desc = "Notification History (Snacks picker)" },
			{ "<leader>un", "<cmd>NoiceDismiss<cr>", desc = "Dismiss all notifications" },
		},
		opts = {
			cmdline = {
				view = "cmdline",
			},
		},
	},
}
