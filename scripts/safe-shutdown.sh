#!/bin/zsh
# ~/dotfiles/scripts/safe-shutdown.sh
# Usage: safe-shutdown.sh [shutdown|reboot] [--force]

ACTION="${1:-shutdown}"
FORCE="$2"

# if you use your a term emulator to send this command, add it in the Exclude list.
# if you don't do it. This process won't be fully executed. (I use quick term of 
# omniWM so I don't need to include my kitty term)
EXCLUDE=("Finder" "Dock" "SystemUIServer" "ControlCenter" "NotificationCenter" "Hammerspoon")

should_skip() {
  local name="$1"
  for ex in "${EXCLUDE[@]}"; do
    [[ "$name" == "$ex" ]] && return 0
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

echo "Quitting: ${targets[*]}"
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
    echo "Aborting shutdown so nothing gets lost. Re-run with --force to override, or go handle the app manually."
    exit 1
  fi
fi

if [[ "$ACTION" == "reboot" ]]; then
  osascript -e 'tell application "System Events" to restart'
else
  osascript -e 'tell application "System Events" to shut down'
fi
