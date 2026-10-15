#!/bin/zsh
# ~/dotfiles/scripts/close-apps.sh
# Gracefully quit running apps to free up memory, keeping select apps open.
# Usage: close-apps.sh [--force]

FORCE="$1"

KEEP_OPEN=("Finder" "Dock" "SystemUIServer" "ControlCenter" "NotificationCenter" "Hammerspoon" "kitty" "WhatsApp" "Microsoft Outlook")

should_skip() {
  local name="$1"
  for keep in "${KEEP_OPEN[@]}"; do
    [[ "$name" == "$keep" ]] && return 0
  done
  return 1
}

apps=$(osascript -e '
tell application "System Events"
    set appList to name of every process whose background only is false
end tell
set AppleScript'"'"'s text item delimiters to linefeed
return appList as text
')

targets=()
while IFS= read -r app; do
  [[ -z "$app" ]] && continue
  should_skip "$app" && continue
  targets+=("$app")
done <<< "$apps"

if (( ${#targets[@]} == 0 )); then
  echo "Nothing to close."
  exit 0
fi

echo "Closing: ${targets[*]}"
for app in "${targets[@]}"; do
  osascript -e "tell application \"$app\" to quit" >/dev/null 2>&1
done

max_wait=60
waited=0
still_running=true
while (( waited < max_wait )); do
  still_running=false
  for app in "${targets[@]}"; do
    running=$(osascript -e "application \"$app\" is running" 2>/dev/null)
    [[ "$running" == "true" ]] && still_running=true && break
  done
  $still_running || break
  sleep 1
  ((waited++))
done

if $still_running; then
  echo "Some app didn't quit in time (likely an unsaved-changes prompt waiting on you)."
  if [[ "$FORCE" == "--force" ]]; then
    echo "Force-quitting stragglers..."
    for app in "${targets[@]}"; do
      pkill -9 -x "$app" 2>/dev/null
    done
  else
    echo "Leaving stragglers alone. Re-run with --force to kill them outright."
    exit 1
  fi
fi

echo "Done."
