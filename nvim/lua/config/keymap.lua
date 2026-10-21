-- Only keymaps that do NOT belong to a plugin live here (built-in Neovim behaviour).
-- Every plugin keymap lives in `keys = { ... }` of that plugin's file in lua/plugins/, so removing
-- or commenting the plugin removes its keymaps too. The leader key is set in config/lazy.lua.
-- Plugin manager (lazy.nvim has no spec file of its own, so its keymap stays here)
vim.keymap.set("n", "<leader>l", vim.cmd.Lazy, { desc = "Lazy" })

vim.keymap.set("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Toggle previous buffer" })

-- Paste over a selection without overwriting the yank register ("sometimes we don't copy, just paste paste paste")
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without overwriting the register" })

-- space+y to save the yank in the OS clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to OS clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to OS clipboard" })

vim.keymap.set("n", "<leader>xx", vim.diagnostic.open_float, { desc = "Show diagnostic in a floating window" })

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

-- "J" joins lines but leaves the cursor at the start of the line, so you can see which line moved
vim.keymap.set("n", "J", "J_")

-- Keep the cursor in the middle of the screen when searching (n/N) and when jumping to the bottom (G)
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set({ "n", "x" }, "G", "Gzz")

-- Toggles under <leader>u ---------------------------------------------------------------------------
vim.keymap.set("n", "<leader>uw", function()
	vim.o.wrap = not vim.o.wrap
end, { desc = "Toggle wrap" })

vim.keymap.set("n", "<leader>uH", function()
	vim.o.list = not vim.o.list
	local estado = vim.o.list and "VISIBLES" or "OCULTOS"
	local color = vim.o.list and "DiagnosticWarn" or "DiagnosticOk"
	vim.api.nvim_echo({ { "Caracteres ocultos: " .. estado, color } }, false, {}) -- false: don't save it in :messages
end, { desc = "Toggle Hidden characters" })

-- Spelling ------------------------------------------------------------------------------------------
-- Native (no keymap needed): zg adds the word under the cursor to your dictionary, zw removes it, z= lists suggestions.
vim.keymap.set("n", "<leader>uS", function()
	vim.o.spell = not vim.o.spell
	local status = vim.o.spell and "visible" or "hidden"
	local color = vim.o.spell and "DiagnosticWarn" or "DiagnosticOk"
	vim.api.nvim_echo({ { "Spelling grammar is " .. status, color } }, false, {})
end, { desc = "Toggle spelling Grammar" })

vim.keymap.set("n", "<leader>use", function()
	vim.opt.spelllang = "en"
	vim.cmd("echo 'Spell language set to English'")
end, { desc = "Spelling language English" })

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
end, { desc = "Spelling: apply the first suggestion" })
