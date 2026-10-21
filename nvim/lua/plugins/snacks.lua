-- pick("<lhs>", "<picker source>", "<desc>", { picker options }, { modes }) -> lazy.nvim `keys` entry
local function pick(lhs, source, desc, opts, mode)
	return {
		lhs,
		function()
			Snacks.picker[source](opts)
		end,
		desc = desc,
		mode = mode,
	}
end

return {
	-- "nvim-tree/nvim-web-devicons", -- optional dependency snacks usa este plugin como dependencia para los iconos
	{
		"folke/snacks.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		priority = 1000,
		lazy = false,
		keys = {
			-- Files / buffers ---------------------------------------------------------------------
			pick("<leader><space>", "smart", "Picker smart"),
			pick("<leader>,", "buffers", "Picker buffers"),
			pick("<leader>fb", "buffers", "Find Buffers"),
			pick("<leader>:", "command_history", "Command History"),
			pick(
				"<leader>ff",
				"files",
				"Find File (modificado)",
				{ exclude = { "node_modules", ".git", ".sfdx", ".sf" } }
			),
			pick("<leader>fF", "files", "Find Files (all, without filters)"),
			pick("<leader>fc", "files", "Find Config File", { cwd = "~/dotfiles/" }),
			pick("<leader>fg", "git_files", "Find git files (Trackeados)"),
			pick("<leader>fp", "projects", "Find Projects"), -- TODO: How detect projects
			pick("<leader>fr", "recent", "Find Recent files"),
			pick("<leader>fC", "colorschemes", "Find Colorschemes (installed plugins)", {
				-- hide the ~30 colorschemes that ship with Neovim; only the plugins of plugins/colorscheme.lua remain
				transform = function(item)
					return not vim.startswith(item.file, vim.env.VIMRUNTIME)
				end,
			}),
			{
				"<leader>ue",
				function()
					Snacks.explorer()
				end,
				desc = "Snacks Explorer",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File (Snacks)",
			},
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Scratch",
			},
			{
				"]]",
				function()
					Snacks.words.jump(1, false) -- Cycle "false"
				end,
				desc = "Go next highlighted word",
			},
			{
				"[[",
				function()
					Snacks.words.jump(-1, false)
				end,
				desc = "Go prev highlighted word",
			},

			-- LSP ---------------------------------------------------------------------------------
			pick("gd", "lsp_definitions", "LSP: Goto Definition"),
			pick("gD", "lsp_declarations", "LSP: Goto Declaration"),
			pick("gr", "lsp_references", "LSP: Goto References"),
			pick("gI", "lsp_implementations", "LSP: Goto Implementation"),
			pick("gy", "lsp_type_definitions", "LSP: Goto T[y]pe Definition"),
			pick("gai", "lsp_incoming_calls", "LSP: C[a]lls Incoming"),
			pick("gao", "lsp_outgoing_calls", "LSP: C[a]lls Outgoing"),
			pick("<leader>ss", "lsp_symbols", "LSP: Symbols"),
			pick("<leader>sS", "lsp_workspace_symbols", "LSP: Workspace Symbols"),
			pick("<leader>sd", "diagnostics", "Search diagnostics"),
			pick("<leader>sD", "diagnostics_buffer", "Search buffer diagnostics"),

			-- Search ------------------------------------------------------------------------------
			pick("<leader>/", "grep", "Grep"),
			pick("<leader>sb", "lines", "Search current Buffer Lines (Grep)"),
			pick("<leader>sB", "grep_buffers", "Search in Buffers (Grep)"),
			pick("<leader>sw", "grep_word", "Search Visual selection or word", nil, { "n", "x" }),
			pick("<leader>sc", "commands", "Search Commands"),
			pick("<leader>sp", "lazy", "Search Plugins"),
			pick("<leader>si", "icons", "Search Icons"),
			pick("<leader>sj", "jumps", "Search Jumps"),
			pick("<leader>s+", "registers", "Search Registers"),
			pick("<leader>s/", "search_history", "Search History"),
			pick("<leader>sa", "autocmds", "Search Autocmds"),
			pick("<leader>sh", "help", "Search Help Pages"),
			pick("<leader>sM", "man", "Man Pages"),
			pick("<leader>sH", "highlights", "Search Highlights"),
			pick("<leader>sk", "keymaps", "Search Keymaps"),
			pick("<leader>sq", "qflist", "Search Quickfix"), -- TODO: Que hace el Quickfix
			pick("<leader>sl", "loclist", "Search Location List"), -- TODO: que es esto
			pick("<leader>s'", "marks", "Search Marks"),
			pick("<leader>sR", "resume", "Search Resume"), -- TODO: que es esto
			pick("<leader>su", "undo", "Search on Undo History"),

			-- Git ---------------------------------------------------------------------------------
			-- (<leader>gl and <leader>gf live in diffview.lua: Enter opens the commit in Diffview)
			pick("<leader>gb", "git_branches", "Git Branches"),
			pick("<leader>gL", "git_log_line", "Git Log Line"),
			pick("<leader>gs", "git_status", "Git Status"),
			pick("<leader>gS", "git_stash", "Git Stash"),
			pick("<leader>gd", "git_diff", "Git diff (Hunks)"),
			pick("<leader>gD", "git_diff", "Git Diff (vs origin/main)", { base = "origin/main" }),
			{
				"<leader>gB",
				function()
					Snacks.gitbrowse()
				end,
				desc = "Git Browse",
				mode = { "n", "x" },
			},
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},

			-- GitHub: issues and pull requests ------------------------------------------------------
			-- <leader>gp = "pull request". Review someone else's PR without leaving nvim:
			--   gpp pick a PR -> <cr> menu (diff, checkout, comment, approve, request changes...), <a-d> straight to its diff
			--   gpd diff of PR #n   gpc checkout PR #n   (gpv, Diffview of the PR vs its base, is in diffview.lua)
			pick("<leader>gi", "gh_issue", "GitHub Issues (open)"),
			pick("<leader>gI", "gh_issue", "GitHub Issues (all)", { state = "all" }),
			pick("<leader>gpp", "gh_pr", "PR: list (open)"),
			pick("<leader>gpa", "gh_pr", "PR: list (all)", { state = "all" }),
			pick("<leader>gP", "gh_pr", "GitHub Pull Requests (All)", { state = "all" }),
			{
				"<leader>gpd",
				function()
					vim.ui.input({ prompt = "PR number: " }, function(n)
						if n and tonumber(n) then
							Snacks.picker.gh_diff({ pr = tonumber(n) })
						end
					end)
				end,
				desc = "PR: diff of #n (comment with `a`)",
			},
			{
				"<leader>gpc",
				function()
					vim.ui.input({ prompt = "Checkout PR number: " }, function(n)
						if not (n and tonumber(n)) then
							return
						end
						vim.system({ "gh", "pr", "checkout", n }, { text = true }, function(res)
							vim.schedule(function()
								if res.code == 0 then
									vim.cmd("checktime")
									vim.notify("Checked out PR #" .. n)
								else
									vim.notify("gh pr checkout failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
								end
							end)
						end)
					end)
				end,
				desc = "PR: checkout #n",
			},
		},
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
					gh_pr = {
						actions = {
							-- Close the PR list first, otherwise two ivy_split layouts stack and the preview collapses.
							pr_diff = function(picker, item)
								if not item then
									return
								end
								picker:close()
								vim.schedule(function()
									Snacks.picker.gh_diff({ repo = item.repo, pr = item.number })
								end)
							end,
						},
						win = {
							input = { keys = { ["<a-d>"] = { "pr_diff", mode = { "n", "i" } } } },
							list = { keys = { ["d"] = "pr_diff" } },
						},
					},
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
					{ section = "header" },
					-- {
					-- 	pane = 2,
					-- 	icon = " ",
					-- 	title = "Git Status",
					-- 	section = "terminal",
					-- 	enabled = function()
					-- 		return Snacks.git.get_root() ~= nil
					-- 	end,
					-- 	cmd = "git status --short --branch --renames",
					-- 	height = 10,
					-- 	padding = 1,
					-- 	ttl = 5 * 60,
					-- 	indent = 3,
					-- },
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
