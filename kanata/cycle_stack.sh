#!/bin/bash

# 1. Obtener la lista de IDs de ventanas en el stack actual (ordenadas)
# Filtramos solo las ventanas que están en el mismo espacio y son del mismo stack
stack_windows=$(yabai -m query --windows --window | jq -r '.stack_index')

# Si la ventana no es parte de un stack, salimos para evitar errores
if [ "$stack_windows" == "0" ]; then
    # Opcional: enfocar la siguiente ventana normal si no hay stack
    yabai -m window --focus next || yabai -m window --focus first
    exit 0
fi

# 2. Intentar mover a la siguiente ventana en el stack
# Si falla (porque es la última), saltamos a la primera
if ! yabai -m window --focus stack.next 2>/dev/null; then
    yabai -m window --focus stack.first
fi
