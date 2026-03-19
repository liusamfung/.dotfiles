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
		ft = { "apex", "cls", "trigger", "visualforce", "soql", "javascript" },
		--  O solo cuando escribas un comando que empiece por 'Sf'
		-- cmd = "SF",
		-- event = "VeryLazy",

		lazy = false,

		-- 2. Le damos un valor de prioridad alto (el valor por defecto es 50)
		priority = 1000,

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
				term_config = {
					blend = 10, -- background transparency: 0 is fully opaque; 100 is fully transparent
					dimensions = {
						height = 0.9, -- proportional of the editor height. 0.4 means 40%.
						width = 0.9, -- proportional of the editor width. 0.8 means 80%.
						x = 0.5, -- starting position of width. Details in `get_dimension()` in raw_term.lua source code.
						y = 0.9, -- starting position of height. Details in `get_dimension()` in raw_term.lua source code.
					},
				},
			})
			local Sf = require("sf")
			vim.keymap.set("n", "<leader>ts", Sf.toggle_term, { desc = "set local" })
			vim.keymap.set("n", "<leader>td", Sf.diff_in_target_org, { desc = "Diff in target org" })
			vim.keymap.set("n", "<leader>tD", Sf.diff_in_org, { desc = "Dif in org..." })
			vim.keymap.set("n", "<leader>tcl", ":SF create lwc<cr>", { desc = "Create LWC" })
			vim.keymap.set("n", "<leader>tct", ":SF create trigger<cr>", { desc = "Create trigger" })
			vim.keymap.set("n", "<leader>tca", ":SF create apex<cr>", { desc = "Create Apex" })
			vim.keymap.set("n", "<leader>tcc", ":SF create ctags<cr>", { desc = "Create ctags" })

			vim.keymap.set(
				"n",
				"<leader>tR",
				Sf.rename_apex_class_remote_and_local,
				{ desc = "Rename apex remote y local" }
			)
			-- nmap("<leader>sR", Sf., "rename current apex from org and local")
			vim.keymap.set(
				"n",
				"<leader>tX",
				Sf.delete_current_apex_remote_and_local,
				{ desc = "Delete remote y local" }
			)

			vim.keymap.set("n", "<C-/>", ":SF term toggle<cr>", { desc = "Create ctags and List" })

			vim.keymap.set("n", "<leader>tp", ":SF currentFile push<cr>", { desc = "Create ctags and List" })
			vim.keymap.set("n", "<leader>tr", ":SF currentFile retrieve<cr>", { desc = "Create ctags and List" })

			vim.keymap.set("n", "<leader>tot", ":SF org setTarget<cr>", { desc = "Select Org Target" })
			vim.keymap.set("n", "<leader>tog", ":SF org setGlobalTarget<cr>", { desc = "Select GlobalOrg Target" })

			vim.keymap.set(
				"n",
				"<leader>tta",
				Sf.run_all_tests_in_this_file,
				{ desc = "run all Apex tests in current file" }
			)
			vim.keymap.set(
				"n",
				"<leader>ttA",
				Sf.run_all_tests_in_this_file_with_coverage,
				{ desc = "Test all with coverage info" }
			)

			vim.keymap.set("n", "<leader>ttc", Sf.run_current_test, { desc = "run Apex tests in under cursor " })
			vim.keymap.set(
				"n",
				"<leader>ttC",
				Sf.run_current_test_with_coverage,
				{ desc = "run  tests in under cursor with coverage" }
			)
			vim.keymap.set("n", "<leader>tts", Sf.open_test_select, { desc = "Select Apex tests current File " })
			vim.keymap.set("n", "<leader>ttl", Sf.repeat_last_tests, { desc = "Repeat the last test" })
			vim.keymap.set("n", "<leader>t/", Sf.toggle_sign, { desc = "Toggel signs for code coverage" })

			-- nmap("\\s", Sf.toggle_sign, "toggle signs for code coverage")

			vim.keymap.set("n", "<leader>tqc", Sf.run_highlighted_soql, { desc = "run_highlighted_soql unde cursor" })

			vim.keymap.set("v", "<leader>tar", function()
				Sf.run_anonymous_stdin(true)
			end, { buffer = true, desc = "run selected content anonymously" })

			vim.keymap.set("n", "<leader>tar", function()
				Sf.run_anonymous_stdin(false)
			end, { desc = "run this buffer anonymously" })
			vim.keymap.set("n", "<leader>taR", Sf.run_anonymous, { desc = "run this buffer anonymously" })

			-- nmap("<leader>sa", function()
			-- 	Sf.run_anonymous_stdin(false)
			-- end, "run this buffer anonymously")
			-- nmap("<leader>sA", Sf.run_anonymous, "run this file anonymously")
		end,
	},
}
