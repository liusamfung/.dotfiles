# dotfiles

Mi entorno de terminal en macOS: zsh (oh-my-zsh, starship), kitty, Neovim (con todo el flujo de Salesforce),
yazi y lazygit. Un solo script lo deja listo en un Mac nuevo.

## Instalar en un Mac nuevo

```bash
git clone https://github.com/liusamfung/.dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
```

Tiene que quedar en `~/dotfiles`: kitty y lazygit asumen esa ruta. Si `git` aún no existe, macOS ofrece instalar
las herramientas de línea de comandos de Xcode; termina esa instalación y repite el comando.

El script es idempotente: se puede volver a ejecutar sin romper nada. Tarda un buen rato en un Mac nuevo (la mayor
parte es Homebrew y la primera descarga de Neovim).

## Qué instala, en este orden

1. **Herramientas de línea de comandos de Xcode** (git, compilador para los parsers de tree-sitter).
2. **Homebrew**.
3. **`Brewfile`**: 35 fórmulas y 3 casks.
   - Shell: `zsh-autosuggestions`, `zsh-vi-mode`, `starship`, `fzf`, `eza`, `zoxide`, `bat`, `trash-cli`.
   - Terminal: `yazi` (con sus dependencias de previsualización), `lazygit`, `gh`, `git`, `btop`, `ov`, `fswatch`, `jq`,
     `ripgrep`, `fd`.
   - Editor: `neovim`, `tree-sitter-cli`, `luarocks`, `watchman`, `python@3.12`, `universal-ctags`.
   - Runtimes: `mise` y `openjdk@21`.
   - Casks: `kitty` y las fuentes JetBrainsMono Nerd Font y Symbols Nerd Font.
   - `Brewfile.extras` (el resto de fórmulas: texlive, qemu, julia, docker…) es opcional: `--extras`.
4. **Enlaces en `$HOME`** hacia este repo: `.zshrc`, `.zprofile`, `.zshenv`, y en `~/.config`: `nvim`, `kitty`,
   `yazi`, `starship.toml`, `mise/config.toml`, `git/config`, `git/ignore`. Si ya existía algo en esos sitios, se
   mueve a `~/.dotfiles-backup/<fecha>/`; nunca se pisa.
5. **oh-my-zsh** (clon en `~/.oh-my-zsh`).
6. **mise**: node 24.21.0 y la CLI de Salesforce (`npm install -g @salesforce/cli` sobre ese node).
7. **Identidad de git** (se guarda en `~/.gitconfig`, no en el repo).
8. **`kanata/local.kbd`** con tu usuario y la ruta del repo (archivo local, no versionado).
9. **Neovim listo**: plugins (respeta `lazy-lock.json`), herramientas de Mason y parsers de tree-sitter, para que la
   primera vez que lo abras no tenga que descargar nada.
10. **Comprobaciones** de tu shell y una prueba con un proyecto Salesforce temporal abierto en Neovim.

## Qué te pedirá

- **Tu contraseña de administrador**, una sola vez y solo si Homebrew no está instalado.
- Instalar las **herramientas de Xcode** (ventana de macOS), si faltan; después hay que repetir el comando.
- **Nombre y correo de git**, si no están configurados.

No pide nada más.

## Opciones

| Opción | Qué hace |
|---|---|
| `--check` | Solo verifica; no cambia nada. |
| `--dry-run` | Muestra lo que haría; no cambia nada. |
| `--extras` | Instala también `Brewfile.extras`. |
| `--mobile` | Instala también `Brewfile.mobile` y `eas-cli` (React Native, Expo, Supabase). |
| `--skip-brew` | Salta Xcode, Homebrew y los paquetes. |
| `--no-nvim` | Salta la descarga de Neovim (plugins, Mason, parsers). |

## Desarrollo móvil (`--mobile`)

Para proyectos React Native + Expo con Supabase (NeighborGood). Es opcional: no todos los Macs lo necesitan.

- **`Brewfile.mobile`**: `supabase` (CLI) y `cocoapods` (solo para compilar iOS en local; EAS Build lo hace en la nube).
- **Android**: no se configura aquí a propósito. EAS Build compila Android en la nube y devuelve un `.apk`; quien tenga
  un teléfono Android prueba con él (las notificaciones push y el escáner QR necesitan un teléfono real).
- **`eas-cli`**: `npm install -g eas-cli` sobre el node de mise (igual que `sf`; si cambias de versión de node, hay que
  repetirlo).
- **Neovim** ya trae lo necesario (se instala con Mason, sin `--mobile`): servidores `eslint`, `denols` (solo dentro de
  `supabase/functions`) y `postgres_lsp` (SQL de las migraciones), y los esquemas de `app.json`, `eas.json`, `tsconfig.json`.
- **A mano**: `eas login` y `supabase login`. Xcode completo (simulador de iOS) viene de la App Store.

## Al terminar (a mano)

- Abrir una terminal nueva (o `exec zsh -l`).
- `gh auth login`
- Activar el agente SSH de 1Password.
- `sf org login web --alias <nombre>`
- Iniciar sesión en `claude` (lo usa el atajo `<C-a>` de lazygit para el mensaje de commit).
- Poner kitty como terminal (la fuente es JetBrainsMono Nerd Font).

## Qué hay en el repo

| Ruta | Contenido |
|---|---|
| `install.sh`, `Brewfile`, `Brewfile.extras` | El instalador y sus paquetes. |
| `.zshrc`, `.zprofile`, `.zshenv` | Configuración de zsh. |
| `nvim/` | Neovim, incluido el flujo de Salesforce (atajos bajo `<leader>t`). |
| `kitty/`, `yazi/`, `lazygit/`, `starship/` | Terminal, gestor de archivos, git y prompt. |
| `mise/`, `git/` | Versiones de node y configuración de git. |
| `kanata/` | Capa de teclado (`local.kbd` se genera por máquina). |
| `scripts/` | Scripts sueltos; `nvim-smoke.lua` lo usa el instalador. |

## Estado

El instalador está probado con una instalación completa en un `HOME` temporal, pero **todavía no en un Mac
virgen**: Homebrew desde cero y la contraseña de administrador quedan sin probar. Faltan las fases siguientes: el
resto de casks, kanata y el teclado, hammerspoon, finicky, OmniWM y los ajustes de macOS.
