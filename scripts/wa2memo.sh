#!/bin/zsh
# ~/dotfiles/scripts/wa2memo.sh
# Converts WhatsApp audios (.opus) to .m4a and imports them into the macOS Voice Memos app.
# Voice Memos only accepts m4a, so dragging a .opus onto it does nothing.
# Usage: wa2memo.sh [file.opus ...]
#   With no arguments it takes the newest .opus in ~/Downloads.

set -u

DOWNLOADS="$HOME/Downloads"
files=("$@")

if (( ${#files[@]} == 0 )); then
  newest=$(ls -t "$DOWNLOADS"/*.opus(N) 2>/dev/null | head -n 1)
  if [[ -z "$newest" ]]; then
    echo "No .opus files given and none found in $DOWNLOADS" >&2
    exit 1
  fi
  files=("$newest")
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

converted=()
for src in "${files[@]}"; do
  if [[ ! -f "$src" ]]; then
    echo "Skipping (not a file): $src" >&2
    continue
  fi
  # Voice Memos uses the file name as the recording title.
  title="${${src:t:r}/#WhatsApp Audio /WhatsApp }"
  out="$tmp/$title.m4a"
  # afconvert ships with macOS and decodes Opus, so no ffmpeg needed.
  if afconvert -f m4af -d aac "$src" "$out" 2>/dev/null; then
    converted+=("$out")
    echo "Converted: ${src:t} -> $title.m4a"
  else
    echo "Could not convert: $src" >&2
  fi
done

if (( ${#converted[@]} == 0 )); then
  exit 1
fi

# `open -a` hands the files to Voice Memos the same way a drag onto its icon does.
open -a "VoiceMemos" "${converted[@]}"

# Voice Memos copies the file asynchronously; wait so the temp dir is not removed too early.
sleep 3
echo "Imported ${#converted[@]} recording(s) into Voice Memos."
