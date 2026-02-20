return {
	-- {
	-- 	"jonathanmorris180/salesforce.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 	},
	-- },

	{
		"xixiaofinland/sf.nvim",
		-- No cargar al inicio, solo cuando abras estos archivos
		ft = { "apex", "cls", "trigger", "visualforce", "soql" },
		--  O solo cuando escribas un comando que empiece por 'Sf'
		cmd = "SF",

		-- ESTE ES EL FILTRO DE SEGURIDAD:
		cond = function()
			-- Solo se carga si existe el archivo maestro de Salesforce en la raíz
			return vim.fn.filereadable(vim.fn.getcwd() .. "/sfdx-project.json") == 1
		end,

		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"ibhagwan/fzf-lua", -- no need if you don't use listing metadata feature
		},

		config = function()
			require("sf").setup({
				-- executable = "sf",
			})
			local Sf = require("sf")
			vim.keymap.set("n", "<leader>ts", Sf.toggle_term, { desc = "set local" })
			vim.keymap.set("n", "<leader>td", Sf.diff_in_target_org, { desc = "Diff in target org" })
			vim.keymap.set("n", "<leader>tD", Sf.diff_in_org, { desc = "Dif in org..." })
			vim.keymap.set("n", "<leader>tcl", ":SF create lwc<cr>", { desc = "Create LWC" })
			vim.keymap.set("n", "<leader>tct", ":SF create trigger<cr>", { desc = "Create trigger" })
			vim.keymap.set("n", "<leader>tca", ":SF create apex<cr>", { desc = "Create Apex" })
			vim.keymap.set("n", "<leader>tcc", ":SF create ctags<cr>", { desc = "Create ctags" })
			vim.keymap.set("n", "<leader>tcC", ":SF create ctagsAndList<cr>", { desc = "Create ctags and List" })

			vim.keymap.set("n", "<leader>tb", Sf.run_anonymous_stdin(false), { desc = "run this buffer anonymously" })
		end,
	},
}
