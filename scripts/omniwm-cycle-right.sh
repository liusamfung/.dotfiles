#!/bin/bash
# Cicla el foco hacia la derecha entre las columnas del workspace activo.
# Si ya está en la última columna, envuelve (wrap) a la primera.
set -euo pipefail

OMNI=/opt/homebrew/bin/omniwmctl
JQ=/opt/homebrew/bin/jq

focused_id() {
  "$OMNI" query windows --focused --format json | "$JQ" -r '.result.payload.windows[0].id // empty'
}

before=$(focused_id)
"$OMNI" command focus right >/dev/null
after=$(focused_id)

if [ -n "$before" ] && [ "$before" = "$after" ]; then
  "$OMNI" command focus-column first >/dev/null
fi
