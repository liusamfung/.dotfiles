return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
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

				-- folke/snacks dependecies (review :checkheath snacks)
				"latex",
				-- "norg", -- don't work
				"svelte",
				"typst",
				"vue",
			})
			-- Autocomando para iniciar el identado de treesittter si encuentra un archivo
			-- 	disponible con identado. En caso de que no, no hace nada
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local ft = vim.bo.filetype

					-- Si no hay filetype, no hacemos nada
					if not ft or ft == "" then
						return
					end

					-- Verificamos si existe un parser para el filetype actual
					-- Nota: get_lang devuelve el nombre del lenguaje si existe el parser
					local has_parser, _ = pcall(vim.treesitter.language.get_lang, ft)

					if has_parser and vim.treesitter.language.get_lang(ft) then
						-- Intentamos iniciar Treesitter de forma segura
						local ok, err = pcall(vim.treesitter.start)

						if ok then
							-- Si inició correctamente, aplicamos las configuraciones
							vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
							-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
							-- vim.wo.foldmethod = "expr"
						end
					end
				end,
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
				multiwindow = false, -- Enable multiple floating windows
				-- max_lines = 6, -- How many lines the window should span. Values <= 0 mean no limit.
				max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				zindex = 20, -- The Z-index of the context window
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				separator = nil,
				-- separator = "",
			})
		end,
	},

	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},

	{
		"hiphish/rainbow-delimiters.nvim",
		event = { "BufReadPost", "BufNewFile" },
	},
}
