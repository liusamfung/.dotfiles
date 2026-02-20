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
