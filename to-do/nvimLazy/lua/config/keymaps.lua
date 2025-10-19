local discipline = require("craftzdog.discipline")

discipline.cowboy()
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- g Add any additional keymaps here
--
-- vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
keymap.set("t", "<C-i>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })
-- TODO: How to jump to next 'Todo'(Por hacer) '[ + t'  or '] + t'
-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
-- keymap.set("n", "dw", 'vb"_d')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- -- New tab
-- keymap.set("n", "te", ":tabedit")
-- keymap.set("n", "<tab>", ":tabnext<Return>", opts)
-- keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Split window
-- keymap.set("n", "sh", ":split<Return>", opts)
-- keymap.set("n", "ss", ":vsplit<Return>", opts)
-- keymap.set("n", "tsh", ":sp | term<Return>", opts)
-- keymap.set("n", "tss", ":vs | term<Return>", opts)

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")
