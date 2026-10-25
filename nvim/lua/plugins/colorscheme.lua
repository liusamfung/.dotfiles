-- Colorschemes. Every theme is installed but only the one in use is loaded: with `lazy = true`, lazy.nvim loads a
-- theme the moment `:colorscheme <name>` runs. To try another one use <leader>fC (it lists only the themes below,
-- with live preview). The last theme you chose is remembered between sessions.
--
-- To add a theme: add its spec below with `lazy = true`. To drop one: delete its spec.

local default = "solarized-osaka"
local state_file = vim.fn.stdpath("state") .. "/colorscheme"

local function saved_colorscheme()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	return ok and lines[1] ~= "" and lines[1] or default
end

local group = vim.api.nvim_create_augroup("colorscheme_settings", { clear = true })

-- Remember the colorscheme, whether it was chosen with <leader>fC or with :colorscheme.
-- Only after startup: before VimEnter the changes are not a choice of yours (the restore below, or the temporary
-- "habamax" lazy.nvim applies while it installs missing plugins).
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	desc = "Save the colorscheme to restore it on the next start",
	callback = function(args)
		if vim.v.vim_did_enter == 1 then
			pcall(vim.fn.writefile, { args.match }, state_file)
		end
	end,
})

-- Transparent background for every theme (some have no option for it).
-- nvim_set_hl replaces the whole group, so the theme's foreground is read first and kept. Without it Normal
-- had no colors at all and snacks.gh (the GitHub pickers, :checkhealth snacks) failed when it blended them.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	desc = "Transparent background",
	callback = function()
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		vim.api.nvim_set_hl(0, "Normal", vim.tbl_extend("force", normal, { bg = "none" }))
	end,
})

return {
	{
		-- Shortend Github urlr
		"craftzdog/solarized-osaka.nvim",
		lazy = false,
		priority = 1000, --Load first first first
		config = function()
			require("solarized-osaka").setup({
				transparent = true,
				styles = {
					-- You need a compatibleNertfont
					comments = { italic = true }, -- Enable italics in comments
					functions = { italic = true, bold = true },
					keywords = { bold = true }, -- Anotaciones, palabras reservadas, etc
				},
			})
			-- The saved theme (or this one by default). If it was uninstalled, fall back to the default.
			if not pcall(vim.cmd.colorscheme, saved_colorscheme()) then
				vim.cmd.colorscheme(default)
			end
		end,
	},

	{ "Mofiqul/dracula.nvim", lazy = true },

	{ "2nthony/vitesse.nvim", lazy = true, dependencies = { "tjdevries/colorbuddy.nvim" } },

	{
		"cpea2506/one_monokai.nvim",
		lazy = true,
		opts = { transparent = true, italics = true },
	},
}
