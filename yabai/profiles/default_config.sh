#!/bin/bash
source /Users/liusam/dotfiles/yabai/scripts/opener.sh

APPS="(kitty|Reminders|Fantastical|YouTube Music|Zen|Microsoft Outlook|WhatsApp)"
# close_other_apps_except_dock "$APPS"

setup_space 1 terminal
setup_space 2 testing
setup_space 3 workOffice
setup_space 4 organization
setup_space 5 media
setup_space 6 browing
setup_space 7 NONEEEEE
setup_space 8 comunication
setup_space 9 NONEEEEE

# open_apps "$APPS_TO_OPEN"
open_and_assign "kitty" 1
open_and_assign "Reminders" 4
open_and_assign "Fantastical" 4
open_and_assign "YouTube Music" 5
open_and_assign "Zen" 6
open_and_assign "WhatsApp" 8
open_and_assign "Microsoft Outlook" 8
# Actualmente ya funnciona. 

# Debido a que tengo un signal en el yabairc que fuerza a enfocar
# cualquier ventana que se acaba de crear(Porque me soluciona un problema).
# Despues que se abran todas las apps quiero que tener es este "profile"
# Deseo que me enfoque el espacio donde esta mi terminal  
yabai -m space --focus 1
