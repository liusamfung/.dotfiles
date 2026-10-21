--UTILITYS
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.filetype.add({
	extension = {
		["code-workspace"] = "jsonc", -- jsonc porque VS Code permite comentarios en estos archivos
		cls = "apex",
		trigger = "apex",
		apex = "apex",
		soql = "soql", -- El plugin sf.nvim lo asigna por mi. Pero de todas formas lo hago aqui.
		sosl = "sosl", -- El plugin sf.nvim lo asigna por mi. Pero de todas formas lo hago aqui.
		-- Visualforce / Aura markup (nvim detects .page as "mallard" and ignores the rest)
		page = "html",
		component = "html",
		cmp = "html",
		app = "html",
		evt = "html",
		intf = "html",
		xsl = "xsl",
		xslt = "xslt",
		kbd = "kanata",
		["kitty-session"] = "conf",
	},
	filename = {
		[".forceignore"] = "gitignore",
	},
})
