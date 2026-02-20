return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },

				java = { "google-java-format" },
				kotlin = { "ktfmt" },

				-- Web development
				javascript = { "prettierd" },
				javascriptreact = { "prettierd" }, -- Para archivos .jsx (React)
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" }, -- Para archivos .tsx (React con TypeScript
				html = { "prettierd" },
				css = { "prettierd" },
				scss = { "prettierd" },
				less = { "prettierd" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
			},
			format_on_save = {
				lsp_format = "never", -- Si no encuentro un formateador configurado para este tipo de archivo en Conform, intenta usar el motor de formateo del propio LSP".
				timeout_ms = 500, -- tiempo máximo (en milisegundos) que Neovim esperará a que el formateador externo (como stylua o google-java-format) termine su trabajo antes de cancelar la operación.
			},
		},
	},
}
