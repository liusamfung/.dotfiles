#!/bin/zsh
# ~/dotfiles/scripts/startup-apps.sh
# Opens the apps you always want running after login.

STARTUP_APPS=(
  "WhatsApp"
  "kitty"
  "Microsoft Outlook"
)

for app in "${STARTUP_APPS[@]}"; do
  open -a "$app"
done
