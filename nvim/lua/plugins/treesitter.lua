return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter") --Alias
			ts.install({
				-- Salesforce
				-- sf.nvim requires these four (`:checkhealth sf`)
				"apex",
				"soql",
				"sosl",
				"sflog",

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
			vim.api.nvim_create_autocmd("FileType", {
				-- augroup con clear = true: al recargar la config no se duplica el autocomando
				group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
				desc = "Instala el parser si falta, arranca Treesitter y usa su identado",
				callback = function(event)
					local lang = vim.treesitter.language.get_lang(event.match)

					-- 1. Auto-instalar: si hay un parser disponible para este lenguaje, ts.install es un no-op cuando ya está
					if vim.list_contains(ts.get_available(), lang or event.match) then
						ts.install({ lang or event.match })
					end

					-- 2. Arrancar solo si Neovim reconoce el lenguaje. pcall: buffers raros (los de snacks) no deben dar errores
					if lang and pcall(vim.treesitter.start, event.buf, lang) then
						vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end

					-- 3. Apex no trae query de identado en nvim-treesitter (:checkhealth nvim-treesitter): se usa el script de Java.
					-- Va DESPUÉS del paso 2 para que gane el de Java. did_indent: el script se salta si ya está definido.
					-- (SOQL no lleva nada: el identado de SQL, el de Treesitter y ninguno dan exactamente el mismo resultado.)
					if event.match == "apex" then
						vim.api.nvim_buf_call(event.buf, function()
							vim.b.did_indent = nil
							vim.cmd("runtime! indent/java.vim")
						end)
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
