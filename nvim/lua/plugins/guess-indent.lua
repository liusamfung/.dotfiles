return {
	-- Why this plugin? Well, you've as standar 2 spaces like tab or indent space.
	-- But not every file must to be 2 spaces. Sometimes, you have to use  4 space
	-- And you don't want to create a .editorconfig every time. So this is a simple
	-- and quickly solution.
	{
		-- Really good.
		"NMAC427/guess-indent.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},
}
