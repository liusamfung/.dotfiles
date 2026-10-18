#!/bin/bash
# Cicla el foco hacia la derecha entre las columnas del workspace activo.
# Si ya está en la última columna, envuelve (wrap) a la primera.
set -euo pipefail

# kanata (a root daemon) runs this through `sudo -u`, so PATH can be minimal: add both Homebrew prefixes
# (Apple Silicon /opt/homebrew, Intel /usr/local) instead of hardcoding one.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
OMNI=$(command -v omniwmctl) || { echo "omniwmctl not found in PATH" >&2; exit 1; }
JQ=$(command -v jq) || { echo "jq not found in PATH" >&2; exit 1; }

focused_id() {
  "$OMNI" query windows --focused --format json | "$JQ" -r '.result.payload.windows[0].id // empty'
}

before=$(focused_id)
"$OMNI" command focus right >/dev/null
after=$(focused_id)

if [ -n "$before" ] && [ "$before" = "$after" ]; then
  "$OMNI" command focus-column first >/dev/null
fi
