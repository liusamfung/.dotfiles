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

--- Project-wide push/retrieve, behind a confirmation that names the target org. On orgs with source tracking
--- (scratch, some sandboxes) they only move what changed; on the rest they move the whole package, so ask first.
local function confirm_project(fn_name, verb)
	return function()
		local ok, org = pcall(function()
			return require("sf").get_target_org()
		end)
		-- no target org: let sf.nvim show its own "Target_org empty!" error
		if not ok or org == "" then
			return require("sf")[fn_name]()
		end
		local msg = ("%s project changes with %s?"):format(verb, org)
		if vim.fn.confirm(msg, "&Yes\n&No", 2) == 1 then
			require("sf")[fn_name]()
		end
	end
end

---@param dir string
---@return integer number of generated sObject stubs (*.cls) in a standardObjects/customObjects tree
local function count_stubs(dir)
	return #vim.fn.glob(dir .. "/*/*.cls", false, true)
end

--- <leader>tS: `:SF sobject refresh` with progress in the lualine (config/sf_status.lua).
--- sf.nvim has no progress hook, so the percentage is estimated: stubs written so far in the staging folder
--- divided by the stubs of the previous refresh (on the first refresh of a project only the count is shown).
--- The end is detected from sf.nvim's own final message (see `intercept` below).
local function refresh_sobjects()
	local status = require("config.sf_status")
	local ok, root = pcall(require("sf.util").get_sf_root)
	if not ok then
		-- outside a project sf.nvim explains why it cannot run
		return require("sf").refresh_sobjects()
	end
	if status.running() then
		return vim.notify("Another SF task is still running", vim.log.levels.WARN)
	end
	root = root:gsub("/$", "")

	local staging = root .. "/.sfdx/tools/sobjects-refresh"
	local previous = count_stubs(root .. "/.sfdx/tools/sobjects")
	local started_at = os.time()
	local settled = false

	-- sf.nvim reports every outcome through these three functions of its util module (they are looked up at call
	-- time), so they are wrapped for the duration of the refresh. vim.notify is NOT touched: Noice warns when
	-- something replaces it.
	local U = require("sf.util")
	local originals = { show = U.show, show_err = U.show_err, show_warn = U.show_warn }

	local function settle(success)
		if settled then
			return
		end
		settled = true
		for name, fn in pairs(originals) do
			U[name] = fn
		end
		status.finish(success, "sObjects")
	end

	local function intercept(name, is_success)
		U[name] = function(msg, ...)
			originals[name](msg, ...)
			if type(msg) == "string" and not msg:match("^Refreshing sObject") then
				settle(is_success(msg))
			end
		end
	end
	local function refreshed(msg)
		return msg:find("refreshed (", 1, true) ~= nil
	end
	intercept("show", refreshed)
	intercept("show_warn", refreshed) -- "refreshed (N objects); M could not be described ..." still counts as done
	intercept("show_err", function()
		return false
	end)

	status.start(function()
		-- a staging folder older than this press is left over from an interrupted refresh: ignore it
		local stat = vim.uv.fs_stat(staging)
		local written = (stat and stat.mtime.sec >= started_at) and count_stubs(staging) or 0
		if previous > 0 then
			return ("sObjects %d%%"):format(math.min(99, math.floor(written * 100 / previous)))
		end
		return ("sObjects %d"):format(written)
	end)
	-- safety net: never leave the spinner on if sf.nvim's final message is missed
	vim.defer_fn(function()
		settle(false)
	end, 10 * 60 * 1000)

	require("sf").refresh_sobjects()
end

--- <leader>tv: dry-run validation of the current file (sf_compile linter in nvim-lint.lua), with a spinner and
--- the elapsed seconds (the CLI gives no progress in --json mode) and a final check / cross in the lualine.
local function validate_file()
	local lint = require("lint")
	local status = require("config.sf_status")
	local buf = vim.api.nvim_get_current_buf()
	if status.running() then
		return vim.notify("Another SF task is still running", vim.log.levels.WARN)
	end

	status.compile_result = nil
	status.start(function(elapsed)
		return ("validating %ds"):format(elapsed)
	end)
	lint.try_lint("sf_compile")

	local timer = vim.uv.new_timer()
	timer:start(
		300,
		200,
		vim.schedule_wrap(function()
			if vim.tbl_contains(lint.get_running(buf), "sf_compile") then
				return
			end
			timer:stop()
			timer:close()

			local result = status.compile_result
			local ns = lint.get_namespace("sf_compile")
			local shown = ns and #vim.diagnostic.get(buf, { namespace = ns }) or 0
			if result and result.error then
				vim.notify("sf validate: " .. result.error, vim.log.levels.WARN)
				return status.finish(false, "validate failed")
			end
			local errors = math.max(shown, result and result.failures or 0)
			if errors > 0 then
				return status.finish(false, ("validate: %d error(s)"):format(errors))
			end
			if result and result.ok then
				return status.finish(true, "validated")
			end
			status.finish(false, "validate: no result")
		end)
	)
end

local anonymous = { win = nil, cursor = nil }

