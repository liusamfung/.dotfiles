return {
	-- "nvim-tree/nvim-web-devicons", -- optional dependency snacks usa este plugin como dependencia para los iconos
	{
		"folke/snacks.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = false },
			dashboard = { enabled = true },
			explorer = { enabled = false },
			indent = { enabled = false }, -- Line the scopes
			input = { enabled = false },
			notifier = { enabled = true }, -- Windows corner top-right notifications `vim.notify`
			quickfile = { enabled = true }, -- When doing nvim somefile.txt, it will render the file as quickly as possible, before loading your plugins.
			scope = { enabled = false }, --TODO:
			scroll = { enabled = false },
			statuscolumn = { enabled = false }, -- TODO:
			words = { enabled = false },

			picker = {
				enabled = true,
				opts = {
					hidden = false,
				},
			},
		},
	},
}
