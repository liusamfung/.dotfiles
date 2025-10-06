#!/bin/bash
# set -x

# Tokyo Night: https://github.com/tokyo-night/tokyo-night-vscode-theme
TOKYONIGHT=(
  blue "#7aa2f7"
  teal "#1abc9c"
  cyan "#7dcfff"
  grey "#414868"
  green "#9fe044"
  yellow "#faba4a"
  orange "#ff9e64"
  red "#f7768e"
  purple "#9d7cd8"
  maroon "#914c54"
  black "#24283b"
  trueblack "#000000"
  white "#c0caf5"
)

# Dracula Refined https://github.com/mathcale/dracula-theme-refined
DRACULA=(
  blue "#6272A4"
  teal "#69FF94"
  cyan "#8BE9FD"
  grey "#44475A"
  green "#50FA7B"
  yellow "#F1FA8C"
  orange "#FFB86C"
  red "#FF5555"
  purple "#BD93F9"
  maroon "#FF79C6"
  black "#282A36"
  trueblack "#1c1c1c"
  white "#F8F8F2"
)

# Rose Pine https://rosepinetheme.com/palette/ingredients/
ROSEPINE=(
  blue "#7283CF"
  teal "#419BBE"
  cyan "#9ccfd8"
  grey "#524f67"
  green "#B4D99C"
  yellow "#f6c177"
  orange "#d7827e"
  red "#eb6f92"
  purple "#c4a7e7"
  maroon "#b4637a"
  black "#26233a"
  trueblack "#000000"
  white "#e0def4"
)

# Catpuccin Mocha https://github.com/catppuccin/catppuccin#-palette
CATPUCCIN=(
  blue "#89b4fa"
  teal "#94e2d5"
  cyan "#89dceb"
  grey "#585b70"
  green "#a6e3a1"
  yellow "#f9e2af"
  orange "#fab387"
  red "#f38ba8"
  purple "#cba6f7"
  maroon "#eba0ac"
  black "#1e1e2e"
  trueblack "#000000"
  white "#cdd6f4"
)

# TEMPLATE https://github.com/XXX
# THEME_NAME=(
#   blue "#"
#   teal "#"
#   cyan "#"
#   grey "#"
#   green "#"
#   yellow "#"
#   orange "#"
#   red "#"
#   purple "#"
#   maroon "#"
#   black "#"
#   trueblack "#"
#   white "#"
# )

COLORS=("${DRACULA[@]}")

getcolor() {
  COLOR_NAME=$1
  local COLOR=""

  if [[ -z $2 ]]; then
    OPACITY=100
  else
    OPACITY=$2
  fi

  # Loop through the array to find the color hex by name
  for ((i = 0; i < ${#COLORS[@]}; i += 2)); do
    if [[ "${COLORS[i]}" == "$COLOR_NAME" ]]; then
      COLOR="${COLORS[i + 1]}"
      break
    fi
  done

  # Check if color was found
  if [[ -z $COLOR ]]; then
    echo "Invalid color name: $COLOR_NAME" >&2
    return 1
  fi

  echo $(PERCENT2HEX $OPACITY)${COLOR:1}
}

PERCENT2HEX() {
  local PERCENTAGE=$1
  local DECIMAL=$(((PERCENTAGE * 255) / 100))
  printf "0x%02X\n" "$DECIMAL"
}

# Color Tokens
BAR_COLOR=$(getcolor black)
BAR_BORDER_COLOR=$(getcolor black 0)
HIGHLIGHT=$(getcolor cyan)
HIGHLIGHT_75=$(getcolor cyan 75)
HIGHLIGHT_50=$(getcolor cyan 50)
HIGHLIGHT_25=$(getcolor cyan 25)
HIGHLIGHT_10=$(getcolor cyan 10)
ICON_COLOR=$(getcolor white)
ICON_COLOR_INACTIVE=$(getcolor white 25)
LABEL_COLOR=$(getcolor white 75)
LABEL_COLOR_NEGATIVE=$(getcolor black)
POPUP_BACKGROUND_COLOR=$(getcolor black 75)
POPUP_BORDER_COLOR=$(getcolor black 0)
SHADOW_COLOR=$(getcolor black)
TRANSPARENT=$(getcolor black 0)

export BLACK=0xff181926
export WHITE=0xffcad3f5
export RED=0xffed8796
export GREEN=0xffa6da95
export BLUE=0xff8aadf4
export YELLOW=0xffeed49f
export ORANGE=0xfff5a97f
export MAGENTA=0xffc6a0f6
export GREY=0xff939ab7
export CYAN=0xff94e2d5
export TRANSPARENT=0x00000000
export BG0=0x801e1e2e
export BG1=0x801e1e2e
export BG2=0x80494d64

# General bar colors
export BAR_COLOR=$BG0
export BAR_BORDER_COLOR=$BG2
export BACKGROUND_0=$BG0
export BACKGROUND_1=$BG1
export BACKGROUND_2=$BG2
export ICON_COLOR=$WHITE  # Color of all icons
export LABEL_COLOR=$WHITE # Color of all labels
export POPUP_BACKGROUND_COLOR=$BAR_COLOR
export POPUP_BORDER_COLOR=$WHITE
export SHADOW_COLOR=$BLACK

