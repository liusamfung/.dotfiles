#!/bin/bash

# Nombre exacto de la aplicación según yabai query
APP_NAME="Notes"

# 1. Buscar si el proceso de Notes existe y obtener su ID de ventana
WINDOW_ID=$(yabai -m query --windows | jq -r ".[] | select(.app == \"$APP_NAME\") | .id" | head -n 1)

# 2. Si la ventana no existe, abrir la aplicación
if [ -z "$WINDOW_ID" ]; then
    open -a "$APP_NAME"
else
    # 3. Si existe, verificar si tiene el foco actualmente
    HAS_FOCUS=$(yabai -m query --windows --window "$WINDOW_ID" | jq -r '."has-focus"')

    if [ "$HAS_FOCUS" = "true" ]; then
        # Si tiene el foco, la minimizamos (u ocultamos la app)
        yabai -m window "$WINDOW_ID" --minimize
        # Opcionalmente puedes usar: osascript -e "tell application \"System Events\" to set visible of process \"$APP_NAME\" to false"
    else
        # Si no tiene el foco, la movemos al espacio actual y le damos foco
        yabai -m window "$WINDOW_ID" --space mouse
        yabai -m window "$WINDOW_ID" --focus
    fi
fi
