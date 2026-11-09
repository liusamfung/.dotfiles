return {
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		-- The plugin ships a small Node app that serves the preview. `npm install` builds it with the node from mise.
		-- IMPORTANT: Run `:Lazy build markdown-preview.nvim` to redo it. (once)
		-- npm rewrites the tracked app/yarn.lock (and adds a package-lock.json), and lazy.nvim then refuses to update the
		-- plugin ("You have local changes"). --no-package-lock plus the checkout keep the plugin folder clean.
		build = "cd app && npm install --no-package-lock && git checkout -- yarn.lock",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		keys = {
			{
				"<leader>cp",
				ft = "markdown",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "Markdown Preview",
			},
		},
	},
}
