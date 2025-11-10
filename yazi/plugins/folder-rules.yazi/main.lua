local home = os.getenv("HOME") -- in my case return 'Users/liusam'
local function setup()
	local dated_paths = {
		home .. "/Downloads", --concadenamos 'Users/liusam' con '/Downloads'
		home .. "/.local/share/Trash/files",
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
