--- @since 26.8.15
-- Extrae archivos .rar con `ouch` y pide la contrasena (cuadro oculto de Yazi) si hace falta.
--
-- Por que existe: el extractor nativo de Yazi usa 7zz, y 7zz no puede con los RAR de WinRAR 7 (da
-- "Unsupported Method" aunque la contrasena sea correcta) y reporta mal los RAR5 cifrados, asi que Yazi
-- nunca pide la contrasena. `ouch` si los extrae, pero tampoco pregunta: falla con un mensaje que
-- contiene "password". Este plugin detecta ese caso, pregunta y reintenta.
--
-- Se activa con un opener que publica el evento (igual que el opener `extract` de fabrica):
--   run = 'ya pub rar-extract --list %s'
-- y con `require("rar-extract"):setup()` en init.lua. Requiere `ouch` en el PATH (esta en el Brewfile).
--
-- Comportamiento (copiado del extractor nativo): extrae a una carpeta temporal y luego la acomoda:
-- si el archivo trae un solo elemento queda tal cual; si trae varios, en una carpeta con el nombre del
-- archivo. Nunca sobrescribe: si ya existe, agrega _1, _2...
-- Extras: si abres la parte 2, 3... de un .partN.rar empieza por la parte 1, y si seleccionas varias
-- partes se extrae una sola vez.

local function fail(s, ...) error(string.format(s, ...)) end

local M = {}

-- HSPA.part2.rar -> HSPA.part1.rar (y HSPA.r00 -> HSPA.rar) si la primera parte existe.
function M.first_volume(path)
	local candidates = {}
	local a, n, c = path:match("^(.*[%.][Pp][Aa][Rr][Tt])(%d+)([%.][Rr][Aa][Rr])$")
	if a and tonumber(n) > 1 then
		candidates[#candidates + 1] = a .. string.rep("0", #n - 1) .. "1" .. c
	end
	local base = path:match("^(.*)[%.][Rr]%d%d$")
	if base then
		candidates[#candidates + 1] = base .. ".rar"
		candidates[#candidates + 1] = base .. ".RAR"
	end
	for _, first in ipairs(candidates) do
		if fs.cha(Url(first), true) then
			return first
		end
	end
	return path
end

function M:setup()
	ps.sub_remote("rar-extract", function(args)
		ya.async(function()
			local seen, list = {}, {}
			for _, arg in ipairs(args) do
				local first = M.first_volume(arg)
				if not seen[first] then
					seen[first], list[#list + 1] = true, first
				end
			end
			for i, arg in ipairs(list) do
				local in_ = {
					self._id or "rar-extract",
					args = { arg, "", noisy = #list == 1 },
					track = i == 1,
				}
				ya.task("plugin", in_):name("Extract " .. arg):spawn()
			end
		end)
	end)
end

function M:init(job)
	local from = job.args[1] and Url(job.args[1])
	if not from then
		fail("No URL provided")
	end

	local to = job.args[2] ~= "" and Url(job.args[2]) or from.parent
	if not to then
		fail("Failed to determine target directory for '%s'", from)
	end

	self.job = { id = job.id, from = from, to = to }
end

function M:entry(job)
	self:init(job)

	local pwd, target, retry = "", nil, false
	while true do
		target, retry = self:try_with(pwd)
		if not retry then
			break
		elseif not job.args.noisy then
			fail("'%s' is password-protected, please extract it individually and enter the password", self.job.from)
		end

		local value, event = ya.input {
			pos = { "top-center", y = 2, w = 50 },
			title = string.format('Password for "%s":', self.job.from.name),
			obscure = true,
		}
		if event == 1 then
			pwd = value
		else
			break
		end
	end

	if target then
		ya.emit("tasks:update_succeed", { job.id, urls = { target }, track = true })
	end
end

function M:try_with(pwd)
	local from, to = self.job.from, self.job.to
	local tmp = fs.unique("dir", to:join(self.tmp_name(from)))
	if not tmp then
		fail("Failed to determine a temporary directory for %s", from)
	end

	-- ouch crea la carpeta de destino. stdin cerrado: nunca debe quedarse esperando algo en una terminal.
	local args = { "d", "-y" }
	if pwd ~= "" then
		args[#args + 1], args[#args + 2] = "-p", pwd
	end
	args[#args + 1], args[#args + 2], args[#args + 3] = "-d", tostring(tmp), tostring(from)

	local child, err = Command("ouch"):arg(args):stdin(Command.NULL):stdout(Command.PIPED):stderr(Command.PIPED):spawn()
	if not child then
		fail("Failed to start `ouch` (is it installed?), error: %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		fs.remove("dir_all", tmp)
		fail("ouch failed to output when extracting '%s', error: %s", from, err)
	elseif output.status.code ~= 0 then
		fs.remove("dir_all", tmp)
		-- ouch no distingue por codigo de salida: todos sus errores de contrasena (faltante o incorrecta,
		-- en zip/7z/rar) incluyen la palabra "password".
		if (output.stdout .. output.stderr):lower():find("password", 1, true) then
			return nil, true -- Hay que pedir (o reintentar) la contrasena
		end
		fail("ouch exited with code %s when extracting '%s':\n%s%s", output.status.code, from, output.stdout, output.stderr)
	end

	return self:tidy(tmp), false
end

function M:tidy(tmp)
	local from, to = self.job.from, self.job.to
	local outs = fs.read_dir(tmp, { limit = 2 })
	if not outs then
		fail("Failed to read the temporary directory '%s' when extracting '%s'", tmp, from)
	elseif #outs == 0 then
		fs.remove("dir", tmp)
		fail("No files extracted from '%s'", from)
	end

	local only = #outs == 1 and outs[1]
	local target = to:join(only and only.name or self.trim_ext(from.name))
	target = fs.unique(only and not only.cha.is_dir and "file" or "dir", target)
	if not target then
		fail("Failed to determine a target for '%s'", from)
	end

	if only and not fs.rename(only.url, target) then
		fail('Failed to move "%s" to "%s"', only.url, target)
	elseif not only and not fs.rename(tmp, target) then
		fail('Failed to move "%s" to "%s"', tmp, target)
	end

	fs.remove("dir", tmp)
	return target
end

function M.tmp_name(url) return ".tmp_" .. ya.hash(string.format("rar-extract//%s//%.10f", url, ya.time())) end

-- HSPA.part1.rar -> HSPA, backup.rar -> backup
function M.trim_ext(name)
	name = name:gsub("%.[Rr][Aa][Rr]$", ""):gsub("%.[Pp][Aa][Rr][Tt]%d+$", ""):gsub("%.[Rr]%d%d$", "")
	return name ~= "" and name or "extracted"
end

return M
