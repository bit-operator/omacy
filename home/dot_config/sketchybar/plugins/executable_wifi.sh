#!/usr/bin/env bash
# Icon only: SSIDs need Location Services on recent macOS; connected/disconnected is what matters.
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/colors.sh"
if [[ -n $(ipconfig getifaddr en0 2>/dev/null) ]]; then
  sketchybar --set "$NAME" icon=󰖩 icon.color="$FG"
else
  sketchybar --set "$NAME" icon=󰖪 icon.color="$RED"
fi
