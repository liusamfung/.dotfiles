return {
	--TODO: investigar que como usar este plugin.
	{
		"tpope/vim-fugitive",
		cmd = {
			"Git",
			"G",
			"Gdiffsplit",
			"Gvdiffsplit",
			"Ghdiffsplit",
			"Gclog",
			"Gllog",
			"Gread",
			"Gwrite",
			"Ggrep",
			"GMove",
			"GDelete",
			"GBrowse",
		},
		-- :Git blame -w to show "What did I do here?? in commits"
	},
}
