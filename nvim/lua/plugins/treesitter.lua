return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile", "VeryLazy" },
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter") --Alias
			ts.install({
				-- Salesforce
				-- "sflog",
				"apex",
				-- "soql",
				-- "sosl",

				"regex", -- Optional for Snacks.picker.
				--ensure install (Anyways, we have Autoinstall)
				-- "lua",
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

	{
		-- "jugarpeupv/nvim-treesitter-context",
		"nvim-treesitter/nvim-treesitter-context",
		enabled = true,
		lazy = true,
		ft = { "json", "jsonc", "yaml", "yml", "yaml.github", "javascript", "typescript", "lua" },
		config = function()
			require("treesitter-context").setup({
				on_attach = function(buf)
					local filetype = vim.fn.getbufvar(buf, "&ft")
					if filetype == "markdown" then
						return false
					end
					return true
				end, -- (fun(buf: integer): boolean) return false to disable attaching
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				multiwindow = true, -- Enable multiple floating windows
				max_lines = 6, -- How many lines the window should span. Values <= 0 mean no limit.
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				zindex = 20, -- The Z-index of the context window
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- separator = nil,
				separator = "",
			})
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		opts = {},
	},
}
