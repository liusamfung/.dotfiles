# restore-last.yazi

Restaura con una tecla **lo último que borraste** (uno o varios archivos) desde la papelera nativa de Yazi.

Reemplaza a [`restore.yazi`](https://github.com/boydaihungst/restore.yazi) y [`recycle-bin.yazi`](https://github.com/uhs-robert/recycle-bin.yazi),
ambos obsoletos. Dependían de `trash-cli`, que solo lee la papelera estilo Linux (`~/.local/share/Trash`)
y **no ve la papelera del Finder** (`~/.Trash`), que es a donde va `d` desde que Yazi tiene su papelera nativa.

## Requisitos

- Yazi `>= 26.8.15` (versión que introdujo la papelera nativa, `g` `t`).
- macOS. Está probado ahí. En Linux y Windows usa otro backend de papelera y no lo he probado.
- No necesita `trash-cli` ni ninguna otra herramienta externa.

## Instalación

Es un plugin local, no se instala con `ya pkg`. Vive en `yazi/plugins/restore-last.yazi/`.

En `keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = "u"
run = "plugin restore-last"
desc = "Restore last deleted files/folders (native trash)"
```

Opciones (se combinan, p. ej. `-- --no-confirm --no-reveal`):

| Opción | Efecto |
|---|---|
| `--no-confirm` | Salta el diálogo de confirmación |
| `--no-reveal` | No cambia de carpeta después de restaurar |

```toml
run = "plugin restore-last -- --no-confirm"
```

## Uso

1. Borra uno o varios archivos con `d`.
2. Presiona `u` en cualquier carpeta.
3. Aparece una lista con lo que se va a restaurar. Confirma y vuelve cada elemento a su carpeta original.
4. Yazi **salta a esa carpeta** y deja seleccionado el archivo restaurado. Esto sirve cuando restauras desde otra carpeta
   (o desde la papelera) y no recuerdas dónde estaba cada cosa.
5. Un aviso indica a qué carpetas volvió todo, por ejemplo: `3 elemento(s) restaurado(s) en ~/Desktop, ~/Documents/Work`.

## Cómo funciona

### De dónde saca "lo último"

Yazi no guarda la fecha en que borraste cada archivo, pero mover algo a la papelera cambia su **`ctime`**
(la última vez que cambió el registro del archivo en el sistema). Su `mtime` (contenido) y `btime` (creación)
no cambian. Entonces el plugin usa el `ctime` como "momento en que se borró".

Lo comprobé en APFS: un archivo y una carpeta movidos pasaron de `ctime` 08:38:38 a 08:38:40 sin tocar `mtime` ni `btime`.

### Cómo arma el lote

1. Lista la papelera con `fs.trash.list()`.
2. Ordena las entradas por `ctime`, de la más nueva a la más vieja. Este orden es **interno del plugin**:
   no cambia cómo se ve la carpeta en pantalla (eso lo decide `folder-rules`, ver más abajo).
3. Toma la más reciente y va sumando las siguientes mientras cada una esté a **menos de 2 segundos** de la anterior.
   Se compara con la anterior y no con la más reciente, así un borrado grande que tarde varios segundos no se corta.
4. Se detiene en el primer hueco de más de 2 segundos. Lo que quede más viejo es otro borrado y no se toca.

### Después de restaurar

- Refresca la vista y ejecuta `reveal` sobre el **archivo más reciente** que se restauró con éxito:
  Yazi entra a su carpeta original y lo deja seleccionado.
- Si el lote se repartió en varias carpetas, solo se salta a una (la del más reciente), pero el aviso lista **todas**,
  así sabes dónde buscar el resto.
- Si el más reciente falló (por ejemplo, por un nombre repetido), salta al primero que sí volvió.
- Si nada se restauró, no cambia de carpeta.
- Con `--no-reveal` se queda donde estaba, y el aviso sigue indicando las carpetas.

### Qué ignora

El `.DS_Store` que el Finder mantiene dentro de `~/.Trash`. Cambia cada vez que el Finder lo toca y,
si no se ignorara, siempre parecería lo último que borraste.

## Relación con `folder-rules`

No hay conflicto. Son independientes:

| | Qué hace | Cuándo corre |
|---|---|---|
| `folder-rules` | Ordena la **vista** de la carpeta (por fecha en la papelera, alfabético en el resto) | Cada vez que cambias de carpeta |
| `restore-last` | Calcula el lote a restaurar | Solo cuando presionas `u` |

`restore-last` no emite ningún comando `sort` ni se suscribe a eventos. Si compartes este plugin con alguien
y quieres que la papelera se vea ordenada por fecha, necesita también un plugin como `folder-rules`
que reconozca la URL `trash:` (la papelera nativa no es una ruta del disco).

## Límites

- **Nombres repetidos:** si en la carpeta original ya existe un archivo con el mismo nombre, no lo sobrescribe
  y lo reporta como fallo. Para ese caso usa el restore nativo (`Shift+O` sobre el archivo, en la papelera), que sí combina carpetas.
- **Borrados seguidos:** dos borrados hechos con menos de 2 segundos de diferencia se tratan como uno solo.
  Se cambia con la constante `GAP` en `main.lua`.
- **Sin ruta de origen:** los elementos que se borraron con una herramienta que no dejó el dato "Put Back"
  no se pueden restaurar y aparecen en el aviso de fallos.
- **No restaura la papelera de `trash-cli`:** solo ve la del sistema. Si algo se borró con `trash-put`, no aparece aquí.

## Nota de implementación

`fs.trash.restore { ent }` **consume** la entrada: después de llamarla (haya tenido éxito o no), cualquier acceso
a `ent.original`, `ent.name`, etc. falla con `userdata has been destructed`. Por eso `main.lua` lee la ruta de origen
**antes** de restaurar. El plugin nativo de Yazi hace lo mismo (copia `top` y `rel` antes de restaurar).

## Probar la lógica sin Yazi

La función de agrupación está expuesta como `M._last_batch` para poder probarla con un intérprete de Lua común.
La integración real (diálogo de confirmación, restauración, permisos sobre `~/.Trash`) solo se puede comprobar dentro de Yazi.
