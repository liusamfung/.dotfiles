return {
	{
		"mikavilpas/yazi.nvim",
		-- event = "VeryLazy",
		dependencies = {
			-- check the installation instructions at
			-- https://github.com/folke/snacks.nvim
			"folke/snacks.nvim",
		},
		keys = {
			-- 👇 in this section, choose your own keymappings!
			{
				"<leader>e",
				mode = { "n", "v" },
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>E",
				function()
					-- the git root of the current file; outside a git repo, the folder where nvim was started
					require("yazi").yazi(nil, vim.fs.root(0, ".git") or vim.fn.getcwd())
				end,
				desc = "Open yazi at the project root (git root or cwd)",
			},
		},
		opts = {
			-- if you want to open yazi instead of netrw, see below for more info
			open_for_directories = true,
			keymaps = {
				show_help = "<f1>",
			},
		},
		-- 👇 if you use `open_for_directories=true`, this is recommended
		init = function()
			-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
			-- vim.g.loaded_netrw = 1
			-- vim.g.loaded_netrwPlugin = 1
		end,
	},
}
