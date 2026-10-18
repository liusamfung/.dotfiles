-- Runs LSP "source" code actions (organize imports, eslint --fix) synchronously, right before a save.
-- Called from conform's format_on_save (see plugins/conform.lua) so the order is always:
--   organize imports -> eslint fixes -> prettier.
local M = {}

-- Code action kinds to request, per LSP client name. Clients not listed here are skipped.
M.kinds = {
	-- ts_ls: "organizeImports" only sorts and merges; deleting unused imports is a separate kind.
	ts_ls = { "source.removeUnusedImports", "source.organizeImports" },
	denols = { "source.organizeImports" },
	eslint = { "source.fixAll.eslint" },
}

local TIMEOUT_MS = 1500

---@param bufnr integer
---@param client vim.lsp.Client
---@param kind string
local function apply(bufnr, client, kind)
	local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
	params.context = { only = { kind }, diagnostics = {} }

	local res = client:request_sync("textDocument/codeAction", params, TIMEOUT_MS, bufnr)
	if not res or res.err or not res.result then
		return
	end

	for _, action in ipairs(res.result) do
		-- Some servers answer with a bare action and fill its edit on demand.
		if not action.edit and client:supports_method("codeAction/resolve") then
			local resolved = client:request_sync("codeAction/resolve", action, TIMEOUT_MS, bufnr)
			action = (resolved and resolved.result) or action
		end
		if action.edit then
			vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
		end
		-- No command is executed: the actions above return their changes as an edit.
	end
end

---@param bufnr integer
function M.run(bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		for _, kind in ipairs(M.kinds[client.name] or {}) do
			-- A failing server must never block the save.
			pcall(apply, bufnr, client, kind)
		end
	end
end

return M
