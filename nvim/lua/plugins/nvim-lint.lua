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

			-- Compilation diagnostics from the org: validates (dry-run) ONLY the current file against the
			-- target org, without running tests and without saving anything in the org.
			-- Manual (<leader>tv, see salesforce.lua): the previous version ran a dry-run deploy of the whole
			-- project, tests included, on every save.
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
					"--test-level",
					"NoTestRun",
					"--source-dir",
					function()
						return vim.api.nvim_buf_get_name(0)
					end,
				},
				stream = "stdout",
				ignore_exitcode = true,
				parser = function(output, bufnr)
					-- <leader>tv reads this to tell "validated" from "the CLI failed" (see sf_status.lua)
					local status = require("config.sf_status")
					local ok, decoded = pcall(vim.json.decode, output)
					if not ok or type(decoded) ~= "table" then
						status.compile_result = { error = "sf returned no JSON" }
						return {}
					end

					local failures = vim.tbl_get(decoded, "result", "details", "componentFailures")
					if type(failures) ~= "table" then
						if decoded.status == 0 then
							status.compile_result = { ok = true, failures = 0 }
						else
							status.compile_result = { error = decoded.message or "validation failed" }
						end
						return {}
					end
					-- The CLI returns a single object, not a list, when there is only one failure.
					if failures.fileName then
						failures = { failures }
					end
					status.compile_result = { ok = false, failures = #failures }

					local fname = vim.api.nvim_buf_get_name(bufnr)
					local diagnostics = {}
					for _, fail in ipairs(failures) do
						-- plain find: file names contain "-" and "." that are pattern characters
						if fail.fileName and fname:find(fail.fileName, 1, true) then
							local lnum = (tonumber(fail.lineNumber) or 1) - 1
							local col = (tonumber(fail.columnNumber) or 1) - 1
							table.insert(diagnostics, {
								source = "SF-Compiler",
								lnum = lnum,
								col = col,
								end_lnum = lnum,
								end_col = col + 1,
								severity = vim.diagnostic.severity.ERROR,
								message = fail.problem,
							})
						end
					end
					return diagnostics
				end,
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
				group = lint_augroup,
				callback = function()
					-- ignore_errors: on a fresh machine Mason may still be installing eslint_d; without
					-- this, BufEnter raised "Error running eslint_d: ENOENT" and aborted `:edit`.
					lint.try_lint(nil, { ignore_errors = true })
				end,
			})
		end,
	},
}
