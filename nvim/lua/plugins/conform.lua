return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
			},
			format_on_save = {
				lsp_format = "fallback", -- Si no encuentro un formateador configurado para este tipo de archivo en Conform, intenta usar el motor de formateo del propio LSP".
				timeout_ms = 500, -- tiempo máximo (en milisegundos) que Neovim esperará a que el formateador externo (como stylua o google-java-format) termine su trabajo antes de cancelar la operación.
			},
		},
	},
}
