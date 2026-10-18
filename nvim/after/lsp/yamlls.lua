return {
	settings = {
		yaml = {
			-- schemaStore built into yaml-language-server is replaced by this one (better matching)
			schemaStore = { enable = false, url = "" },
			schemas = require("schemastore").yaml.schemas(),
		},
	},
}
