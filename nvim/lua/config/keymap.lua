-- set leader key to space
local opts = {
	noremap = true, --NoRecursiveMapping No busques si ese comando tiene otros atajos asociados.(Solo haz la secuencia que se te menciona)"
	silent = true, --TODO: Don't work?
}

vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>e", vim.cmd.Ex, opts)
vim.keymap.set("n", "<leader>l", vim.cmd.Lazy, opts)

vim.keymap.set("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Toggle previous buffer" })

-- Use space+p to paste your current yank line without copy-override your clipboard
-- Sometime we don't copy, just paste paste paste paste
vim.keymap.set("x", "<leader>p", '"_dP', opts)

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- When you using "J" to stack lines. Don't move the cursor the end line. Very useful for know `What the fuck line` I will move.
vim.keymap.set("n", "J", "mzJ`z")

--When you navigate with <C-d/u>, keep the cursor en the middle. Very useful for not getting disoriented.
-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- When you search ('/'), keep the cursor en the middle.
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
--When I use "G" to go the bottom. I like the cursor in the middle
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("x", "G", "Gzz")

-- Use space+p to paste your current yank line without copy-override your clipboard
-- Sometime we don't copy, just paste paste paste paste
vim.keymap.set("x", "<leader>p", '"_dP')

-- space+y to Save yank in OS clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Fix Quickfix?? Test
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>cm", vim.cmd.Mason, { noremap = true, silent = true, desc = "Open Mason" })

vim.keymap.set("n", "<leader>uw", function()
	vim.o.wrap = not vim.o.wrap
	local status = vim.o.wrap and "enable" or "disable"
	local color = vim.o.wrap and "DiagnosticError" or "DiagnosticOk"
	vim.api.nvim_echo({ { "Now wrap is " .. status, color } }, false, {})
end)

vim.keymap.set("n", "<leader>uH", function()
	vim.o.list = not vim.o.list --First, change the value.
	local estado = vim.o.list and "VISIBLES" or "OCULTOS"
	local color = vim.o.list and "DiagnosticWarn" or "DiagnosticOk"
	vim.api.nvim_echo({ { "Caracteres ocultos: " .. estado, color } }, false, {}) --(False to not save this message in the list of :message)
end, { desc = "Toggle Hidden characters" })

vim.keymap.set("n", "<leader>uS", function()
	-- vim.opt.spell !=  vim.o.spell
	-- vm.opt === Memory direction(Object 0xwhatever)
	-- vim.o === Real value (Data: True, false, etc)
	vim.o.spell = not vim.o.spell
	local status = vim.o.spell and "visible" or "hidden"
	local color = vim.o.spell and "DiagnosticWarn" or "DiagnosticOk"
	vim.api.nvim_echo({ { "Spelling grammar is " .. status, color } }, false, {})
end, { desc = "Toggle spelling Grammar" })

vim.keymap.set("n", "<leader>use", function()
	vim.opt.spelllang = "en"
	vim.cmd("echo 'Spell language set to English'")
end)

vim.keymap.set("n", "<leader>uss", function()
	vim.opt.spelllang = "es"
	vim.cmd("echo 'Spell language set to Spanish'")
end, { desc = "Spelling language Spanish" })

vim.keymap.set("n", "<leader>usb", function()
	vim.opt.spelllang = "en,es"
	vim.cmd("echo 'Spell language set to Spanish and English'")
end, { desc = "Spelling language Spanish and English" })

vim.keymap.set("n", "<leader>usc", function()
	vim.cmd("normal! 1z=")
end, { desc = "Spelling suggestions" })
--[[Atajos para gestionar el diccionario personal de spellcheck son nativos de Neovim y Vim y vienen por defecto:
  - zg: Para agregar la palabra bajo el cursor al diccionario personal (permanente).
  - zw: Para remover la palabra del diccionario personal.
  - z=: Para abrir la lista de sugerencias de corrección ortográfica (muy útil para corregir errores rápidamente).
  ]]
