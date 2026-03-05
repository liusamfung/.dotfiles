vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function(args)
		require("jdtls.jdtls_setup").setup()
	end,
})

-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "apex",
-- 	callback = function(args)
-- 		require("jdtls.jdtls_setup").setup()
-- 	end,
-- })
--
