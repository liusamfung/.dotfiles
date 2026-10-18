-- Smoke test for the Salesforce setup. Run by `scripts/bootstrap.sh check`:
--   cd <sfdx project> && nvim --headless -u <config>/init.lua -c "luafile nvim-smoke.lua"
-- Prints one "PASS|FAIL <what>" line per check and exits with the number of failures.
local fails = 0
local function check(name, ok, detail)
	print(("%s %s%s"):format(ok and "PASS" or "FAIL", name, detail and (" - " .. detail) or ""))
	if not ok then
		fails = fails + 1
	end
end

local function open(file)
	vim.cmd("silent edit " .. vim.fn.fnameescape(file))
	return vim.api.nvim_get_current_buf()
end

local function wait_for(cond, ms)
	return vim.wait(ms or 20000, cond, 200)
end

local function client_names(buf)
	return vim.tbl_map(function(c)
		return c.name
	end, vim.lsp.get_clients({ bufnr = buf }))
end

local cls = vim.env.SMOKE_CLS
local js = vim.env.SMOKE_JS

-- Apex ---------------------------------------------------------------------------------------------
local buf = open(cls)
check("filetype apex", vim.bo[buf].filetype == "apex", vim.bo[buf].filetype)
check("apex_ls attaches", wait_for(function()
	return vim.tbl_contains(client_names(buf), "apex_ls")
end, 40000), table.concat(client_names(buf), ","))
local conform = require("conform")
local fmts = vim.tbl_map(function(f)
	return f.name .. (f.available and "" or "(unavailable)")
end, conform.list_formatters(buf))
check("apex formatter", #fmts > 0 and not fmts[1]:find("unavailable"), table.concat(fmts, ","))

-- LWC ----------------------------------------------------------------------------------------------
buf = open(js)
check("filetype javascript", vim.bo[buf].filetype == "javascript")
check("lwc_ls attaches", wait_for(function()
	return vim.tbl_contains(client_names(buf), "lwc_ls")
end, 40000), table.concat(client_names(buf), ","))
check("eslint_d on PATH", vim.fn.executable("eslint_d") == 1)

-- Treesitter parsers (installed asynchronously on first start: give them time) -------------------------
for _, lang in ipairs({ "apex", "soql", "sosl", "sflog", "html", "javascript", "xml" }) do
	local ok = wait_for(function()
		return pcall(vim.treesitter.language.add, lang)
	end, 120000)
	check("parser " .. lang, ok)
end

-- Plugin side ----------------------------------------------------------------------------------------
check(":SF command", vim.fn.exists(":SF") == 2)
check("<leader>tp mapped", vim.fn.maparg("<leader>tp", "n") ~= "")
check("filetype .page", vim.filetype.match({ filename = "x.page" }) == "html")

vim.cmd("cquit " .. fails)
