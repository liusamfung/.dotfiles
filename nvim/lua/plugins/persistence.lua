return {
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
		keys = {
			{
				"<leader>qb",
				function()
					require("persistence").load()
				end,
				desc = "Session: load the one of the current workdir",
			},
			{
				"<leader>qs",
				function()
					require("persistence").select()
				end,
				desc = "Session: select one to load",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Session: load the last one",
			},
		},
	},
}
