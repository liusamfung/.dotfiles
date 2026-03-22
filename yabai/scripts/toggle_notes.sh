#!/bin/bash
# Nombre exacto de la aplicación
APP_NAME="Notes"

# 1. Buscar si la ventana existe y obtener su ID
WINDOW_ID=$(yabai -m query --windows | jq -r ".[] | select(.app == \"$APP_NAME\") | .id" | head -n 1)

# 2. Si la ventana no existe, abrir la aplicación
if [ -z "$WINDOW_ID" ]; then
    open -a "$APP_NAME"
else
    # 3. Verificar si tiene el foco actualmente
    HAS_FOCUS=$(yabai -m query --windows --window "$WINDOW_ID" | jq -r '."has-focus"')

    if [ "$HAS_FOCUS" = "true" ]; then
        # CAMBIO: En lugar de --minimize, usamos AppleScript para ocultar (Command + H)
        osascript -e "tell application \"System Events\" to set visible of process \"$APP_NAME\" to false"
    else
        # Si está oculta o en otro espacio, la traemos al frente
        # Nota: Al estar oculta, a veces es necesario asegurar que sea visible primero
        osascript -e "tell application \"System Events\" to set visible of process \"$APP_NAME\" to true"
        yabai -m window "$WINDOW_ID" --space mouse
        yabai -m window "$WINDOW_ID" --focus
    fi
fi