--- <leader>te: toggle a floating "Execute Anonymous" window, like Developer Console's.
--- It edits a real file, <project>/.sfdx/anonymous.apex (git ignores .sfdx), so the snippet survives restarts and
--- apex_ls attaches to it: completion works, sObject fields included. <leader><CR> runs the buffer (or the selection
--- in Visual mode) through sf.nvim, whose floating terminal shows the log (the window hides itself on run so it does not cover
--- it); <leader>te or q hide it too.
--- A plain <CR> deliberately does nothing special: running code in the org must not happen by accident.
local function toggle_anonymous()
	if anonymous.win and vim.api.nvim_win_is_valid(anonymous.win) then
		anonymous.cursor = vim.api.nvim_win_get_cursor(anonymous.win)
		local buf = vim.api.nvim_win_get_buf(anonymous.win)
		if vim.bo[buf].modified then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("silent noautocmd write") -- noautocmd: no prettier on a half-written snippet
			end)
		end
		vim.api.nvim_win_close(anonymous.win, true)
		anonymous.win = nil
		return
	end

	local ok, root = pcall(require("sf.util").get_sf_root)
	if not ok then
		return vim.notify("Not inside a Salesforce project", vim.log.levels.WARN)
	end
	local path = root:gsub("/$", "") .. "/.sfdx/anonymous.apex"
	if not vim.uv.fs_stat(path) then
		vim.fn.mkdir(vim.fs.dirname(path), "p")
		vim.fn.writefile({
			"// Execute Anonymous. <leader><CR> runs the whole buffer (or the Visual selection). q hides this window.",
			"System.debug('Hello');",
		}, path)
	end

	local buf = vim.fn.bufadd(path)
	vim.fn.bufload(buf)
	vim.bo[buf].buflisted = false
	vim.bo[buf].filetype = "apex"

	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.5)
	anonymous.win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2) - 1,
		style = "minimal",
		border = "rounded",
		title = " Execute Anonymous ",
		title_pos = "center",
		footer = " <leader><CR> run   q / <leader>te hide ",
		footer_pos = "center",
	})
	vim.wo[anonymous.win].number = true
	vim.wo[anonymous.win].signcolumn = "no"
	if anonymous.cursor then
		pcall(vim.api.nvim_win_set_cursor, anonymous.win, anonymous.cursor)
	end

	local function map(modes, lhs, rhs, desc)
		vim.keymap.set(modes, lhs, rhs, { buffer = buf, desc = "SF: " .. desc })
	end
	local function run(selection)
		return function()
			if not selection then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("silent noautocmd write")
				end)
			end
			require("sf").run_anonymous_stdin(selection)
			-- hide this window so it does not cover the log in sf.nvim's terminal
			toggle_anonymous()
		end
	end
	map("n", "<leader><CR>", run(false), "execute the whole snippet")
	map("x", "<leader><CR>", run(true), "execute the selection")
	map("n", "q", toggle_anonymous, "hide the Execute Anonymous window")
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

			-- Current file (lowercase)
			{ "<leader>tp", sf("save_and_push"), desc = "SF: push current file (saves first)" },
			{ "<leader>tr", sf("retrieve"), desc = "SF: retrieve current file" },
			{ "<leader>td", sf("diff_in_target_org"), desc = "SF: diff current file vs target org" },
			{ "<leader>tD", sf("diff_in_org"), desc = "SF: diff current file vs org..." },
			{ "<leader>tx", sf("org_open_current_file"), desc = "SF: open current file in org" },

			-- Whole project (uppercase of the file keys above)
			{ "<leader>tP", confirm_project("push_delta", "Push"), desc = "SF: push PROJECT changes" },
			{ "<leader>tR", confirm_project("retrieve_delta", "Retrieve"), desc = "SF: retrieve PROJECT changes" },

			-- Destructive: they change the org AND delete/rename local files
			{
				"<leader>tXr",
				sf("rename_apex_class_remote_and_local"),
				desc = "SF: rename Apex class (org + local)",
			},
			{
				"<leader>tXd",
				sf("delete_current_apex_remote_and_local"),
				desc = "SF: delete Apex class (org + local)",
			},

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
			{ "<leader>tS", refresh_sobjects, desc = "SF: refresh sObject definitions (apex_ls)" },

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
			{ "<leader>ttO", sf("run_local_tests"), desc = "SF: ALL local Apex tests in the org + coverage" },
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
				validate_file,
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
			{ "<leader>te", toggle_anonymous, desc = "SF: toggle Execute Anonymous window" },
		},

		config = function(_, opts)
			require("sf").setup(opts)

			-- sf.nvim fetches the org list (which gives the target org shown in lualine) from a VimEnter
			-- autocmd. With VeryLazy the plugin loads after VimEnter, so that autocmd never fires: fetch here.
			if vim.v.vim_did_enter == 1 and vim.fn.executable("sf") == 1 then
				require("sf").fetch_org_list()
			end

			-- sf.nvim gives the focus back to the window you were in right after it opens its terminal, so the log
			-- could only be scrolled after clicking into it. Once a command has FINISHED, move the focus to the
			-- terminal. While it is still running the focus is left alone, so typing elsewhere is not hijacked.
			vim.api.nvim_create_autocmd("BufWinEnter", {
				group = vim.api.nvim_create_augroup("SfTermFocus", { clear = true }),
				desc = "Focus sf.nvim's terminal when a command has finished",
				callback = function(args)
					if vim.bo[args.buf].filetype ~= "SFTerm" then
						return
					end
					local job = vim.b[args.buf].terminal_job_id
					if not job or vim.fn.jobwait({ job }, 0)[1] == -1 then
						return
					end
					-- schedule: sf.nvim restores the previous window synchronously after opening the terminal
					vim.schedule(function()
						local win = vim.fn.bufwinid(args.buf)
						if win ~= -1 then
							vim.api.nvim_set_current_win(win)
						end
					end)
				end,
			})

			local ok, wk = pcall(require, "which-key")
			if ok then
				wk.add({
					{ "<leader>t", group = "Salesforce" },
					{ "<leader>tc", group = "create" },
					{ "<leader>to", group = "orgs" },
					{ "<leader>ta", group = "anonymous Apex" },
					{ "<leader>tt", group = "tests" },
					{ "<leader>tq", group = "query" },
					{ "<leader>tX", group = "destructive (org + local)" },
				})
			end
		end,
	},
}
