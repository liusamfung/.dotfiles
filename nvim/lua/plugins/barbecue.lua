return {
	{
		"utilyre/barbecue.nvim",
		event = { "BufReadPost", "BufNewFile" },
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			-- attach_navic = true, --Don't show in where I am. I use treesitter-contex.nvim
			show_navic = false,
			show_modified = true,
			-- Funcion para que aparezcan los los diagnostic en la barra superior derecha
			-- lead_custom_section = function(bufnr, _)
			-- 	local icons = {
			-- 		Error = "",
			-- 		Warn = "",
			-- 		Info = "",
			-- 		Hint = "󰠠",
			-- 	}
			--
			-- 	local label = {}
			-- 	for severity, icon in pairs(icons) do
			-- 		local n = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity[string.upper(severity)] })
			-- 		if n > 0 then
			-- 			table.insert(label, { icon .. " " .. n .. " ", "DiagnosticSign" .. severity })
			-- 		end
			-- 	end
			-- 	return label
			-- end,
			exclude_filetypes = {
				"netrw",
				"toggleterm",
				"NvimTree",
				"Diff",
				"help",
				"dashboard",
				"fugitive",
				"diffview",
				" ",
				"",
				"startify",
				"dashboard",
				"packer",
				"neogitstatus",
				"Trouble",
				"alpha",
				"lir",
				"toggleterm",
			},
			show_dirname = true,
			show_basename = true,
			symbols = {
				modified = "⏺",
			},
			theme = {
				normal = { fg = "#c0caf5" },
				ellipsis = { fg = "#737aa2" },
				separator = { fg = "#737aa2" },
				modified = { fg = "#C2C2C2" }, -- Casi blance
				dirname = { fg = "#737aa2" },
				basename = { bold = false },
				context = { fg = "#737aa2" },
			},
		},
	},
}
