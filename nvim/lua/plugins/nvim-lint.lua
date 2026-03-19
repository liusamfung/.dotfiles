return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile", "InsertLeave" }, -- Nota: el campo es 'event' (singular)
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				-- ["*"] = { "cspell" }, -- Ya tengo el cspell_ls. Es mejor y mas completo

				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				-- apex = { "pmd" },
			}
			-- lint.linters.pmd = {
			-- 	cmd = "pmd",
			-- 	stdin = false,
			-- 	append_fname = true,
			-- 	args = {
			-- 		"check",
			-- 		"-f",
			-- 		"text", -- Formato simple: archivo:linea:mensaje
			-- 		"-R",
			-- 		"apex-ruleset.xml",
			-- 		"-d",
			-- 	},
			-- 	ignore_exitcode = true, -- PMD sale con 4 si hay errores, esto lo ignora
			-- 	stream = "stdout",
			-- 	parser = function(output)
			-- 		local diagnostics = {}
			-- 		-- PMD en formato 'text' entrega: /ruta/archivo.cls:linea:mensaje
			-- 		for line in output:gmatch("[^\r\n]+") do
			-- 			local file, lnum, message = line:match("([^:]+):(%d+):%s*(.+)")
			-- 			if file and lnum and message then
			-- 				table.insert(diagnostics, {
			-- 					lnum = tonumber(lnum) - 1,
			-- 					col = 0,
			-- 					message = message,
			-- 					severity = vim.diagnostic.severity.WARN,
			-- 					source = "pmd",
			-- 				})
			-- 			end
			-- 		end
			-- 		return diagnostics
			-- 	end,
			-- }

			-- Autocomando para ejecutar el linting
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({
				"BufEnter",
				"BufWritePost",
				"InsertLeave",
				"TextChanged", -- Se activa cuando el texto cambia en el modo Normal (por ejemplo, si borras una línea con dd o una palabra con dw).
				-- "TextChangedI", -- Se activa cuando el texto cambia mientras estás en el modo Insertar (por ejemplo, al usar la tecla de retroceso para borrar el error).
			}, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
