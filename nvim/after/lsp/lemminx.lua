-- Salesforce metadata schemas, vendored in nvim/schemas/salesforce (no VS Code needed).
-- See nvim/schemas/salesforce/README.md for their origin and the local patches.
local schemas = vim.fn.stdpath("config") .. "/schemas/salesforce"

return {
	settings = {
		xml = {
			catalogs = { schemas .. "/metadata-catalog.xml" },
			fileAssociations = {
				-- LWC has its own, more precise schema
				{ pattern = "**/*.js-meta.xml", systemId = schemas .. "/js-meta.xsd" },
				-- every other *-meta.xml (Apex, objects, layouts...) and package.xml
				{ pattern = "**/*-meta.xml", systemId = schemas .. "/salesforce_metadata_api_namespace1.xsd" },
				{ pattern = "**/package.xml", systemId = schemas .. "/salesforce_metadata_api_namespace1.xsd" },
			},
			validation = {
				-- the XSD is generated from the docs and rejects ~7% of real files:
				-- use it for completion/hover only, not for red squiggles
				schema = { enabled = "never" },
			},
		},
	},
}
