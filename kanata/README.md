# kanata

Mi teclado en macOS con [kanata](https://github.com/jtroo/kanata): capas que se activan manteniendo una letra de la
fila central, home-row mods y atajos que lanzan Raycast, OmniWM, Hammerspoon, kitty, etc.

**Es una config personal y está escrita para macOS.** Si usas Linux, lee primero la sección
[Si usas Linux](#si-usas-linux): la estructura, las reglas de kanata y el sistema de capas te sirven tal cual, pero
casi todos los atajos apuntan a apps que solo existen en macOS. Las partes que solo valen para un sistema están
marcadas con **[solo macOS]** o **[solo Linux]**.

## Estructura

`config.kbd` es solo un índice (`defcfg` + la lista de `include`). Todo lo demás vive en tres carpetas:

```
kanata/
├── config.kbd            punto de entrada: defcfg + includes
├── local.kbd             valores de TU máquina (no está en git, ver más abajo)
├── local.kbd.example     plantilla de local.kbd
├── core/
│   ├── vars.kbd          tiempos (tap-time, hold-time)
│   ├── defsrc.kbd        las teclas físicas que kanata intercepta
│   ├── triggers.kbd      tap-holds que activan capas, home-row mods y teclas de doble función
│   └── local-guard.kbd   hace fallar --check si falta local.kbd (ver más abajo)
├── shared/               alias usados por más de una capa
│   ├── chars.kbd         símbolos y mayúsculas
│   └── shortcuts.kbd     atajos hyper y de macOS
├── layers/               un archivo por función: sus alias + su deflayer
└── tools/fmt.py          formatea las cuadrículas y revisa los nombres (ver "Formato y nombres")
```

Criterio para decidir dónde va algo: **lo que se edita junto vive junto**. Una capa y los alias que solo ella usa van
en el mismo archivo (`layers/windows.kbd` tiene la capa y sus comandos de OmniWM). Si un alias lo usan dos o más
capas, va a `shared/`.

## Reglas de kanata que hay que conocer

Valen en macOS y en Linux. Son limitaciones del propio kanata. Si las ignoras, la config falla con errores poco claros
o, peor, **no falla y una tecla deja de funcionar**.

1. **Los `include` solo pueden estar en `config.kbd`.** Un archivo incluido no puede incluir otro. Por eso la lista
   completa de módulos está en `config.kbd` y no hay jerarquía de includes.
2. **Un `include` de un archivo que no existe se ignora en silencio.** Una errata en el nombre no da error de
   archivo: lo que verás es `Referenced unknown alias ...` o `unknown layer ...` en `--check`, porque el módulo nunca
   se cargó. Y si lo que falta es un módulo sin nada que lo referencie, simplemente desaparece sin avisar.
3. **Las rutas del `include` son relativas a `config.kbd`**, no al directorio desde donde ejecutas kanata.
4. **El orden importa cuando un alias usa otro alias.** Si dentro de un `defalias` escribes `@otro`, `otro` tiene que
   estar declarado antes. Por eso en `config.kbd` el orden es `core/vars`, `core/defsrc`, `shared/*`,
   `core/triggers` y luego las capas: `triggers.kbd` usa alias de `shared/` (`@hr-click`, `@{`, ...). Dentro de un
   `deflayer` el orden no importa: puede usar alias definidos en cualquier archivo, antes o después.
5. **La primera `deflayer` es la capa con la que arranca kanata.** `layers/base.kbd` tiene que seguir siendo el primer
   `layers/*` de la lista.
6. **Todas las capas tienen que tener exactamente las mismas teclas que `defsrc`**, en el mismo orden. Si añades o
   quitas una tecla en `core/defsrc.kbd`, hay que tocar todas las capas.
7. **`defcfg` no se recarga en caliente.** La tecla `lrld` (recargar) relee capas y alias, pero no `defcfg`. Si cambias
   `defcfg`, reinicia kanata.
8. **Borrar una capa deja referencias colgando.** Un `(layer-toggle X)` hacia una capa que ya no existe es un error
   (aunque ese alias no lo use nadie), y lo mismo un `@alias` que ya no está definido. `--check` te los señala. Lo que
   `--check` **no** señala es un alias definido que ya nadie usa: se queda en silencio y es ruido. Al borrar una capa,
   borra también su activador en `core/triggers.kbd`, la tecla de `layers/base.kbd` donde estaba y los alias que solo
   ella usaba.

## Cómo comprobar que todo está bien

```bash
kanata -c ~/dotfiles/kanata/config.kbd --check
```

Dice `config file is valid` o señala el archivo y la línea. Hazlo siempre antes de reiniciar kanata: si la config no
parsea, kanata no arranca y te quedas sin teclado remapeado. En mi `.zshrc` hay dos alias: `kanata-check` (solo valida)
y `kanata-restart` (valida y, si pasa, reinicia el daemon de macOS).

Con kitty, `kitty/sessions/dotfiles.kitty-session` abre un panel que vuelve a ejecutar `--check` cada vez que guardas
cualquier `.kbd` bajo `kanata/` (necesita `fswatch`).

## Formato y nombres

Dos cosas que mantienen la config ordenada y que **comprueba un script**, así que no dependen de tu disciplina.

### Las capas son cuadrículas con forma de teclado

Cada `deflayer` se escribe como el teclado: una fila por línea, cada tecla en una celda de ancho fijo, la barra
espaciadora ocupando cuatro celdas. `core/defsrc.kbd` es la leyenda: la tecla que está en esa posición del `defsrc` es
la que se redefine en esa posición de la capa.

```
(deflayer windows
  XX        XX        XX        f3        f4        f5   ...
  102d      @wm-float XX        XX        XX        XX   ...
  ...
  lsft      caps      XX        @wm-west  @wm-south @wm-north @wm-east  ...
  fn        lctl      lalt      XX        @ly-winmv                               rmet  ...
)
```

¿Es la mejor forma? Para esta config, sí. kanata también tiene `deflayermap`, donde cada capa lista solo `tecla acción`,
y es más corto para capas casi vacías. Pero ahí las teclas se nombran por su tecla física **QWERTY** (`s` sería la tecla
que escribe `o` en Dvorak), y justo eso es lo que confunde. La cuadrícula muestra cada acción en el sitio donde la
pulsas. Si tu base fuera QWERTY, `deflayermap` también sería una buena opción.

Para mantenerla:

1. Edita el contenido de la capa sin preocuparte de los espacios.
2. Ejecuta el formateador, que realinea todo con el mismo ancho de celda:

   ```bash
   python3 ~/dotfiles/kanata/tools/fmt.py           # reescribe los archivos
   python3 ~/dotfiles/kanata/tools/fmt.py --check   # no cambia nada; sale con error si algo está desordenado
   ```

   En mi `.zshrc` el primero es el alias `kanata-fmt`.

3. Una capa tiene que tener tantas teclas como el `defsrc`. Si no, el formateador lo dice (`has 78 keys, defsrc has 79`).
4. No pongas comentarios **dentro** de la cuadrícula (el formateador no los puede recolocar y se negará a tocar esa
   capa); ponlos encima.
5. `XX` es una tecla bloqueada. Un `@alias` ocupa su celda como cualquier otra tecla.

Los `defalias` y `defvar` también los formatea: una entrada por línea, con los valores alineados dentro de cada grupo
(los grupos se separan con una línea en blanco).

### Convención de nombres

Alias: minúsculas, con guiones, **máximo 8 caracteres**, con la forma `<prefijo>-<nombre>`. El prefijo es la
herramienta que recibe la acción. El límite de 8 no es capricho: con `@` son 9 caracteres, que es lo que cabe en una
celda de la cuadrícula; un nombre más largo descuadraría todas las capas, y el formateador lo rechaza.

| Prefijo | Qué es | Ejemplos |
|---|---|---|
| `ly-` | Mantener para activar una capa (tap-hold) | `ly-num`, `ly-ws`, `ly-lsft` |
| `mod-` | Tap = la tecla, hold = un modificador. `mod-<mano><modificador>` | `mod-la` (mano izquierda, alt) |
| `wm-` | OmniWM | `wm-ws3` ir al espacio 3, `wm-mv3` mover la ventana, `wm-west` foco, `wm-colw` mover columna |
| `kt-` | kitty | `kt-pdn` panel de abajo, `kt-grid` layout, `kt-code` sesión `coding` |
| `rc-` | Raycast | `rc-clip`, `rc-rain` |
| `hs-` | Hammerspoon (abrir o alternar una app) | `hs-notes` |
| `ss-` | Capturas de pantalla | `ss-area`, `ss-rec` |
| `tab-`, `nav-` | Pestañas del navegador, historial | `tab-new`, `nav-back` |
| `hr-` | Homerow | `hr-click`, `hr-scrl` |
| `sys-` | Atajos del sistema macOS | `sys-lock`, `sys-zin` |
| `hy-` | Hyper + tecla de función | `hy-f4` |
| `jmp-` | Saltos de cursor (palabra, línea) | `jmp-wl`, `jmp-ll` |
| `app-`, `opt-`, `mic-`, `pw-`, `ctl-` | Otros atajos de una sola herramienta | `app-tab`, `opt-n`, `mic-mute` |
| sin prefijo | Teclas de doble función por lo que hacen al tocar y al mantener | `at-1pw` (`@` / autorrelleno de 1Password), `pst-cpy` |

- Los alias de **1 o 2 caracteres** (`@A`, `@!`, `@''`) se llaman como el carácter que escriben, y quedan exentos de la
  regla anterior. Los que no se pueden escribir como nombre llevan palabra: `lpar`, `rpar`, `dquote`.
- Las **capas** también van en minúsculas con guiones, con el nombre de lo que hacen (`windows`, `terminal-panes`);
  la subcapa de una capa lleva `-move` o similar (`windows-move`).
- Los nombres dicen lo que **hace** el alias, no la tecla donde está hoy. Así no hay que renombrar nada cuando
  cambias de sitio una capa.

## Mapa de capas

Se activan **manteniendo** una tecla de la capa base (al tocarla, escribe lo normal). Las letras son las de la
disposición Dvorak, es decir, la tecla que produce esa letra.

| Mantener | Capa | Módulo | Para qué | Plataforma |
|---|---|---|---|---|
| espacio | `number` | `number.kbd` | Teclado numérico y saltos de palabra | adaptar |
| backspace / enter | `control-l` / `control-r` | `control.kbd` | Atajos con Ctrl y hyper | macOS |
| shift izq. / der. | `shift-l` / `shift-r` | `shift.kbd` | Símbolos, mayúsculas y acentos | adaptar |
| `a` | `quick-apps` | `quick-apps.kbd` | Abrir apps y atajos hyper | solo macOS |
| `o` | `tabs` | `tabs.kbd` | Pestañas del navegador | adaptar |
| `e` | `workspaces` / `workspaces-move` | `workspaces.kbd` | Espacios de trabajo de OmniWM | solo macOS |
| `u` | `sessions` | `sessions.kbd` | Sesiones de kitty | adaptar |
| `h` | `terminal` | `terminal.kbd` | Prompts y scroll en kitty | adaptar |
| `t` | `terminal-panes` | `terminal.kbd` | Paneles y layouts de kitty | adaptar |
| `n` | `windows` / `windows-move` | `windows.kbd` | Ventanas de OmniWM | solo macOS |
| `s` | `system` | `system.kbd` | Volumen, brillo, bloquear, zoom | solo macOS |
| `{` | `screenshot` | `screenshot.kbd` | Capturas y grabación | solo macOS |

"adaptar" significa que la idea sirve en cualquier sistema pero las teclas que emite (`M-...`, que es Cmd en macOS, o
atajos de macOS) hay que cambiarlas.

## Instalarlo en macOS **[solo macOS]**

Haz los pasos en este orden.

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

El daemon de macOS corre como root, así que no sabe qué usuario tiene abierta la sesión de OmniWM. Esos valores se
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

Activa el binario de kanata en Ajustes del Sistema > Privacidad y seguridad > Monitorización de entrada. Si cambias el
binario de sitio o lo recompilas y kanata deja de interceptar teclas, revisa que siga activado ahí.

### 5. El daemon (LaunchDaemon)

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

### Qué asume la config en macOS **[solo macOS]**

Los atajos que dispara no funcionan solos: hace falta que esas apps estén instaladas y configuradas.

- **Teclado ISO de MacBook** (usa la tecla `102d`, la tecla extra de los teclados ISO, y `fn`) con la capa base en
  **Dvorak**.
- **OmniWM** (`omniwmctl`) para espacios de trabajo y ventanas, más `jq` (lo usa `scripts/omniwm-cycle-right.sh`).
- **Raycast**, con la extensión de Raindrop.io para el enlace `raycast://extensions/lardissone/raindrop-io/...`.
- **Hammerspoon**, que atiende los enlaces `hammerspoon://toggleapp?name=...` (`.hammerspoon/modules/app_toggler.lua`).
- **kitty** con los atajos de `kitty/kitty.conf` (sesiones con `ctrl+cmd+N`, paneles con `ctrl+j/k/q/x`, layouts con
  `ctrl+cmd+option+...`).
- Atajos con las cuatro teclas modificadoras a la vez (`S-C-A-M-...`, el "hyper") que otras apps (Homerow,
  Easydict, toggleMute, etc.) tienen asignados con esa misma combinación.

## Si usas Linux

Lo más importante: **esta config no funciona tal cual en Linux.** No es un problema de kanata (kanata funciona igual
en Linux) sino de lo que dispara: Raycast, OmniWM, Hammerspoon, macshot, Homerow, los atajos `M-` (Cmd) y los comandos
`open raycast://...` solo existen en macOS. Si la copias entera, esas teclas no harán nada o fallarán.

Lo que sí te sirve y puedes reutilizar:

- La estructura en `core/`, `shared/` y `layers/`, y las [reglas de kanata](#reglas-de-kanata-que-hay-que-conocer).
- El sistema de capas con tap-hold (`core/triggers.kbd`) y los home-row mods.
- `layers/_template.kbd.example` y la receta de [añadir una capa](#cómo-añadir-una-capa).

### Qué tocar antes de usarla en Linux

| Qué | Por qué |
|---|---|
| `core/defsrc.kbd` | Es la distribución de un MacBook ISO (`fn`, `102d`, `grv`). Ajústala a tu teclado y haz lo mismo en **todas** las capas (regla 6). Para ver cómo llama kanata a tus teclas, ejecútalo con `kanata --debug`. |
| `layers/base.kbd` | Es Dvorak. Si usas QWERTY, hay que reescribirla. |
| `M-...` en cualquier alias | En kanata, `M-` es la tecla Meta: **Cmd en macOS y Super en Linux**. Todos los atajos `M-c`, `M-v`, `M-t`, `M-w`, `M-1` ... (pestañas, copiar/pegar, `number.kbd`) tienen que pasar a `C-...` en Linux. |
| `A-left`, `A-rght` (`number.kbd`) | Saltar palabra con Option es de macOS; en Linux es `C-left` / `C-rght`, y `M-left` / `M-rght` (inicio/fin de línea) es `home` / `end`. |
| `A-n`, `A-e`, `A-u`, `A-1`, `S-A-/` (`shared/chars.kbd`, `shared/shortcuts.kbd`) | Son las teclas muertas de acentos y `¡ ¿` con Option de macOS. En Linux usa AltGr o la tecla Compose de tu entorno. |
| `(cmd open ...)` | `open` es de macOS. En Linux el equivalente es `xdg-open`, pero los destinos (`raycast://`, `hammerspoon://`) tampoco existen. |
| `sudo -u $user ...` | Solo hace falta en macOS porque allí kanata corre como root. En Linux kanata corre con tu usuario y esos `sudo` pedirían contraseña y fallarían. |
| `local.kbd` | Los valores `user` y `cycle-script` solo los usan los comandos de OmniWM. Si quitas esos módulos, puedes quitar también `(include core/local-guard.kbd)` y no necesitas `local.kbd`. |
| `kitty/kitty.conf` | Los atajos de `sessions.kbd` y `terminal.kbd` emiten `C-M-...` y `C-A-M-...` (Ctrl+Cmd, Ctrl+Option+Cmd), que en kitty son combinaciones de macOS. Hay que reasignarlos en tu `kitty.conf`. |

### Qué módulos puedes quitar y qué se rompe

Cada fila es un módulo que sobra en Linux. Para quitarlo: borra su `include` de `config.kbd`, borra su activador en
`core/triggers.kbd` (regla 8) y arregla lo que dependía de él:

| Quitar | Qué más hay que cambiar |
|---|---|
| `layers/workspaces.kbd` | `layers/control.kbd` usa `@wm-wsprv` y `@wm-cycle`; `layers/quick-apps.kbd` usa `@wm-wsprv`. Sustitúyelos por `XX`. |
| `layers/windows.kbd` | `layers/shift.kbd` usa `@wm-fprev` y `@wm-fnext`. Sustitúyelos por `XX`. |
| `layers/raycast.kbd` | `layers/shift.kbd` usa `@rc-rain` y `@rc-prmpt`; `layers/quick-apps.kbd` usa `@rc-rain` y `@rc-clip`; `layers/system.kbd` usa `@rc-dism`. |
| `layers/screenshot.kbd` | `layers/shift.kbd` usa `@ss-full`. |
| `layers/quick-apps.kbd` | Nada la usa salvo el activador (`@ly-qck`, `@ly-lhyp`, `@ly-rhyp` en `core/triggers.kbd`). |
| `layers/system.kbd` | Nada la usa salvo su activador (`@ly-sys`). Usa alias de `shared/shortcuts.kbd` y `layers/raycast.kbd`. |
| `shared/shortcuts.kbd` | La usan `core/triggers.kbd`, `layers/base.kbd`, `control.kbd`, `shift.kbd` y `system.kbd`. Es lo último que conviene quitar. |

Dependencias entre módulos (las que cruzan archivos), por si cambias algo más: `triggers` usa `shared/chars` y
`shared/shortcuts`; `base` usa `triggers`, `chars` y `shortcuts`; `control` usa `triggers`, `chars`, `shortcuts` y
`workspaces`; `shift` usa `chars`, `shortcuts`, `raycast`, `screenshot` y `windows`; `number` usa `chars`; `quick-apps`
usa `raycast` y `workspaces`; `system` usa `shortcuts` y `raycast`.

### Instalar kanata en Linux **[solo Linux]**

Estos pasos vienen de la [guía de Linux de kanata](https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md); no
los he probado yo en Linux, así que si algo no coincide con tu distribución, manda esa guía.

1. **Permisos.** Aquí no hay daemon de root ni driver de Karabiner: kanata corre con tu usuario, pero necesita acceso a
   `/dev/input` y a `/dev/uinput`.

   ```bash
   sudo groupdel uinput 2>/dev/null
   sudo groupadd --system uinput
   sudo usermod -aG input $USER
   sudo usermod -aG uinput $USER
   sudo modprobe uinput
   sudo tee /etc/udev/rules.d/99-input.rules > /dev/null <<'EOF'
   KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
   EOF
   sudo udevadm control --reload-rules && sudo udevadm trigger
   ```

   Cierra sesión y vuelve a entrar para que cuenten los grupos (`groups` debe listar `input` y `uinput`).
   Para que `uinput` se cargue en cada arranque, añade `uinput` a `/etc/modules-load.d/`.

2. **El binario.** Instálalo con `cargo install kanata`. Si conservas algún `(cmd ...)` en tu config, necesitas
   `cargo install kanata --features cmd` (los binarios precompilados no traen `cmd` salvo que la release publique una
   variante con él). Si no usas `cmd`, quita `danger-enable-cmd yes` de `defcfg`.

3. **Probar a mano.**

   ```bash
   kanata -c ~/dotfiles/kanata/config.kbd --check   # validar
   kanata -c ~/dotfiles/kanata/config.kbd           # ejecutar en la terminal
   ```

4. **Arrancar con la sesión (systemd de usuario)**, en `~/.config/systemd/user/kanata.service`:

   ```ini
   [Unit]
   Description=Kanata keyboard remapper

   [Service]
   Type=simple
   ExecStart=%h/.cargo/bin/kanata --cfg %h/dotfiles/kanata/config.kbd --no-wait
   Restart=on-failure
   RestartSec=3

   [Install]
   WantedBy=default.target
   ```

   Cambia la ruta del binario si no lo instalaste con cargo. `--no-wait` es necesario para que `Restart=on-failure`
   funcione.

   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now kanata
   systemctl --user restart kanata     # tras cambiar la config
   journalctl --user -u kanata -f      # ver los logs
   ```

   Esto sustituye a todo el apartado del LaunchDaemon y de los permisos de macOS: **no existe `/Library/LaunchDaemons`
   ni Monitorización de entrada en Linux.**

## Cómo añadir una capa

1. Copia `layers/_template.kbd.example` a `layers/<nombre>.kbd` (la plantilla ya trae el número correcto de teclas
   para el `defsrc` de este repo; si cambiaste `defsrc`, ajústala).
2. Define sus alias (`defalias`) en el mismo archivo, con los [nombres](#formato-y-nombres) de la convención, y
   rellena el `deflayer`. No hace falta alinear a mano: lo hace el formateador.
3. Añade `(include layers/<nombre>.kbd)` en `config.kbd`.
4. Crea el activador en `core/triggers.kbd`, por ejemplo
   `ly-mi (tap-hold $tap-time $hold-time x (layer-toggle mi-capa))`, y ponlo (`@ly-mi`) en la tecla de
   `layers/base.kbd` que quieras.
5. `python3 tools/fmt.py` y `kanata -c config.kbd --check`.

Un nombre de capa mal escrito en `layer-toggle` o un `include` olvidado en el paso 3 solo se detectan con `--check`.
