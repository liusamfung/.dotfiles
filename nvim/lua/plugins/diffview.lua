return {
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewFileHistory",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
		},
		-- <leader>gv = "view diff". Left side = old version, right side = your real file (editable).
		keys = {
			{ "<leader>gvv", "<cmd>DiffviewOpen<cr>", desc = "Diff: pending changes (index + worktree)" },
			{ "<leader>gvs", "<cmd>DiffviewOpen --staged<cr>", desc = "Diff: staged vs HEAD" },
			{ "<leader>gvl", "<cmd>DiffviewOpen HEAD~1..HEAD<cr>", desc = "Diff: last commit" },
			{ "<leader>gvm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diff: branch vs main (merge-base)" },
			{ "<leader>gvM", "<cmd>DiffviewOpen origin/main<cr>", desc = "Diff: worktree vs main" },
			{ "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: history of this file" },
			{ "<leader>gvF", "<cmd>DiffviewFileHistory<cr>", desc = "Diff: repo history" },
			{ "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Diff: close everything" },

			-- Snacks pickers whose Enter opens the commit in Diffview (snacks' default would `git checkout` it)
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log({
						confirm = function(picker, item)
							picker:close()
							if item and item.commit then
								vim.cmd("DiffviewOpen " .. item.commit .. "^!")
							end
						end,
					})
				end,
				desc = "Git Log (Enter = open diff)",
			},
			{
				"<leader>gf",
				function()
					local file = vim.api.nvim_buf_get_name(0)
					Snacks.picker.git_log_file({
						confirm = function(picker, item)
							picker:close()
							if item and item.commit then
								vim.cmd(("DiffviewOpen %s^! -- %s"):format(item.commit, vim.fn.fnameescape(file)))
							end
						end,
					})
				end,
				desc = "Git Log File (Enter = open diff)",
			},

			-- Diffview of the checked-out PR against the branch it targets (not always main)
			{
				"<leader>gpv",
				function()
					vim.system(
						{ "gh", "pr", "view", "--json", "baseRefName", "-q", ".baseRefName" },
						{ text = true },
						function(res)
							vim.schedule(function()
								local base = vim.trim(res.stdout or "")
								if res.code ~= 0 or base == "" then
									vim.notify(
										"This branch has no PR (use <leader>gpc to check one out)",
										vim.log.levels.WARN
									)
									return
								end
								vim.system({ "git", "fetch", "origin", base }, { text = true }, function()
									vim.schedule(function()
										vim.cmd("DiffviewOpen origin/" .. base .. "...HEAD")
									end)
								end)
							end)
						end
					)
				end,
				desc = "PR: Diffview vs its base branch",
			},
		},
		config = function()
			local actions = require("diffview.actions")

			-- Open the entry under the cursor; if it is a file (not a folder) hide the panel afterwards,
			-- the same behaviour as snacks' explorer (jump = { close = true }).
			local function open_and_hide()
				local view = require("diffview.lib").get_current_view()
				local item = view and view.panel:get_item_at_cursor()
				local is_file = item ~= nil and type(item.collapsed) ~= "boolean"
				actions.select_entry()
				if is_file then
					actions.toggle_files()
				end
			end

			require("diffview").setup({
				hooks = {
					-- DiffviewOpen starts with just the two diff panes; <leader>e brings the file panel back.
					-- File-history views keep their commit list: it is the only way to move between commits.
					view_opened = function(view)
						local DiffView = require("diffview.scene.views.diff.diff_view").DiffView
						if view:instanceof(DiffView) then
							view.panel:close()
						end
					end,
				},
				keymaps = {
					file_panel = {
						{ "n", "<cr>", open_and_hide, { desc = "Open diff and hide the panel" } },
						{ "n", "o", open_and_hide, { desc = "Open diff and hide the panel" } },
						{ "n", "l", open_and_hide, { desc = "Open diff and hide the panel" } },
						{ "n", "<2-LeftMouse>", open_and_hide, { desc = "Open diff and hide the panel" } },
						{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
					},
					file_history_panel = {
						{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
					},
				},
			})
		end,
	},
}
