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
			image = { enabled = true },
			animate = {
				enabled = true, -- Asegúrate de que esté activo
				duration = 10, -- ms per step
				easing = "linear",
				fps = 120, -- frames per second. Global setting for all animations
			},
			scroll = {
				enabled = false,
				animate = {
					duration = {
						step = 10, --  pAl reducir el tiempo por paso, la animación tiene más "muestras" por segundo. Esto hace que el movimiento sea más "sedoso", especialmente si tienes un monitor de muchos Hz.
						total = 100, -- und: milisegudos
					}, --animacion para scroll?
					-- easing = "linear",
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
			input = { enabled = false }, -- Better vim.ui.input.(La version light the noice.nvim, desactivalo para que `noice` pueda trabajar)
			notifier = { enabled = false }, -- Windows corner top-right notifications `vim.notify` (La version light the noice.nvim desactivalo para que `noice` pueda trabajar)
			quickfile = { enabled = true }, -- When doing nvim somefile.txt, it will render the file as quickly as possible, before loading your plugins.
			scope = { enabled = false }, --TODO:
			statuscolumn = { enabled = true }, -- View your marks, LSP Icons, Folds, better relative numbers(Current line, in linexD), etc.
			words = { -- hightlight words with LSP and jump there with "[[" or "]]"
				debounce = 150, -- time en ms to wait before updating
			},

			picker = {
				enabled = true,
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
					preset = "ivy_split",
					-- preset = "right", --Good, all page like ff choose "right" to obten de 'sidebar' style on right hand
					-- preset = "sidebar", --Good, all page like ff choose "right" to obten de 'sidebar' style on right hand
					-- preset = "vertical", -- S
				},
				sources = {
					explorer = {
						-- focus = "",
						jump = { close = true }, --autoclose when you choose a file
						-- sidebar
						layout = {
							-- preset = "vertical",
							preview = false,
							layout = {
								position = "right",
							},
						},
					},
					files = {
						-- finder = "explorer", puedes convertir el buscar en un explorer con esta linea
						hidden = true,
						ignored = true,
					},
				},
			},

			dashboard = {
				enabled = true,
				preset = {
					keys = {
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					},
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
				sections = {
					-- { section = "header" },
					{
						pane = 2,
						icon = " ",
						title = "Git Status",
						section = "terminal",
						enabled = function()
							return Snacks.git.get_root() ~= nil
						end,
						cmd = "git status --short --branch --renames",
						height = 10,
						padding = 1,
						ttl = 5 * 60,
						indent = 3,
					},
					-- { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
		},
		config = function(_, opts)
			require("snacks").setup(opts)

			-- Guard: "jump" asserts when a picker item has neither .buf nor .file.
			-- Instead of the red error, close the picker and report which one caused it.
			local actions = require("snacks.picker.actions")
			local confirm = actions.confirm -- same function as actions.jump
			actions.confirm = function(picker, item, action)
				for _, it in ipairs(picker:selected({ fallback = true })) do
					if not it.buf and not it.file then
						picker:close()
						vim.notify(
							("Snacks picker '%s': item without file/buf\n%s"):format(
								picker.opts.source or "?",
								vim.inspect(it, { depth = 1 })
							),
							vim.log.levels.WARN
						)
						return
					end
				end
				return confirm(picker, item, action)
			end
		end,
	},
}
