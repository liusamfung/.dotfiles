return {
	settings = {
		xml = {
			catalogs = {
				-- Version de vscode (Necesitas descargarte el editor de codigo y
				-- descargar su pack de extensiones para que te arroje este archivo)
				-- vim.fn.glob(
				-- 	"~/.vscode/extensions/salesforce.salesforcedx-vscode-lwc*/resources/static/js-meta-home.xml"
				-- ),
				-- Pero también se puede obtener ese mismo archivo clonando el repositorio ofical de salesforce y obteniendo
				-- Y solo tienes que hacer ´git pull' cada vez que quieras "actualizar" este archivo.
				-- git clone https://github.com/forcedotcom/salesforcedx-vscode.git
				vim.fn.glob(
					"~/.vscode/extensions/salesforce.salesforcedx-vscode-lwc*/resources/static/js-meta-home.xml"
				),
			},
		},
	},
}
