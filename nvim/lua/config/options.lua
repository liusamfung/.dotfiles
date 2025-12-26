vim.opt.wrap = false -- Don't wrap default. (Teot fit in one  no matters how log it is)
vim.opt.breakindent = true -- Cuando tenemos el modo Wrap activo y la linea es tan grande que no entra en la panatalla. Queremos que este continue la identacion de la linea actual. No queromos que se vaya hasta el principio de la linea (Columna 0) ttnuutuetuuntoehentuhtuhtoehu uoeu eou ue euoe uee uoe oeu oeu ou oe uoe  uuoeueuou

vim.opt.number = true -- Se the line number left side
vim.opt.relativenumber = true --See relative numbers (It'll change in real time)
vim.o.signcolumn = "yes" -- ["auto","yes'] Keep 1 column empty on the leftside to show icons, features, etc(✖, ⚠)for LSP, or  Git signs, Debugg mark, etc
vim.opt.colorcolumn = "80" --Show line hightlight in column 80. (Very usefull to follow standart or conventionsr)

vim.opt.mouse = "a" --Enable mouse (Sometimes we want to use for resizing when we don't have a key map)
vim.opt.sidescrolloff = 20 -- number of columns to keep to hte left/right of cursor (Que el cursor no toque el límite lateral y siempre puedas verr la siguiente palabra)
vim.opt.scrolloff = 2 -- Minimal number of screen lines to keep above and below the cursor.(Same behavior to 'sidescrolloff')

vim.opt.showmode = true -- Don't show mode(Insert, normal, etc) in command line(The last line on this window). If you have Statusline/bar. You don't enable this obviously.

vim.opt.expandtab = true --"True" for convert tabcharater to spacecharactecr (for tabstop, no indenttab)Espacios):Esta es la norma en el desarrollo moderno (JavaScript, Python, Lua, etc.), porque garantiza que el código se vea igual en todas las computadoras del mundo.
vim.opt.shiftwidth = 2 --number of character inserted for each indentation level
vim.opt.tabstop = 2 --number of spaces(Charter/column) inserted for tab character ( After typing any word in single line: word word (tab) word)
vim.opt.smartindent = false -- Neovim moderno, lo ideal es tenerlo en false para evitar confictos con el LSP o Treesitter. Era un truco antiguo para adivinar la identacion
vim.opt.softtabstop = 2 --number of charactecr inserted for <Tab> key or <Backspace>. For example, if your have assiged `tabstop = 2` and softtabstop = 5. Neovim will insert <tab><tab><space> = (5 columns/characters)

vim.opt.spelllang = { "en", "es" } -- Agregamos el dueouiccionario para ingles(en) y español(es)
vim.opt.spell = false --Disable por defecto el spell language.

vim.opt.termguicolors = true -- True color support-just enable. It make colors better.

-- Sync clipboard between OS and Neovim.
-- NOTE: See config/keymap.lua. Exist a keymap to Yank in OS Clipboard Maybe It's better keep separeted
-- vim.schedule(function() --  Remove this option if you want your OS clipboard to remain independent.
--   vim.o.clipboard = 'unnamedplus'
-- end) --  See `:help 'clipboard'`

vim.opt.undofile = true -- If you quit nvim en go in the same file again. Now you can do undo-action.
vim.opt.undolevels = 10000 -- Save 10000 registers (checkpoints) to press key 'u' for undo change.
vim.opt.updatetime = 50 -- Save swap file(Neovim guarda los cambios temporales en el disco por si se apaga la computadora.) and trigger CursorHold.(Muchos plugins (como los que muestran errores de programación o diagnósticos de LSP) esperan a que dejes de escribir para mostrarte información. si tienes un error en tu código, el aviso aparecerá casi instantáneamente (0.05 segundos).
-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 500 -- If you have a key map ('jk' to show Explorer) you will have 500 to press 'k' after 'j' for open your Explorer. If you longer than that, then y just move down(j) then up(k).

vim.opt.ignorecase = true --If  you search "hola" with "/", neovim will find "Hola, hola, HOLA"
vim.opt.smartcase = true -- If you type "Hola" (At least one uppercase) it only find "Hola" it will be case sensitive(Default)
vim.opt.inccommand = "split" --When you trying to find and replace wiht :%s/<tarjet>/<new> split a new windown to show where and how many lines are changing

-- vim.opt.hlsearch = false --hightlight in Find (With '/)
-- vim.opt.incsearch = true -- I think this come enable default

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.(That are ussualy "invisible").
vim.opt.list = false --Active list (required
vim.opt.listchars = { --if you want to pass a table, you must to use 'opt'
	tab = "» ",
	trail = "·", -- (Space-character in the end line) It's trash character, always we have to delete it.
	nbsp = "␣",
	eol = "↲", -- Muestra el final de la línea (Enter)
	extends = "»", -- Símbolo si la línea sigue fuera de la pantalla (derecha)
	-- precedes = '«', -- Símbolo si hay texto oculto a la izquierda
	-- space = '⋅',    -- Muestra cada espacio (puede ser muy ruidoso)
}

-- vim.o.cursorline = true -- Show which line your cursor is

vim.o.confirm = true -- When you try to quit to the wile without save. Neovim give you options (Save, discard, cancel)
