-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
--
--If you wanna view relotivenumber in 'terminalmode'
-- vim.api.nvim_create_autocmd("TermOpen", {
--   callback = function()
--     -- vim.opt_local.relativenumber = true
--     -- vim.opt_local.wrap = false
--   end,
-- })
