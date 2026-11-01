return {
	{
		"XXiaoA/atone.nvim",
		cmd = "Atone",
		-- Under <leader>u with the other toggles (<leader>uw wrap, <leader>uS spelling...).
		-- Inside the tree the plugin has its own keys (press ? there): <CR> go to that state, gd floating diff, q quit.
		-- <leader>su (snacks.lua) is a searchable list of the same history; this is the tree.
		keys = {
			{ "<leader>uu", "<cmd>Atone toggle<cr>", desc = "Undo tree: toggle (Atone)" },
			{ "<leader>uf", "<cmd>Atone focus<cr>", desc = "Undo tree: focus its window" },
		},
		---@module "atone"
		---@type AtoneConfig
		opts = {},
	},
}
