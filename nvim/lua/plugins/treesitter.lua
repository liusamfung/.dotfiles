return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile", "VeryLazy" },
		build = ":TSUpdate",
		config = function()
			ts = require("nvim-treesitter") --Alias
			ts.install({
				--ensure install (Anyways, we have Autoinstall)
				"lua",
				"c",
				"cpp",
				"java",

				--Web
				"javascript",
				"html",
				"css",

				--Python
				"python",
			})
		end,
	},
}
