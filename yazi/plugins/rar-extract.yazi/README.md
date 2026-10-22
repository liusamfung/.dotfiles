# rar-extract.yazi

Extrae archivos `.rar` desde Yazi con `ouch` y **pide la contraseña** (cuadro oculto de Yazi) si el archivo está cifrado.

## Por qué existe

El extractor nativo de Yazi usa `7zz`, y con ciertos `.rar` falla:

- **RAR de WinRAR 7 (método `v6`):** `7zz` responde `Unsupported Method` **aunque la contraseña sea correcta**.
- **RAR5 cifrados:** `7zz` no dice `Wrong password` (que es lo que Yazi busca para abrir el cuadro de contraseña),
  así que Yazi falla en silencio y nunca pregunta.

`ouch` sí los extrae, pero tampoco pregunta: falla con un mensaje que contiene `password`.
Este plugin detecta ese caso, pregunta y reintenta.

Probado con un RAR5 cifrado (AES) de 3 volúmenes, 50 archivos y 5.1 GB: los bytes extraídos coinciden exactos con los del archivo.

## Requisitos

- Yazi `>= 26.8.15`.
- `ouch` en el PATH (está en el `Brewfile`) **compilado con soporte RAR**. Es una función opcional (`unrar`) que viene
  activada por defecto y en los binarios oficiales, pero algunas distribuciones la quitan por la licencia de RAR.
  Para comprobarlo: `ouch --help | grep -i rar` debe listar `rar`.
- Pensado para macOS y Linux (el plugin solo usa la API de Yazi y `ouch`, y el opener usa `for = "unix"`),
  pero **solo está probado en macOS**.

## Instalación

Plugin local, no se instala con `ya pkg`. Tres piezas:

`init.lua`:

```lua
require("rar-extract"):setup()
```

`yazi.toml`:

```toml
[open]
prepend_rules = [
  { mime = "application/{rar,x-rar,vnd.rar}", use = [ "rar", "extract", "reveal" ] },
]

[opener]
rar = [
  { run = 'ya pub rar-extract --list %s', desc = "Extract RAR (ouch)", for = "unix" },
]
```

El opener `extract` de la regla es el nativo de Yazi (7zz), que queda como segunda opción en `Shift+O`.

## Uso

Sobre un `.rar`, `o` (o `Enter`). Si está cifrado aparece `Password for "archivo.rar":`.
Con una contraseña incorrecta vuelve a preguntar. Para cancelar: `Escape` **dos veces**
(la primera sale del modo de edición del cuadro).

## Cómo funciona

1. El opener publica el evento `rar-extract` con `ya pub` (igual que el opener `extract` de fábrica).
2. El plugin lo recibe en `setup()` y lanza una tarea de Yazi por archivo.
3. Extrae con `ouch d -y [-p CONTRASEÑA] -d <carpeta temporal> <archivo>`.
4. Si `ouch` falla y su salida contiene `password` (en minúsculas: `ouch` no distingue por código de salida),
   borra lo extraído, pide la contraseña y reintenta.
5. Acomoda el resultado (copiado del extractor nativo): un solo elemento queda tal cual; varios, en una carpeta con el
   nombre del archivo. **Nunca sobrescribe**: si ya existe, crea `_1`, `_2`...

### Volúmenes (`.part1.rar`, `.part2.rar`...)

- Si abres la parte 2, 3... empieza por la parte 1 (si existe). También `.r00` → `.rar`.
- Si seleccionas varias partes y pulsas `o`, se extrae **una sola vez** y se abre un solo cuadro de contraseña.
- Hacen falta **todas las partes completas** en la misma carpeta. Si alguna se está descargando, falla.

## Límites

- Si seleccionas varios `.rar` distintos y alguno tiene contraseña, falla con un aviso para extraerlo individualmente
  (igual que el extractor nativo).
- La contraseña viaja como argumento de `ouch` (`-p`), por lo que es visible un instante en la lista de procesos local.
- Extrae primero a una carpeta temporal dentro de la carpeta del archivo: necesita espacio libre para el contenido completo.
