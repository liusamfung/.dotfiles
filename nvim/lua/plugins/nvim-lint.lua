return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile", "InsertLeave" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
			}

			-- Diagnóstico asíncrono con la CLI de Salesforce
			lint.linters.sf_compile = {
				cmd = "sf",
				stdin = false,
				append_fname = false,
				args = {
					"project",
					"deploy",
					"start",
					"--dry-run",
					"--json",
					"--ignore-conflicts",
				},
				stream = "stdout",
				ignore_exitcode = true,
				parser = function(output, bufnr)
					local decoded = vim.fn.json_decode(output)
					local diagnostics = {}

					if
						decoded
						and decoded.result
						and decoded.result.details
						and decoded.result.details.componentFailures
					then
						local failures = decoded.result.details.componentFailures
						if type(failures) ~= "table" then
							failures = { failures }
						end

						for _, fail in ipairs(failures) do
							local fname = vim.api.nvim_buf_get_name(bufnr)
							if string.find(fname, fail.fileName) then
								table.insert(diagnostics, {
									source = "SF-Compiler",
									lnum = tonumber(fail.lineNumber) - 1,
									col = tonumber(fail.columnNumber) or 0,
									end_lnum = tonumber(fail.lineNumber) - 1,
									end_col = (tonumber(fail.columnNumber) or 0) + 1,
									severity = vim.diagnostic.severity.ERROR,
									message = fail.problem,
								})
							end
						end
					end
					return diagnostics
				end,
			}

			-- Creamos el grupo de autocomandos primero para usarlo en ambos bloques
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			-- MODIFICACIÓN PRINCIPAL: Filtro de seguridad para la ejecución de sf_compile
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				group = lint_augroup,
				callback = function()
					-- 1. Validar que el ejecutable 'sf' exista en el sistema externo
					local binario_existe = vim.fn.executable("sf") == 1
					-- 2. Validar que estemos operando dentro de la raíz de un proyecto de Salesforce
					local es_proyecto_sf = vim.fn.filereadable(vim.fn.getcwd() .. "/sfdx-project.json") == 1

					if binario_existe and es_proyecto_sf then
						-- 3. Filtrar por tipos de archivos relevantes para evitar ejecuciones en archivos de configuración (.lua)
						local ft = vim.bo.filetype
						local fts_validos = {
							apex = true,
							cls = true,
							trigger = true,
							soql = true,
							javascript = true,
							html = true,
						}

						if fts_validos[ft] then
							require("lint").try_lint("sf_compile")
						end
					end
				end,
			})

			-- Autocomando general para linters estándar (eslint_d, etc.)
			vim.api.nvim_create_autocmd({
				"BufEnter",
				"BufWritePost",
				"InsertLeave",
				"TextChanged",
			}, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
