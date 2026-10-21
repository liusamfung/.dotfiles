-- NOTA: en una subcarpeta de lua/plugins/ lazy.nvim SOLO carga init.lua (este archivo, que devuelve el spec).
-- Los demás archivos (setup.lua) no se ejecutan como specs: se cargan con require("plugins.jdtls.setup").
-- Una subcarpeta sin init.lua se ignora entera.
return {
	{
		-- java's language server is kind of complicated, so mfussenegger made a
		-- plugin to handle it.
		"mfussenegger/nvim-jdtls",
		ft = "java", -- loaded the first time a Java file is opened; mason-lspconfig does not start jdtls (see exclude)
		config = function()
			-- start_or_attach reuses the running server for the same root_dir, so every Java buffer just attaches.
			-- lazy.nvim re-fires FileType for the buffer that triggered the load, so that one is covered too.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("jdtls_attach", { clear = true }),
				pattern = "java",
				desc = "Start or attach nvim-jdtls",
				callback = function()
					require("plugins.jdtls.setup").setup()
				end,
			})
		end,
	},
}
