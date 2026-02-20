#!/bin/bash
# close_other_apps_except_dock() {
#     local apps_to_keep_regex="$1"
#
#     # 1. Obtenemos TODAS las aplicaciones que aparecen en el Dock/Force Quit
#     # Usamos AppleScript para obtener los nombres de procesos con interfaz gráfica
#     local running_apps
#     running_apps=$(osascript -e 'tell application "System Events" to get name of every process whose background only is false')
#
#     # 2. Procesamos la lista (viene separada por comas)
#     echo "$running_apps" | tr ',' '\n' | sed 's/^ //' | while read -r raw_name; do
#         # Limpiamos caracteres invisibles como hicimos antes
#         local app_name=$(echo "$raw_name" | tr -dc '[:print:]')
#
#         # 3. Apps que NUNCA deben cerrarse (Sistema y tu Terminal)
#         [[ -z "$app_name" ]] && continue
#         [[ "$app_name" =~ ^(Finder|kitty|Terminal|AlDente)$ ]] && continue
#
#         # 4. Si no está en la lista de permitidas, cerrar de verdad
#         if ! echo "$app_name" | grep -iqE "$apps_to_keep_regex"; then
#             echo "Cerrando app persistente: $app_name"
#             osascript -e "quit app \"$app_name\"" 2>/dev/null
#         fi
#     done
# }

close_other_apps_except_dock() {
    local apps_to_keep_regex="$1"

    # 1. Get the list of running GUI apps
    local running_apps
    running_apps=$(osascript -e 'tell application "System Events" to get name of every process whose background only is false')

    # 2. Process the list
    echo "$running_apps" | tr ',' '\n' | sed 's/^ //' | while read -r raw_name; do
        local app_name=$(echo "$raw_name" | tr -dc '[:print:]')

        # 3. Safety Check: Apps that SHOULD NOT be closed
        [[ -z "$app_name" ]] && continue
        [[ "$app_name" =~ ^(Finder|kitty|Terminal|AlDente)$ ]] && continue

        # 4. If it's not in the allowed list, quit it
        if ! echo "$app_name" | grep -iqE "$apps_to_keep_regex"; then
            echo "Cerrando app: $app_name"
            osascript -e "quit app \"$app_name\"" 2>/dev/null
        fi
    done

    # 5. WAIT until the apps are actually gone
    echo "Esperando a que las aplicaciones finalicen..."
    while true; do
        # Check if any app (other than the excluded ones and the allowed regex) is still running
        local still_running
        still_running=$(osascript -e 'tell application "System Events" to get name of every process whose background only is false' | tr ',' '\n' | sed 's/^ //' | grep -vE "^(Finder|kitty|Terminal|AlDente|$apps_to_keep_regex)$")
        
        if [[ -z "$still_running" ]]; then
            break
        fi
        sleep 1 # Wait 1 second before checking again
    done

    # 6. Send the Notification
    osascript -e 'display notification "Todas las aplicaciones se han cerrado correctamente." with title "Limpieza Completa" sound name "Glass"'
    
    echo "¡Listo! Notificación enviada."
}

close_other_apps_except() {
    local apps_to_keep_regex="$1"

    yabai -m query --windows | jq -c '.[]' | while read -r line; do
        local raw_name=$(echo "$line" | jq -r '.app')
        local app_name=$(echo "$raw_name" | tr -dc '[:print:]')
        
        # 1. Apps esenciales que nunca se cierran
        [[ "$app_name" =~ ^(kitty|Terminal)$ ]] && continue

        # 2. Si no está en la lista de permitidas, solicitar cierre
        if ! echo "$app_name" | grep -iqE "$apps_to_keep_regex"; then
            osascript -e "quit app \"$app_name\"" 2>/dev/null
        fi
    done
}

# Función para configurar espacios
setup_space() {
  local idx="$1"
  local name="$2"
  while [ $(yabai -m query --spaces | jq '. | length') -lt "$idx" ]; do
    yabai -m space --create
  done
  yabai -m space "$idx" --label "$name"
}