--
vim.keymap.set({ "n" }, "<leader>f.", function()
	require("telescope.builtin").find_files({
		prompt_title = "< NvimRC >",
		cwd = "~/dotfiles/",
		no_ignore = true,
		hidden = true, -- Ver los archivos ocultos (Como .zshrc, etc)
		preview = {
			hide_on_startup = true,
		},
	})
end, opts)

vim.keymap.set("n", "<leader>ue", function()
	require("snacks").explorer()
end, { noremap = true, silent = true, desc = "Snacks Explorer" }) -- TOOD: En que se diferencia con el de arriba

--Snacks.Find
vim.keymap.set("n", "<leader>fo", function()
	require("telescope.builtin").oldfiles()
end, opts)

vim.keymap.set("n", "<leader>fC", function()
	require("telescope.builtin").colorscheme()
end, opts)

vim.keymap.set("n", "<leader>fr", function()
	require("telescope.builtin").registers()
end, { noremap = true, silent = true, desc = "register" })

vim.keymap.set("n", "<leader>fk", function()
	require("telescope.builtin").keymaps()
end, opts)
--LSP -------------------------------------------------------

vim.keymap.set("n", "<leader>cR", function()
	require("snacks").rename.rename_file()
end, { noremap = true, silent = true, desc = "Rename File(Snacks)" }) -- vim.notify

vim.keymap.set("n", "<leader>sd", function()
	require("snacks").picker.diagnostics()
end, { noremap = true, silent = true, desc = "Search diagnostics(Snacks.picker)" }) -- TODO:

vim.keymap.set("n", "<leader>sD", function()
	require("snacks").picker.diagnostics_buffer()
end, { noremap = true, silent = true, desc = "Search Bufffer diagnostics(Snacks.picker)" }) -- TOOD: En que se diferencia con el de arriba

vim.keymap.set("n", "<leader>sq", function()
	require("snacks").picker.qflist()
end, { noremap = true, silent = true, desc = "Search Quickfix" }) -- TODO: Que hace er Quickfix

vim.keymap.set("n", "gd", function()
	require("snacks").picker.lsp_definitions()
end, { noremap = true, silent = true, desc = "LSP: Goto Definition" })

vim.keymap.set("n", "gD", function()
	require("snacks").picker.lsp_declarations()
end, { noremap = true, silent = true, desc = "LSP: Goto Declaration" })

vim.keymap.set("n", "gr", function()
	require("snacks").picker.lsp_references()
end, { noremap = true, silent = true, desc = "LSP: Goto References" })

vim.keymap.set("n", "gI", function()
	require("snacks").picker.lsp_implementations()
end, { noremap = true, silent = true, desc = "LSP: Goto Implementation" })

vim.keymap.set("n", "gy", function()
	require("snacks").picker.lsp_type_definitions()
end, { noremap = true, silent = true, desc = "LSP: Goto T[y]pe Definition" })

vim.keymap.set("n", "gai", function()
	require("snacks").picker.lsp_incoming_calls()
end, { noremap = true, silent = true, desc = "LSP: C[a]lls Incoming" })

vim.keymap.set("n", "gao", function()
	require("snacks").picker.lsp_outgoing_calls()
end, { noremap = true, silent = true, desc = "LSP: C[a]lls Outgoing" })

vim.keymap.set("n", "<leader>ss", function()
	require("snacks").picker.lsp_symbols()
end, { noremap = true, silent = true, desc = "LSP: Symbols" })

vim.keymap.set("n", "<leader>sS", function()
	require("snacks").picker.lsp_workspace_symbols()
end, { noremap = true, silent = true, desc = "LSP: Workspace Symbols" })

--Snacks
vim.keymap.set("n", "<leader><space>", function()
	require("snacks").picker.smart()
end, { noremap = true, silent = true, desc = "Picker smart" })

vim.keymap.set("n", "<leader>,", function()
	require("snacks").picker.buffers()
end, { noremap = true, silent = true, desc = "Picker buffers" })

