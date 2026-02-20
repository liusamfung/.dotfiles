#!/bin/bash

source /Users/liusam/dotfiles/yabai/scripts/opener.sh

setup_space 1 terminal

# Definir Apps para abrir en este perfil
APPS_TO_OPEN="(kitty|Terminal)"

close_other_apps_except_dock "$APPS_TO_OPEN"

open_and_assign "kitty" 1
