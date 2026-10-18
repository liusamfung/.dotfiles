-- sf.nvim: wrapper around the `sf` CLI (push/retrieve, orgs, Apex tests, anonymous Apex, ...).
-- sf.nvim detects the project itself (sfdx-project.json / .forceignore, searched upwards from the current
-- file or cwd), so there is no `cond` here: with one, opening nvim from a subfolder of the project
-- (or `nvim path/to/Foo.cls` from outside it) silently left the plugin, its keymaps and `:SF` unloaded.

--- Absolute path of the Jest test that covers the current LWC file, or nil.
--- Works from foo.js / foo.html / foo.css of a bundle and from the test file itself.
local function lwc_test_file()
	local file = vim.api.nvim_buf_get_name(0)
	if file:match("%.test%.js$") then
		return file
	end
	local bundle_dir = vim.fs.dirname(file)
	if vim.fs.basename(vim.fs.dirname(bundle_dir)) ~= "lwc" then
		return nil
	end
	local test = ("%s/__tests__/%s.test.js"):format(bundle_dir, vim.fs.basename(bundle_dir))
	return vim.uv.fs_stat(test) and test or nil
end

local function run_lwc_jest(all)
	local ok, root = pcall(require("sf.util").get_sf_root)
	if not ok then
		return vim.notify("Not inside a Salesforce project", vim.log.levels.WARN)
	end
	if all then
		return require("sf").run(("cd %s && npm run test:unit:coverage"):format(vim.fn.shellescape(root)))
	end
	local test = lwc_test_file()
	if not test then
		return vim.notify("No __tests__/<bundle>.test.js for this file", vim.log.levels.WARN)
	end
	require("sf").run(
		("cd %s && npm run test:unit -- -- %s"):format(vim.fn.shellescape(root), vim.fn.shellescape(test))
	)
end

local function sf(fn_name, ...)
	local args = { ... }
	return function()
		return require("sf")[fn_name](unpack(args))
	end
end

return {
	{
		"xixiaofinland/sf.nvim",
		-- `:SF` and the keys below load the plugin on demand; VeryLazy makes sure the org list is fetched
		-- and the coverage signs / statusline are ready without opening a Salesforce filetype first.
		event = "VeryLazy",
		cmd = "SF",

		dependencies = {
			"nvim-treesitter/nvim-treesitter", -- needs the apex, soql, sosl and sflog parsers (see treesitter.lua)
			"ibhagwan/fzf-lua", -- metadata pickers (`:SF md list`, ctags list)
		},

		opts = {
			-- executable = "sf",
			term_config = {
				blend = 10, -- background transparency: 0 is fully opaque; 100 is fully transparent
				dimensions = { height = 0.9, width = 0.9, x = 0.5, y = 0.9 },
			},
		},

		keys = {
			-- Terminal
			{ "<leader>ts", sf("toggle_term"), desc = "SF: toggle terminal" },
			{ "<C-/>", "<cmd>SF term toggle<cr>", desc = "SF: toggle terminal" },

			-- Current file
			{ "<leader>tp", sf("save_and_push"), desc = "SF: save + push current file" },
			{ "<leader>tr", sf("retrieve"), desc = "SF: retrieve current file" },
			{ "<leader>td", sf("diff_in_target_org"), desc = "SF: diff vs target org" },
			{ "<leader>tD", sf("diff_in_org"), desc = "SF: diff vs org..." },
			{ "<leader>tx", sf("org_open_current_file"), desc = "SF: open file in org" },
			{ "<leader>tR", sf("rename_apex_class_remote_and_local"), desc = "SF: rename Apex class (org + local)" },
			{ "<leader>tX", sf("delete_current_apex_remote_and_local"), desc = "SF: delete Apex class (org + local)" },

			-- Create
			{ "<leader>tcl", "<cmd>SF create lwc<cr>", desc = "SF: create LWC" },
			{ "<leader>tct", "<cmd>SF create trigger<cr>", desc = "SF: create trigger" },
			{ "<leader>tca", "<cmd>SF create apex<cr>", desc = "SF: create Apex class" },
			{ "<leader>tcc", "<cmd>SF create ctags<cr>", desc = "SF: create ctags" },

			-- Orgs
			{ "<leader>tot", "<cmd>SF org setTarget<cr>", desc = "SF: select target org" },
			{ "<leader>tog", "<cmd>SF org setGlobalTarget<cr>", desc = "SF: select global target org" },
			{ "<leader>tof", "<cmd>SF org fetchList<cr>", desc = "SF: refresh org list" },
			{ "<leader>too", sf("org_open"), desc = "SF: open target org" },
			{ "<leader>tl", sf("pull_log"), desc = "SF: pull latest debug log" },
			{ "<leader>tS", "<cmd>SF sobject refresh<cr>", desc = "SF: refresh sObject definitions (apex_ls)" },

			-- Apex tests
			{ "<leader>tta", sf("run_all_tests_in_this_file"), desc = "SF: Apex tests in this file" },
			{
				"<leader>ttA",
				sf("run_all_tests_in_this_file_with_coverage"),
				desc = "SF: Apex tests in file + coverage",
			},
			{ "<leader>ttc", sf("run_current_test"), desc = "SF: Apex test under cursor" },
			{ "<leader>ttC", sf("run_current_test_with_coverage"), desc = "SF: Apex test under cursor + coverage" },
			{ "<leader>tts", sf("open_test_select"), desc = "SF: pick Apex tests" },
			{ "<leader>ttl", sf("repeat_last_tests"), desc = "SF: repeat last Apex tests" },
			{ "<leader>t/", sf("toggle_sign"), desc = "SF: toggle coverage signs" },
			{ "]v", sf("uncovered_jump_forward"), desc = "SF: next uncovered hunk" },
			{ "[v", sf("uncovered_jump_backward"), desc = "SF: previous uncovered hunk" },

			-- LWC Jest tests
			{
				"<leader>ttj",
				function()
					run_lwc_jest(false)
				end,
				desc = "SF: Jest for this LWC",
			},
			{
				"<leader>ttJ",
				function()
					run_lwc_jest(true)
				end,
				desc = "SF: Jest for all LWC + coverage",
			},

			-- Validate the current file against the org without saving anything there (see nvim-lint.lua)
			{
				"<leader>tv",
				function()
					require("lint").try_lint("sf_compile")
				end,
				desc = "SF: validate current file (dry-run)",
			},

			-- Run code. SOQL and the selection variants must be mapped in Visual mode: the plugin checks mode().
			{ "<leader>tqc", sf("run_highlighted_soql"), mode = "v", desc = "SF: run selected SOQL" },
			{
				"<leader>tar",
				sf("run_anonymous_stdin", true),
				mode = "v",
				desc = "SF: run selection as anonymous Apex",
			},
			{ "<leader>tar", sf("run_anonymous_stdin", false), desc = "SF: run buffer as anonymous Apex" },
			{ "<leader>taR", sf("run_anonymous"), desc = "SF: run file as anonymous Apex" },
		},

		config = function(_, opts)
			require("sf").setup(opts)

			local ok, wk = pcall(require, "which-key")
			if ok then
				wk.add({
					{ "<leader>t", group = "Salesforce" },
					{ "<leader>tc", group = "create" },
					{ "<leader>to", group = "orgs" },
					{ "<leader>ta", group = "anonymous Apex" },
					{ "<leader>tt", group = "tests" },
					{ "<leader>tq", group = "query" },
				})
			end
		end,
	},
}
