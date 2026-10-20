local home = os.getenv("HOME") -- in my case return 'Users/liusam'
local function setup()
	local dated_paths = {
		home .. "/Downloads", --concadenamos 'Users/liusam' con '/Downloads'
		home .. "/.local/share/Trash/files",
		home .. "/Pictures/Fototeca de Photo Booth/Pictures", --Only for MacOS
		home .. "/Movies",
		home .. "/.Trash",
	}

	ps.sub("cd", function()
		local cwd = cx.active.current.cwd
		-- 2. Normalizar el path para una mejor comparación (opcional, pero buena práctica)
		local current_path = tostring(cwd)

		-- 3.  verificar si el path actual está en la tabla
		local is_dated_path = false
		for _, path in ipairs(dated_paths) do
			if current_path == path or current_path:match(path .. "/.+$") then
				is_dated_path = true
				break
			end
		end
		-- 3.1 La papelera nativa (g+t) no es una ruta del disco sino una URL virtual "trash://...",
		-- asi que nunca coincide con home .. "/.Trash". Se detecta por el esquema (incluye subcarpetas).
		-- La papelera nativa de Yazi es un lugar virtual. trash://... no es una carpeta del disco, sino una dirección que Yazi inventó para poder hablar con la papelera.
		-- ventaja: Yazi puede manejar la papelera igual en cualquier sistema
		if not is_dated_path and current_path:find("^trash:") then
			is_dated_path = true
		end
		if is_dated_path then
			-- Aplica la regla  cualquier path en dated_paths
			ya.emit("sort", { "mtime", reverse = true, dir_first = false })
		else
			-- Aplica la regla por defecto para el resto de directorios
			ya.emit("sort", { "alphabetical", reverse = false, dir_first = true })
		end
	end)
end

return { setup = setup }
