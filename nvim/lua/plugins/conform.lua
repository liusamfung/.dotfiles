return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
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
			},
			format_on_save = {
				lsp_format = "never", -- Si no encuentro un formateador configurado para este tipo de archivo en Conform, no quiero que use  el motor de formateo del propio LSP (No es tan bueno muchas veces).
				timeout_ms = 500, -- tiempo máximo (en milisegundos) que Neovim esperará a que el formateador externo (como stylua o google-java-format) termine su trabajo antes de cancelar la operación.
			},
		},
	},
}