# Función para abrir apps desde una lista (separada por |)
open_apps() {
  local list=$(echo "$1" | tr -d '()' | tr '|' '\n')
  echo "$list" | while read -r app; do
            # Abrir en segundo plano (-g) para no interrumpir
    [ -n "$app" ] && open -g -a "$app"
  done
}

open_and_assign() {
    local app_name="$1"
    local target_space="$2"

    echo "Intentando abrir $app_name en espacio $target_space..."

    # 1. Abrir la aplicación (usamos el nombre para el comando open)
    open -g -a "$app_name"

    # 2. Reintento con búsqueda flexible (regex)
    for i in {1..15}; do  # WhatsApp es lento, subimos a 15 reintentos (7.5s)
        # Buscamos el ID ignorando mayúsculas/minúsculas y buscando coincidencias parciales
        local window_id=$(yabai -m query --windows | jq -r ".[] | select(.app | test(\"$app_name\"; \"i\")) | .id" | head -n 1)

        if [ -n "$window_id" ] && [ "$window_id" != "null" ]; then
            echo "Ventana de $app_name detectada (ID: $window_id). Moviendo..."
            yabai -m window "$window_id" --space "$target_space"
            return 0
        fi
        
        sleep 0.5
    done

    echo "Advertencia: No se detectó ventana para $app_name después de 7.5 segundos."
}

# close_apps_debug() {
#     local apps_to_keep_regex="$1"
#
#     echo "--- INICIO DE DIAGNÓSTICO DE CIERRE ---"
#
#     yabai -m query --windows | jq -c '.[]' | while read -r line; do
#         # EXTRAEMOS Y LIMPIAMOS: Eliminamos caracteres no imprimibles/invisibles
#         local raw_name=$(echo "$line" | jq -r '.app')
#         local app_name=$(echo "$raw_name" | tr -dc '[:print:]') # Filtra solo caracteres imprimibles
#         # El comando tr -dc '[:print:]' le dice al sistema: "Toma el nombre de 
#         # la aplicación y borra todo lo que no sea un carácter imprimible 
#         # (letras, números, espacios o símbolos estándar)". Al eliminar ese 
#         # carácter invisible, el comando osascript finalmente pudo encontrar 
#         # una aplicación llamada exactamente "WhatsApp" y enviarle la orden de 
#         # cierre.
#
#         local pid=$(echo "$line" | jq -r '.pid')
#
#         echo "--------------------------------------"
#         echo "Analizando App: [$app_name] | PID: $pid"
#
#         # 1. Exclusiones base
#         if [[ "$app_name" =~ ^(Finder|Dock|System\ Settings|yabai|skhd|borders|kitty|Terminal)$ ]]; then
#             echo "STATUS: EXCLUIDA (Sistema/Terminal)"
#             continue
#         fi
#
#         # 2. Comparación
#         if echo "$app_name" | grep -iqE "$apps_to_keep_regex"; then
#             echo "STATUS: MANTENER"
#         else
#             echo "STATUS: CERRAR [$app_name]"
#
#             # Intentamos cerrar usando el nombre limpio
#             osascript -e "quit app \"$app_name\"" 2>/dev/null
#
#             # Si después de 0.5s el proceso sigue vivo, usamos el PID (Fuerza Bruta)
#             sleep 0.5
#             # if ps -p "$pid" > /dev/null; then
#             #     echo "ADVERTENCIA: osascript falló. Usando kill -9 en PID: $pid"
#             #     kill -9 "$pid" 2>/dev/null
#             # else
#             #     echo "SUCCESS: App cerrada correctamente."
#             # fi
#         fi
#     done
#     echo "--- FIN DE DIAGNÓSTICO ---"
# }
# Exportamos las funciones para que los perfiles puedan usarlas
export -f setup_space
export -f open_apps
export -f open_and_assign
# export -f close_other_apps_except
export -f close_other_apps_except_dock

