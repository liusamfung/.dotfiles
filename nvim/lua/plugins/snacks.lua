return {
	-- "nvim-tree/nvim-web-devicons", -- optional dependency snacks usa este plugin como dependencia para los iconos
	{
		"folke/snacks.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			animate = {}, -- TODO: QUE HACE?
			scroll = {
				animate = {
					duration = { step = 20, total = 100 },
					easing = "linear",
				},
			},
			bigfile = { enabled = true },
			explorer = {
				enabled = true,
				keys = {
					["<C-q>"] = false,
				},
			},
			indent = { enabled = true }, -- Line the scopes
			input = { enabled = false }, -- Light version of 'folke/noice'. Don't need it
			notifier = { enabled = true }, -- Windows corner top-right notifications `vim.notify`
			quickfile = { enabled = true }, -- When doing nvim somefile.txt, it will render the file as quickly as possible, before loading your plugins.
			scope = { enabled = false }, --TODO:
			statuscolumn = { enabled = true }, -- View your marks, LSP Icons, Folds, better relative numbers(Current line, in linexD), etc.
			words = { -- hightlight words with LSP and jump there with "[[" or "]]"
				debounce = 150, -- time en ms to wait before updating
			},

			picker = {
				enabled = true,
				opts = {
					hidden = false,
				},
				win = {
					-- 1. Desactivamos en la ventana de entrada (donde escribes)
					input = {
						keys = {
							["<c-q>"] = false, -- I use <C-q> to move to left pane
							["q"] = false, -- Don't want to close Explorer "de causalidad"
							["<Esc>"] = false, -- Don't want to close Explorer "de causalidad"
							-- ["<c-k>"] = false, -- También lo desactivamos para que no interfiera
						},
					},
					list = {
						keys = {
							["<c-q>"] = false,
							["q"] = false, -- Don't want to close Explorer "de causalidad"
							["<Esc>"] = false, -- Don't want to close Explorer "de causalidad"
							-- ["<c-k>"] = false,
						},
					},
				},
				layout = {
					preset = "ivy",
				},
				sources = {
					explorer = {
						layout = {
							layout = {
								position = "right",
							},
						},
					},
				},
			},

			dashboard = {
				enabled = true,
				preset = {
					-- https://patorjk.com/software/taag/#p=display&f=Univers&t=Insano&x=none&v=4&h=4&w=80&we=false
					-- 88
					-- 88
					-- 88
					-- 88  8b,dPPYba,   ,adPPYba,  ,adPPYYba,  8b,dPPYba,    ,adPPYba,
					-- 88  88P'   `"8a  I8[    ""  ""     `Y8  88P'   `"8a  a8"     "8a
					-- 88  88       88   `"Y8ba,   ,adPPPPP88  88       88  8b       d8
					-- 88  88       88  aa    ]8I  88,    ,88  88       88  "8a,   ,a8"
					-- 88  88       88  `"YbbdP"'  `"8bbdP"Y8  88       88   `"YbbdP"'
					header = [[

██╗     ██╗███╗   ███╗ █████╗ ██╗   ██╗ ██████╗ ██████╗ ██╗  ██╗
██║     ██║████╗ ████║██╔══██╗╚██╗ ██╔╝██╔═══██╗██╔══██╗██║ ██╔╝
██║     ██║██╔████╔██║███████║ ╚████╔╝ ██║   ██║██████╔╝█████╔╝ 
██║     ██║██║╚██╔╝██║██╔══██║  ╚██╔╝  ██║   ██║██╔══██╗██╔═██╗ 
███████╗██║██║ ╚═╝ ██║██║  ██║   ██║   ╚██████╔╝██║  ██║██║  ██╗
╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
   ]],
				},
			},
		},
	},
}
