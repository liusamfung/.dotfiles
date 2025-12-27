local function enable_transparency()
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
end
-- If any colorscheme plugin don't have transparancy as Option(Built-in)
-- Just call this fuction in `funcion()end` block

-- enable_transparency()

return {
	-- {
	-- 	-- Shortend Github urlr
	-- 	"craftzdog/solarized-osaka.nvim",
	-- 	lazy = false,
	-- 	priority = 1000, --Load first first first
	-- 	config = function()
	-- 		require("solarized-osaka").setup({
	-- 			transparent = true,
	-- 			styles = {
	-- 				comments = { italic = true }, -- Enable italics in comments
	-- 				functions = { italic = true, bold = true },
	-- 				keywords = { bold = true }, -- Anotaciones, palabras reservadas, etc
	-- 			},
	-- 		})
	-- 		--     -- Load the colorscheme here.
	-- 		--     -- Like many other themes, this one has different styles, and you could load
	-- 		--     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
	-- 		--     vim.cmd.colorscheme 'tokyonight-night'
	-- 		vim.cmd.colorscheme("solarized-osaka")
	-- 	end,
	-- },

	{
		"cpea2506/one_monokai.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("one_monokai").setup({
				transparent = true,
				colors = {},
				highlights = function(colors)
					return {}
				end,
				italics = true,
			})
			vim.cmd.colorscheme("one_monokai")
		end,
	},
	--
	-- {
	-- 	"EdenEast/nightfox.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("nightfox").setup({
	-- 			options = {
	-- 				styles = {
	-- 					comments = "italic",
	-- 					keywords = "bold",
	-- 					-- types = 'italic,bold',
	-- 				},
	-- 			},
	-- 		})
	-- 		vim.cmd("colorscheme duskfox")
	-- 		enable_transparency()
	-- 	end,
	-- },

	-- {
	-- 	"Ronxvier/ymir.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd("colorscheme ymir")
	--
	-- 		enable_transparency()
	-- 	end,
	-- },

	-- {
	-- 	--Shorted Github url
	-- 	"Mofiqul/dracula.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd.colorscheme("dracula")
	-- 		enable_transparency()
	-- 	end,
	-- 	--De Aqui unicamente me gusta el color del los comentarios
	-- },
}
