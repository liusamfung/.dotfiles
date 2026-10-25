return {
	-- Run :NvimWebDeviconsHiTest to see all icons and their highlighting.
	{
		"nvim-tree/nvim-web-devicons",
		-- devicons only knows exact file names and extensions, never patterns. Apex test classes
		-- (TestFoo.cls, FooTest.cls, FooTests.cls) are found by name here, and the icon below is
		-- looked up under a fixed fake file name. Yazi does the same with globs in yazi/theme.toml.
		opts = {
			override_by_filename = {
				["apex-test-class.cls"] = {
					icon = "󰅣",
					color = "#00A1E0",
					name = "ApexTestFile",
				},
			},
			override_by_extension = {
				["apex"] = {
					icon = "",
					color = "#00A1E0",
					name = "ApexFile",
				},
				["cls"] = {
					icon = "",
					color = "#00A1E0",
					name = "ApexFile",
				},
				["trigger"] = {
					icon = "",
					color = "#00A1E0",
					name = "ApexFile",
				},
				["soql"] = {
					icon = "",
					color = "#00A1E0",
					name = "SOQL",
				},
				["code-workspace"] = {
					icon = " ",
					color = "#cbcb41",
					name = "JsonAdd",
				},
			},
		},

		-- fixing barbecue Test icon for salesforce icons
		config = function(_, opts)
			local devicons = require("nvim-web-devicons")
			devicons.setup(opts)
			local function is_apex_test(name)
				if type(name) ~= "string" then
					return false
				end
				local file = vim.fs.basename(name)
				return file:match("^Test%u.*%.cls$") ~= nil or file:match("Tests?%.cls$") ~= nil
			end
			for _, fn in ipairs({ "get_icon", "get_icon_colors", "get_icon_cterm_color" }) do
				local original = devicons[fn]
				devicons[fn] = function(name, ext, o)
					if is_apex_test(name) then
						name = "apex-test-class.cls"
					end
					return original(name, ext, o)
				end
			end
			-- barbecue (the bar at the top) does not call get_icon: it reads the raw table from get_icons() and
			-- indexes it with the file name. A missing key falls through to this __index, which answers for test
			-- classes. devicons builds a new table when it refreshes its icons, so it is re-applied on every call.
			local get_icons = devicons.get_icons
			devicons.get_icons = function()
				local icons = get_icons()
				if getmetatable(icons) == nil then
					setmetatable(icons, {
						__index = function(t, key)
							if is_apex_test(key) then
								return rawget(t, "apex-test-class.cls")
							end
						end,
					})
				end
				return icons
			end
		end,
	},
}
