#!/bin/zsh

# Este script se encarga de gestionar procesos y archivos.
# Contiene errores intencionales para probar un Language Server.

# Variables globales
USUARIO_ACTUAL=$(whoami)
DIRECTORIO_RAIZ="/var/www/html"

# Funciones del script
function mostrar_ayuda() {
  echo "Uso: $0 [OPCION]"
  echo "Gestiona procesos y archivos en el sistema."
  echo "Opciones:"
  echo "  -p, --procesos  Muestra el top 5 de procesos por uso de CPU."
  echo "  -a, --archivos  Encuentra archivos grandes en un directorio específico."
  echo "  -h, --help      Muestra esta ayuda y sale."
  echo "  -c, --clean     Elimina archivos de más de 30 días en el directorio raíz."
}

# -----------------
# FUNCIONES CON ERRORES
# -----------------

# Error leve: Falta un punto y coma y hay un error de sintaxis en el 'if'
function mostrar_procesos() {
  echo "Mostrando los 5 procesos con mayor uso de CPU:"
  ps aux --sort=-%cpu | head -n 6
  if [ -z "$USUARIO_ACTUAL" ]
    then
      echo "No se pudo obtener el usuario." >&2
      exit 1
  fi
}

# Error grave: Falta una comilla de cierre en el 'find' y un nombre de función incorrecto
function buscar_archivos_grandes() {
  local directorio_a_buscar="$1"
  if [[ -z "$directorio_a_buscar" ]]; then
    echo "ERROR: Debes especificar un directorio." >&2
    return 1
  fi
  echo "Buscando archivos de más de 100MB en $directorio_a_buscar"
  find "$directorio_a_buscar" -type f -size +100M -exec ls -lh {} +
}

# Otro error leve: Falta un 'done' en el bucle 'for'
function limpiar_directorio() {
  echo "Limpiando archivos antiguos en $DIRECTORIO_RAIZ..."
  local ahora=$(date +%s)
  local dias_antiguos=30

  for archivo in $(find "$DIRECTORIO_RAIZ" -type f -mtime +$dias_antiguos); do
    echo "Eliminando archivo antiguo: $archivo"
    # rm "$archivo"  # Comentado para evitar borrado accidental
  
  if [ -z "$DIRECTORIO_RAIZ" ]; then
    echo "ERROR: La variable DIRECTORIO_RAIZ no está definida." >&2
    exit 1
  fi
}

# -----------------
# LÓGICA PRINCIPAL
# -----------------

if [[ $# -eq 0 ]]; then
  mostrar_ayuda
  exit 0
fi

case "$1" in
  -p | --procesos)
    mostrar_procesos
    ;;
  -a | --archivos)
    buscar_archivos_grandes "$2"
    ;;
  -c | --clean)
    limpiar_directorio
    ;;
  -h | --help)
    mostrar_ayuda
    ;;
  *)
    echo "Opción no válida: $1" >&2
    mostrar_ayuda
    exit 1
    ;;
esac
