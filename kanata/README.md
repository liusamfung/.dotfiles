# kanata

Mi teclado en macOS con [kanata](https://github.com/jtroo/kanata): capas que se activan manteniendo una letra de la
fila central, home-row mods y atajos que lanzan Raycast, OmniWM, Hammerspoon, tmux, etc.

**Es una config personal.** Si la copias, léela antes de usarla: la capa base es Dvorak sobre un teclado ISO, y los
atajos asumen las apps de arriba. Usa esto como punto de partida y adapta las teclas.

## Estructura

`config.kbd` es solo un índice (`defcfg` + la lista de `include`). Todo lo demás vive en tres carpetas:

```
kanata/
├── config.kbd            punto de entrada: defcfg + includes
├── local.kbd             valores de TU máquina (no está en git, ver más abajo)
├── local.kbd.example     plantilla de local.kbd
├── core/
│   ├── vars.kbd          tiempos (tap-time, hold-time, ...)
│   ├── defsrc.kbd        las teclas físicas que kanata intercepta
│   ├── triggers.kbd      tap-holds que activan capas, home-row mods y teclas de doble función
│   └── local-guard.kbd   hace fallar --check si falta local.kbd (ver más abajo)
├── shared/               alias usados por más de una capa (símbolos, mayúsculas, atajos hyper)
└── layers/               un archivo por función: sus alias + su deflayer
```

Criterio para decidir dónde va algo: **lo que se edita junto vive junto**. Una capa y los alias que solo ella usa van
en el mismo archivo (`layers/windows.kbd` tiene la capa y sus comandos de OmniWM). Si un alias lo usan dos o más
capas, va a `shared/`.

## Reglas de kanata que hay que conocer

Son limitaciones del propio kanata. Si las ignoras, la config falla con errores poco claros o, peor, **no falla y una
tecla deja de funcionar**.

1. **Los `include` solo pueden estar en `config.kbd`.** Un archivo incluido no puede incluir otro. Por eso la lista
   completa de módulos está en `config.kbd` y no hay jerarquía de includes.
2. **Un `include` de un archivo que no existe se ignora en silencio.** Una errata en el nombre no da error de
   archivo: lo que verás es `Referenced unknown alias ...` o `unknown layer ...` en `--check`, porque el módulo nunca
   se cargó. Y si lo que falta es un módulo sin nada que lo referencie, simplemente desaparece sin avisar.
3. **Las rutas del `include` son relativas a `config.kbd`**, no al directorio desde donde ejecutas kanata. El daemon
   usa la ruta absoluta de `config.kbd`, así que funciona igual desde cualquier sitio.
4. **El orden importa cuando un alias usa otro alias.** Si dentro de un `defalias` escribes `@otro`, `otro` tiene que
   estar declarado antes. Por eso en `config.kbd` el orden es `core/vars`, `core/defsrc`, `shared/*`,
   `core/triggers` y luego las capas: `triggers.kbd` usa alias de `shared/` (`@hrow_cl`, `@{`, ...). Dentro de un
   `deflayer` el orden no importa: puede usar alias definidos en cualquier archivo, antes o después.
5. **La primera `deflayer` es la capa con la que arranca kanata.** `layers/base.kbd` tiene que seguir siendo el primer
   `layers/*` de la lista.
6. **Todas las capas tienen que tener exactamente las mismas teclas que `defsrc`**, en el mismo orden. Si añades o
   quitas una tecla en `core/defsrc.kbd`, hay que tocar todas las capas.
7. **`defcfg` no se recarga en caliente.** La tecla `lrld` (recargar) relee capas y alias, pero no `defcfg`. Si cambias
   `defcfg`, reinicia el daemon.

## Cómo comprobar que todo está bien

```bash
kanata -c ~/dotfiles/kanata/config.kbd --check
```

Dice `config file is valid` o señala el archivo y la línea. Hazlo siempre antes de reiniciar el daemon: si la config
no parsea, kanata no arranca y te quedas sin teclado remapeado. En mi `.zshrc` hay dos alias:
`kanata-check` (solo valida) y `kanata-restart` (valida y, si pasa, reinicia el daemon).

Con kitty, `kitty/sessions/dotfiles.kitty-session` abre un panel que vuelve a ejecutar `--check` cada vez que
guardas cualquier `.kbd` bajo `kanata/`.

## Instalarlo en otro Mac

Esto es lo que necesita que no viene en el repo. Haz los pasos en este orden.

### 1. El driver de Karabiner

kanata en macOS necesita el driver virtual de teclado de Karabiner (Karabiner-DriverKit-VirtualHIDDevice). Instálalo
siguiendo las instrucciones de macOS de la [página de releases de kanata](https://github.com/jtroo/kanata/releases/);
usa la versión que indique la release de kanata que instales. Sin él, kanata no puede crear el teclado virtual.

### 2. Un kanata compilado con `cmd`

Esta config usa `(cmd ...)` para lanzar Raycast, OmniWM y scripts, y esa acción **no viene activada en los binarios
precompilados** (tampoco en el de Homebrew). Con uno de esos, `--check` falla con un mensaje que dice
`compile with the feature: cmd`. Compílalo tú:

```bash
cargo install kanata --features cmd
```

Además, `defcfg` ya trae `danger-enable-cmd yes`, que es el interruptor de la config para permitir esas acciones.
Ten en cuenta que `cmd` ejecuta comandos arbitrarios con los permisos con los que corre kanata (root, en el daemon).

### 3. `local.kbd`

kanata corre como daemon de root, así que no sabe qué usuario tiene abierta la sesión de OmniWM. Esos valores se
ponen en `kanata/local.kbd`, que no está en git:

```bash
cp ~/dotfiles/kanata/local.kbd.example ~/dotfiles/kanata/local.kbd
```

Edita `user` (el resultado de `id -un`) y `cycle-script` (la ruta absoluta de `scripts/omniwm-cycle-right.sh` en tu
clon). Si usas `install.sh`, lo genera él. **Mantén la línea `local-kbd-loaded 1`**: es un centinela. Como un
`include` de un archivo inexistente se ignora, `core/local-guard.kbd` define un alias que usa ese número; sin
`local.kbd`, `--check` falla de forma visible en lugar de dejar rotos todos los atajos `sudo -u $user ...`.

### 4. Permiso de Monitorización de entrada

Ejecútalo una vez a mano para que macOS te pida el permiso:

```bash
sudo kanata -c ~/dotfiles/kanata/config.kbd
```

Activa el binario de kanata en Ajustes del Sistema > Privacidad y seguridad > Monitorización de entrada. Si cambias el binario de sitio o lo
recompilas y kanata deja de interceptar teclas, revisa que siga activado ahí.

### 5. El daemon

Para que arranque con el Mac, crea `/Library/LaunchDaemons/com.TUUSUARIO.kanata.plist` (propietario `root:wheel`)
con tus rutas:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.TUUSUARIO.kanata</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
  <key>ProgramArguments</key>
  <array>
    <string>/RUTA/A/kanata</string>
    <string>-c</string>
    <string>/Users/TUUSUARIO/dotfiles/kanata/config.kbd</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/Library/Logs/Kanata/kanata.out.log</string>
  <key>StandardErrorPath</key>
  <string>/Library/Logs/Kanata/kanata.err.log</string>
</dict>
</plist>
```

- Usa **rutas absolutas** en `ProgramArguments`: `~` no se expande en un plist.
- El `PATH` incluye `/opt/homebrew/bin` para que los comandos `(cmd ...)` (`jq`, `omniwmctl`, ...) se encuentren.
- Crea antes el directorio de logs: `sudo mkdir -p /Library/Logs/Kanata`.

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.TUUSUARIO.kanata.plist   # arrancar
sudo launchctl kickstart -k system/com.TUUSUARIO.kanata                              # reiniciar
sudo launchctl bootout system/com.TUUSUARIO.kanata                                   # parar
```

## Qué asume esta config

Los atajos que dispara no funcionan solos: hace falta que esas apps estén instaladas y configuradas.

- **Teclado**: ISO (usa la tecla `102d`, la tecla extra de los teclados ISO) con la capa base en **Dvorak**. Si usas
  QWERTY o ANSI, hay que rehacer `layers/base.kbd` y las teclas `102d` de `core/defsrc.kbd`.
- **OmniWM** (`omniwmctl`) para espacios de trabajo y ventanas, más `jq` (lo usa `scripts/omniwm-cycle-right.sh`).
- **Raycast**, con las extensiones que llaman los enlaces `raycast://extensions/...`.
- **Hammerspoon**, que atiende los enlaces `hammerspoon://toggleapp?name=...`.
- **tmux** con el prefijo `C-x`, y kitty/Ghostty para los atajos de terminal.
- Atajos con las cuatro teclas modificadoras a la vez (`S-C-A-M-...`, el "hyper") que otras apps (Homerow, Raycast,
  CleanShot, etc.) tienen que tener asignados con esa misma combinación.

## Cómo añadir una capa

1. Copia `layers/_template.kbd.example` a `layers/<nombre>.kbd` (la plantilla ya trae el número correcto de teclas).
2. Define sus alias (`defalias`) en el mismo archivo y rellena el `deflayer`.
3. Añade `(include layers/<nombre>.kbd)` en `config.kbd`.
4. Crea el activador en `core/triggers.kbd`, por ejemplo
   `mi_lyr (tap-hold $tap-time $hold-time x (layer-toggle MiCapa))`, y ponlo (`@mi_lyr`) en la tecla de
   `layers/base.kbd` que quieras.
5. `kanata -c config.kbd --check`.

Un nombre de capa mal escrito en `layer-toggle` o un `include` olvidado en el paso 3 solo se detectan con `--check`.
