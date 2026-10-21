return {
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			-- <leader>gh = "git hunks" of the current file. ]h / [h jump between hunks.
			on_attach = function(buf)
				local gs = require("gitsigns")
				local map = function(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
				end

				map("]h", function()
					gs.nav_hunk("next")
				end, "Next hunk")
				map("[h", function()
					gs.nav_hunk("prev")
				end, "Prev hunk")

				map("<leader>ghp", gs.preview_hunk_inline, "Hunk: preview inline")
				map("<leader>ghs", gs.stage_hunk, "Hunk: stage (toggle)")
				map("<leader>ghr", gs.reset_hunk, "Hunk: reset")

				map("<leader>ghd", gs.diffthis, "Diff file vs index")
				map("<leader>ghD", function()
					gs.diffthis("HEAD")
				end, "Diff file vs HEAD")
				map("<leader>ghu", function()
					gs.diffthis(nil, { unified = true })
				end, "Diff inline (repeat to close)")

				map("<leader>ghb", gs.blame_line, "Blame line")
			end,
		},
	},
}
