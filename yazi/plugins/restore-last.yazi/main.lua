--- @since 26.8.15
-- Restaura el ULTIMO lote borrado (uno o varios archivos) desde la papelera nativa de Yazi (g+t).
-- Reemplaza a restore.yazi, que dependia de trash-cli y no ve la papelera del Finder.
--
-- Yazi no guarda la fecha de borrado, pero mover un archivo a la papelera cambia su `ctime`
-- (el `mtime` y `btime` no cambian). Se usa ese `ctime` para agrupar: los archivos borrados en la
-- misma operacion quedan a segundos de distancia entre si.
--
-- Uso:  { on = "u", run = "plugin restore-last" }
--       { on = "u", run = "plugin restore-last -- --no-confirm" }   -- sin dialogo de confirmacion
--       { on = "u", run = "plugin restore-last -- --no-reveal" }    -- sin saltar a la carpeta de origen

local M = {}

-- Dos archivos pertenecen al mismo lote si sus ctime estan a menos de GAP segundos.
local GAP = 2
local MAX_SHOWN = 8

local function notify(level, content)
	ya.notify { title = "Restore", content = content, level = level, timeout = 6 }
end

-- Momento en que el archivo entro a la papelera (ctime del propio enlace/archivo).
local function trashed_at(ent)
	local cha = ent.lcha or ent.cha
	return cha and (cha.ctime or cha.mtime) or 0
end

-- Devuelve las entradas del lote mas reciente, de la mas nueva a la mas vieja.
-- Se encadena por distancia al anterior (no a la mas nueva) para que un lote largo no se corte.
local function last_batch(ents)
	local items = {}
	for _, ent in ipairs(ents) do
		-- Finder mantiene su .DS_Store dentro de ~/.Trash; cambia seguido y no es un archivo borrado.
		if ent.name ~= ".DS_Store" then
			items[#items + 1] = { ent = ent, ts = trashed_at(ent) }
		end
	end
	table.sort(items, function(a, b)
		return a.ts > b.ts
	end)

	local batch = {}
	for i, item in ipairs(items) do
		if i > 1 and items[i - 1].ts - item.ts > GAP then
			break
		end
		batch[#batch + 1] = item.ent
	end
	return batch
end

-- /Users/liusam/Downloads -> ~/Downloads (solo para mostrarlo en el aviso)
local function short(path)
	local home = os.getenv("HOME")
	if home and home ~= "" and path:sub(1, #home) == home then
		return "~" .. path:sub(#home + 1)
	end
	return path
end

local function describe(batch)
	local lines = {}
	for i, ent in ipairs(batch) do
		if i > MAX_SHOWN then
			lines[#lines + 1] = string.format("... y %d mas", #batch - MAX_SHOWN)
			break
		end
		lines[#lines + 1] = "  " .. ent.name
	end
	return lines
end

function M:entry(job)
	local ents, err = fs.trash.list()
	if not ents then
		return notify("error", "No se pudo leer la papelera: " .. tostring(err))
	end

	local batch = last_batch(ents)
	if #batch == 0 then
		return notify("info", "La papelera esta vacia")
	end

	if not job.args["no-confirm"] then
		local confirmed = ya.confirm {
			pos = { "center", w = 70, h = math.min(#batch, MAX_SHOWN + 1) + 4 },
			title = ui.Line(string.format("Restaurar %d elemento(s)?", #batch)):style(th.confirm.title),
			body = ui.Text(table.concat(describe(batch), "\n")),
		}
		if not confirmed then
			return
		end
	end

	local restored, failed, first_err = 0, 0, nil
	local first_url, dirs, seen = nil, {}, {}
	for _, ent in ipairs(batch) do
		-- fs.trash.restore CONSUME la entrada (queda destruida, aunque falle): hay que leer todo antes.
		local url = ent.original and Url(ent.original)
		local ok, e = fs.trash.restore { ent }
		if ok then
			restored = restored + 1
			if url then
				first_url = first_url or url
				local dir = url.parent and short(tostring(url.parent))
				if dir and not seen[dir] then
					seen[dir], dirs[#dirs + 1] = true, dir
				end
			end
		else
			failed, first_err = failed + 1, first_err or e
		end
	end

	if restored > 0 then
		ya.emit("refresh", {})
		-- Lleva la vista a la carpeta de origen y deja seleccionado el archivo mas reciente restaurado.
		if first_url and not job.args["no-reveal"] then
			ya.emit("reveal", { first_url })
		end
	end

	local where = #dirs > 0 and (" en " .. table.concat(dirs, ", ")) or ""
	if failed > 0 then
		notify(
			"error",
			string.format("%d restaurado(s)%s, %d fallaron: %s", restored, where, failed, tostring(first_err))
		)
	else
		notify("info", string.format("%d elemento(s) restaurado(s)%s", restored, where))
	end
end

-- Expuesto solo para probar la logica de agrupacion fuera de Yazi.
M._last_batch = last_batch

return M
