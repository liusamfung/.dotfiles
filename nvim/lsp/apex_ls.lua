return {
	-- recommended in lsp-nvim config oficial https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#apex_ls
	apex_jar_path = vim.fn.stdpath("data") .. "/mason/share/apex-language-server/apex-jorje-lsp.jar",
	apex_enable_semantic_errors = false, -- Whether to allow Apex Language Server to surface semantic errors
	apex_enable_completion_statistics = false, -- Whether to allow Apex Language Server to collect telemetry on code completion usage
}
