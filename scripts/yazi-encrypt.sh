#!/bin/zsh
# ~/dotfiles/scripts/yazi-encrypt.sh
# Compresses files into a 7z with the strongest protection 7-Zip offers: AES-256 with the key derived from the
# password by 2^19 rounds of SHA-256, and the file names encrypted too (-mhe=on). 7zz asks for the password in the
# terminal (hidden, with confirmation), so it never shows up in `ps` or in the shell history.
# Usage: yazi-encrypt.sh file-or-folder ...      (`Ce` in yazi)
# It asks for the archive name first (prefilled with the first item's name, docs -> docs.7z; edit it or press
# Enter to accept) and creates the archive next to the files. If that name is taken it uses "name (1).7z",
# "name (2).7z", ...

set -u

(( $# > 0 )) || { echo "Usage: ${0:t} file-or-folder ..." >&2; exit 2; }

pause() { read -r "?Press Enter to return to yazi"; }

# yazi passes absolute or relative paths; work from the folder of the first item and store plain names
cd "${1:h}" || { pause; exit 1; }
names=("${@:t}")
out="${names[1]}.7z"
vared -p "Archive name: " out
out="${out%.7z}.7z"   # always end in .7z, even if the extension was left out
if [[ $out == .7z ]]; then
  echo "Empty name: nothing done." >&2
  pause
  exit 1
fi

# 7zz adds to an archive that already exists, which would silently mix files into it: pick the first free
# "name (1).7z", "name (2).7z", ... instead
if [[ -e $out ]]; then
  base=${out%.7z}
  n=1
  while [[ -e "$base ($n).7z" ]]; do
    (( n++ ))
  done
  echo "$out already exists: using $base ($n).7z"
  out="$base ($n).7z"
fi

echo "Encrypting ${#names} item(s) into $out (7z, AES-256, names encrypted)"
if 7zz a -t7z -mhe=on -p "$out" -- "${names[@]}"; then
  echo "Created $out"
else
  echo "7zz failed" >&2
fi
pause