vim.keymap.set("n", "<leader>:", function()
	require("snacks").picker.command_history()
end, { noremap = true, silent = true, desc = "Command History" })

vim.keymap.set("n", "<leader>n", function()
	require("snacks").picker.notifications()
end, { noremap = true, silent = true, desc = "Notification History" }) -- vim.notify
-- find---------------------------------------
vim.keymap.set("n", "<leader>fb", function()
	require("snacks").picker.buffers()
end, { noremap = true, silent = true, desc = "Find Buffers" }) -- vim.notify

vim.keymap.set("n", "<leader>fc", function()
	Snacks.picker.files({ cwd = "~/dotfiles/" })
end, { noremap = true, silent = true, desc = "Find Config File" }) -- vim.notify

vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files()
end, { noremap = true, silent = true, desc = "Find Files" }) -- find files

vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, { noremap = true, silent = true, desc = "Find git files(Trackeados)" }) -- Archivos trackeados por git

vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { noremap = true, silent = true, desc = "Find Projects" }) -- TOOD: How detect projects

vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { noremap = true, silent = true, desc = "Find Recent files" })
-- Git-----------------------------------------------
vim.keymap.set("n", "<leader>gb", function()
	Snacks.picker.git_branches()
end, { noremap = true, silent = true, desc = "Git Branches" })

vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, { noremap = true, silent = true, desc = "Git Log" })

vim.keymap.set("n", "<leader>gL", function()
	Snacks.picker.git_log_line()
end, { noremap = true, silent = true, desc = "Git Log Line" })

vim.keymap.set("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { noremap = true, silent = true, desc = "Git Status" })

vim.keymap.set("n", "<leader>gS", function()
	Snacks.picker.git_stash()
end, { noremap = true, silent = true, desc = "Git Stash" })

vim.keymap.set("n", "<leader>gdttt", function()
	Snacks.picker.git_diff()
end, { noremap = true, silent = true, desc = "Git diff (Hunks)" })

vim.keymap.set("n", "<leader>gf", function()
	Snacks.picker.git_log_file()
end, { noremap = true, silent = true, desc = "Git Log File" })

vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit()
end, { noremap = true, silent = true, desc = "Lazygit" })
--gh-------------------------------
vim.keymap.set("n", "<leader>gi", function()
	Snacks.picker.gh_issue()
end, { noremap = true, silent = true, desc = "GitHub Issues (open)" })

vim.keymap.set("n", "<leader>gI", function()
	Snacks.picker.gh_issue({ state = "all" })
end, { noremap = true, silent = true, desc = "GitHub Issues(all)" })

vim.keymap.set("n", "<leader>gp", function()
	Snacks.picker.gh_pr()
end, { noremap = true, silent = true, desc = "GitHub Pull Requests(open)" })

vim.keymap.set("n", "<leader>gP", function()
	Snacks.picker.gh_pr({ state = "all" })
end, { noremap = true, silent = true, desc = "GitHub Pull Requests(All)" })

vim.keymap.set("n", "<leader>gB", function()
	Snacks.picker.gitbrowse()
end, { noremap = true, silent = true, desc = "Git Browse" })

--grep-------------------------------
vim.keymap.set("n", "<leader>sb", function()
	Snacks.picker.lines()
end, { noremap = true, silent = true, desc = "Search current Buffer Lines(Grep)" })

vim.keymap.set("n", "<leader>sB", function()
	Snacks.picker.grep_buffers()
end, { noremap = true, silent = true, desc = "Search in Buffers(Grep)" })

vim.keymap.set("n", "<leader>/", function()
	require("snacks").picker.grep()
end, { noremap = true, silent = true, desc = "Grep" })

vim.keymap.set({ "n", "x" }, "<leader>sw", function()
	require("snacks").picker.grep_word()
end, { noremap = true, silent = true, desc = "Search Visual selection or word" })

