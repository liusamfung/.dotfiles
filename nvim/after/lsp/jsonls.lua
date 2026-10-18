return {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas({
				extra = {
					{
						-- SchemaStore ships this schema without a fileMatch (app.json is a too generic name)
						name = "Expo SDK 57 app.json",
						description = "Expo app manifest",
						fileMatch = { "app.json" },
						url = "https://www.schemastore.org/expo-57.0.0.json",
					},
				},
			}),
			validate = { enable = true },
		},
	},
}
