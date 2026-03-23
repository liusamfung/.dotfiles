return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "v0.2.0",
		dependencies = { "nvim-lua/plenary.nvim" },
		--Another way to config telescope
		-- config = function()
		--   local builtin = require('telescope.builtin')
		--   vim.keymap.set( "n", "<leader>ff", builtin.find_files, { desc = "Find files" })
		--
		-- end
		keys = {
			-- { mode = "n", "<leader>ff", function() require("telescope.builtin").find_files() end, {""}, },
			-- { mode = "n", "<leader>fp", function() require("telescope.builtin").git_files() end, {}, },
			-- { mode = "n", "<leader>/", function() require("telescope.builtin").live_grep() end, {}, },
			-- { mode = "n", "<leader>fh", function() require("telescope.builtin").help_tags() end, {}, },
			{
				"<leader>fx",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "ManPages",
			},
			-- -- { "<leader>/", LazyVimpick("live_grep"), desc = "Grep (Root Dir)" },
			-- { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			-- -- { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
			-- -- find
			-- {
			--   "<leader>,",
			--   "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
			--   desc = "Find buffers",
			-- },
			-- { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
			-- { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			-- -- git
			-- { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
			-- { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
			-- { "<leader>gS", "<cmd>Telescope git_stash<cr>", desc = "Git Stash" },
			-- -- search
			-- -- { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
			-- { "<leader>s/", "<cmd>Telescope search_history<cr>", desc = "Search History" },
			-- { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
			-- { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer Lines" },
			-- { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			-- { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
			-- { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
			-- { "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Buffer Diagnostics" },
			-- -- { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
			-- -- { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
			-- { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
			-- { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
			-- { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
			-- { "<leader>sk", "<cmd>Telescope keymaps<cru", desc = "Key Maps" },
			-- { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
			-- { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
			-- { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
			-- { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
			-- { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
			-- { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
		},
	},
}