--Search-----------------------------------------
vim.keymap.set("n", "<leader>sc", function()
	require("snacks").picker.commands()
end, { noremap = true, silent = true, desc = "Search Commands" })

vim.keymap.set("n", "<leader>sp", function()
	require("snacks").picker.lazy()
end, { noremap = true, silent = true, desc = "Search Plugins" })

vim.keymap.set("n", "<leader>si", function()
	require("snacks").picker.icons()
end, { noremap = true, silent = true, desc = "Searh Icons" })

vim.keymap.set("n", "<leader>sj", function()
	require("snacks").picker.jumps()
end, { noremap = true, silent = true, desc = "Searh Jumps" })

vim.keymap.set("n", "<leader>s+", function()
	require("snacks").picker.registers()
end, { noremap = true, silent = true, desc = "Search Registers" })

vim.keymap.set("n", "<leader>s/", function()
	require("snacks").picker.search_history()
end, { noremap = true, silent = true, desc = "SearchHistory" })

vim.keymap.set("n", "<leader>sa", function()
	require("snacks").picker.autocmds()
end, { noremap = true, silent = true, desc = "Search Autocmds" })

vim.keymap.set("n", "<leader>sh", function()
	require("snacks").picker.help()
end, { noremap = true, silent = true, desc = "SearchHelp Pages" })

vim.keymap.set("n", "<leader>sM", function()
	require("snacks").picker.man()
end, { noremap = true, silent = true, desc = "Man Pages" })

vim.keymap.set("n", "<leader>sH", function()
	require("snacks").picker.highlights()
end, { noremap = true, silent = true, desc = "Search Highlights" })

vim.keymap.set("n", "<leader>sk", function()
	require("snacks").picker.keymaps()
end, { noremap = true, silent = true, desc = "Search Keymaps" })

vim.keymap.set("n", "<leader>sl", function()
	require("snacks").picker.loclist()
end, { noremap = true, silent = true, desc = "Search Location List" }) -- TODO: QUE ES ESTA MIELDA

vim.keymap.set("n", "<leader>s'", function()
	require("snacks").picker.marks()
end, { noremap = true, silent = true, desc = "Search Marks" })

vim.keymap.set("n", "<leader>sR", function()
	require("snacks").picker.resume()
end, { noremap = true, silent = true, desc = "Search Resume" }) -- TODO: QUE ES ESTA MIELDA

vim.keymap.set("n", "<leader>su", function()
	require("snacks").picker.undo()
end, { noremap = true, silent = true, desc = "Search on Undo History" })

--Snacks.otherss----------------------------------------------------------
vim.keymap.set("n", "<leader>bd", function()
	require("snacks").bufdelete()
end, { noremap = true, silent = true, desc = "delete  Buffer" })

vim.keymap.set("n", "<leader>un", function()
	require("snacks").notifier.hide()
end, { noremap = true, silent = true, desc = "Dismiss all notifications" })

vim.keymap.set("n", "<leader>.", function()
	require("snacks").scratch()
end, { noremap = true, silent = true, desc = "Scratch" })

vim.keymap.set("n", "]]", function()
	require("snacks").words.jump(1, false) -- Cycle "false"
end, { noremap = true, silent = true, desc = "Go next highlighted word" })

vim.keymap.set("n", "[[", function()
	require("snacks").words.jump(-1, false)
end, { noremap = true, silent = true, desc = "Go prev highlighted word" })

-- vim.keymap.set('n', '<leader>e', function()
--   require("snacks").picker.explorer()
-- end, { desc = 'File Explorer (Snacks)' }) -- vim.notify

--TODO:
--{ "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
-- { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },

-- load the session for the current directory
vim.keymap.set("n", "<leader>qb", function()
	require("persistence").load()
end, { noremap = true, silent = true, desc = "load session belongs to current workdir" })

-- select a session to load
vim.keymap.set("n", "<leader>qs", function()
	require("persistence").select()
end)

-- load the last session
vim.keymap.set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end)
