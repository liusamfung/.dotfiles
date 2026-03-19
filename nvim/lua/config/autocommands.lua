--UTILITYS
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- --If you wanna view relotivenumber in 'terminalmode'
-- vim.api.nvim_create_autocmd('termopen', {
--   callback = function()
--     vim.opt_local.relativenumber = true
--     vim.opt_local.wrap = false
--   end,
-- })
--

-- vim.api.nvim_create_autocmd("FileType", {
-- 	callback = function(ev)
-- 		local lang = vim.treesitter.language.get_lang(ev.match)
-- 		if lang then
-- 			vim.treesitter.start()
-- 		end
-- 	end,
-- })

-- Treesitter autocommands-----------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Enable treesitter highlighting and indentation (non-blocking)",
	callback = function(event)
		local ts = require("nvim-treesitter")
		-- Obtenemos el lenguaje real o el match del evento
		local lang = vim.treesitter.language.get_lang(event.match) or event.match

		-- Verificamos si el lenguaje es instalable (está disponible en los tiers de TS)
		-- 'get_available()' devuelve una lista de strings con los lenguajes soportados.
		local available_langs = ts.get_available()

		local is_supported = false
		for _, supported_lang in ipairs(available_langs) do
			if supported_lang == lang then
				is_supported = true
				break
			end
		end

		if is_supported then
			-- Intentamos instalar. Según tu doc, es un "no-op" si ya está instalado.
			ts.install({ lang })
		end
	end,
})

-- vim.api.nvim_create_autocmd("FileType", {
-- 	group = group,
-- 	desc = "Enable treesitter highlighting and indentation (non-blocking)",
-- 	callback = function(event)
-- 		local lang = vim.treesitter.language.get_lang(event.match) or event.match
-- 		-- Auto-install missing parsers (async, no-op if already installed)
-- 		local ts = require("nvim-treesitter") --Alias
-- 		ts.install({ lang })
-- 	end,
-- })
-- Treesitter autostart
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ts_auto_start", { clear = true }), -- augroup: Es buena práctica envolver tus autocomandos en grupos con { clear = true }. Si recargas tu configuración mientras Neovim está abierto, esto evita que el autocomando se duplique infinitamente en memoria.
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match)
		-- Solo intentamos iniciar si Neovim reconoce el lenguaje
		if lang then
			-- Usamos pcall (protected call) para que si algo falla,
			-- no nos llene la pantalla de errores rojos
			pcall(vim.treesitter.start, ev.buf, lang) -- pcall: Es una función de Lua que significa "llamada protegida". Si vim.treesitter.start() encuentra un problema (como con los buffers de snacks), en lugar de detener todo Neovim con un error, simplemente devuelve false y continúa silenciosamente.
		end
	end,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	group = vim.api.nvim_create_augroup("LspRefreshFix", { clear = true }),
-- 	callback = function()
-- 		-- Forzar a que el LSP piense que el contenido ha cambiado para que re-analice
-- 		vim.diagnostic.show() -- Asegura que la capa de visualización esté activa
-- 	end,
-- })

--Usa la identación de Java para  archivos Apex (Tresitter no proporciona
--identación ofical en us paquete de Apex)
-- run ":checkhealth nvim-treesitter" to see which lenguaje
--Installed languages    H L F I J ~
-- apex                  ✓ ✓ ✓ . ✓
-- java                  ✓ ✓ ✓ ✓ ✓
-- soql                  ✓ . . . .
-- sosl                  ✓ . . . .

--Usamos la identación de Java para archivos de tipo apex
vim.api.nvim_create_autocmd("FileType", {
	pattern = "apex",
	callback = function()
		vim.cmd("runtime! indent/java.vim") -- este motor activa identados de 4. y el prettierrc de salesforce marca 2
		-- Por eso debes descargarte este plugin  NMAC427/guess-indent.nvim para que adivine el identado en tiempo
		-- real y este sobre escriba tu configuración dependiendo del archivo
		-- por eso debemos usar otro método.

		-- Desactiva el motor de identado de Treesitter para este buffer.
		-- vim.bo.indentexpr = ""
		-- vim.opt.smartindent = true -- una opción "tonta" y mecánica. Es muy tonta
	end,
})
--Usamos la identación de sql para archivos soql
vim.api.nvim_create_autocmd("FileType", {
	-- pattern = { "soql", "sosl" },
	pattern = "soql",
	callback = function()
		vim.cmd("runtime! indent/sql.vim")
	end,
})

vim.filetype.add({
	pattern = {
		[".*/*.cls"] = "apex",
	},
})

vim.filetype.add({
	extension = {
		["code-workspace"] = "jsonc", -- jsonc porque VS Code permite comentarios en estos archivos
		cls = "apex",
		trigger = "apex",
		apex = "apex",
		soql = "soql", -- El plugin sf.nvim lo asigna por mi. Pero de todas formas lo hago aqui.
		sosl = "sosl", -- El plugin sf.nvim lo asigna por mi. Pero de todas formas lo hago aqui.
		xsl = "xsl",
		xslt = "xslt",
		kbd = "kanata",
	},
})
