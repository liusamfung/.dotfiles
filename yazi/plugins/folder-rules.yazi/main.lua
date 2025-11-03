local function setup()
	ps.sub("cd", function()
		local cwd = cx.active.current.cwd
		-- Para el directorio con nombre 'Downloads', aplicará la siguiente regla,
		-- de otro modo, A todos los demás directórios les asignará la reglas del 'else'
		if cwd:ends_with("Downloads") then
			ya.emit("sort", { "mtime", reverse = true, dir_first = false })
		else
			ya.emit("sort", { "alphabetical", reverse = false, dir_first = true })
		end
	end)
end

return { setup = setup }
