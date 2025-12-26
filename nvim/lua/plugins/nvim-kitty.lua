return {
	{
		"mikesmithgh/kitty-scrollback.nvim",
		enabled = true,
		lazy = true,
		cmd = {
			"KittyScrollbackGenerateKittens",
			"KittyScrollbackCheckHealth",
			"KittyScrollbackGenerateCommandLineEditing",
		},
		event = { "User KittyScrollbackLaunch" },
		-- version = '*', -- latest stable version, may have breaking changes if major version changed
		-- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
		config = function()
			require("kitty-scrollback").setup()
		end,
	},

	{
		"knubie/vim-kitty-navigator",
		build = "cp ./*.py ~/.config/kitty/",
		-- Yo no uso el teclado QWERTY, uso dvrk. Por ello me es mas comodo rempearlo
		-- de esta forma para que todo los motions esten en una sola mano.bb
		-- Si tú usas QWERTY, qudate con la configuración por defecto.
		init = function()
			-- Deshabilita los keymaps por defecto del plugin (Vimscript: let g:kitty_navigator_no_mappings = 1)
			vim.g.kitty_navigator_no_mappings = 1
		end,
		-- Función `config`: Se ejecuta después de que el plugin se ha cargado.
		-- Aquí definimos nuestros keymaps personalizados de forma directa.
		config = function()
			local map = vim.keymap.set
			local opts = { silent = true, remap = false }
			-- if you don't want to see the pop-up for a micro while. Don't use ":KittyNavigate...<CR>"
			-- Instead of use "<cmd>KittyNavigate...<CR>"
			-- Aditionality. If you want to type inmdiality when you switch in panes. You can do it like that line below
			-- map('n', '<C-q>', '<cmd>KittyNavigateLeft<CR><cmd>startinsert<CR>', { desc = 'Kitty: Mover Izquierda' })
			map("n", "<C-q>", "<cmd>KittyNavigateLeft<CR><cmd>startinsert<CR>", { desc = "Kitty: Mover Izquierda" })
			map("n", "<C-j>", "<cmd>KittyNavigateDown<CR><cmd>startinsert<CR>", { desc = "Kitty: Mover Abajo" })
			map("n", "<C-k>", "<cmd>KittyNavigateUp<CR><cmd>startinsert<CR>", { desc = "Kitty: Mover Arriba" })
			map("n", "<C-x>", "<cmd>KittyNavigateRight<CR><cmd>startinsert<CR>", { desc = "Kitty: Mover Derecha" })
		end,
	},
}
