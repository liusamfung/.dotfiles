-- Tipos de archivo propios. Van aquí y no en un plugin porque son de Neovim y deben estar activos desde el
-- arranque: sf.nvim registra varios de estos tipos, pero solo cuando se carga (VeryLazy), y un `nvim Foo.cls`
-- detecta el archivo antes de eso.
vim.filetype.add({
	extension = {
		-- Salesforce
		cls = "apex",
		trigger = "apex",
		apex = "apex",
		soql = "soql",
		sosl = "sosl",
		-- Visualforce / Aura markup (nvim detects .page as "mallard" and ignores the rest)
		page = "html",
		component = "html",
		cmp = "html",
		app = "html",
		evt = "html",
		intf = "html",

		-- Otros
		["code-workspace"] = "jsonc", -- jsonc porque VS Code permite comentarios en estos archivos
		xsl = "xsl",
		xslt = "xslt",
		kbd = "kanata",
		["kitty-session"] = "conf",
	},
	filename = {
		[".forceignore"] = "gitignore", -- Salesforce
	},
})
