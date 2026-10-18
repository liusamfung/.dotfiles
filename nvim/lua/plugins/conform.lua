return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ lsp_format = "never", timeout_ms = 3000 })
				end,
				desc = "[C]ode [F]ormat buffer",
				mode = { "n", "x" },
			},
		},
		opts = {
			formatters_by_ft = {
				--Salesforce
				apex = { "prettier" },

				lua = { "stylua" },

				java = { "google-java-format" },
				kotlin = { "ktfmt" },

				-- Web development
				javascript = { "prettier" },
				javascriptreact = { "prettier" }, -- Para archivos .jsx (React)
				typescript = { "prettier" },
				typescriptreact = { "prettier" }, -- Para archivos .tsx (React con TypeScript
				html = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },

				-- Extra
				xml = { "prettier", "xmlformatter", stop_after_first = true },
				markdown = { "prettier" },

				-- Supabase migrations (manual only, see format_on_save)
				sql = { "sql_formatter" },
			},
			formatters = {
				sql_formatter = { prepend_args = { "--language", "postgresql", "--config", '{"keywordCase":"lower"}' } },
			},
			-- A function (not a table) so the LSP code actions (organize imports, eslint fixes) run first.
			format_on_save = function(bufnr)
				-- Migrations are hand-written and reviewed: never rewrite them on save (format by hand with <leader>cf).
				if vim.bo[bufnr].filetype == "sql" then
					return nil
				end
				require("config.code_actions").run(bufnr)
				return {
					lsp_format = "never", -- Si no encuentro un formateador configurado para este tipo de archivo en Conform, no quiero que use  el motor de formateo del propio LSP (No es tan bueno muchas veces).
					timeout_ms = 3000, -- tiempo máximo (en milisegundos) que Neovim esperará a que el formateador externo (como stylua o google-java-format) termine su trabajo antes de cancelar la operación.
				}
			end,
		},
	},
}
