#!/usr/bin/env bash
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/colors.sh"
batt=$(pmset -g batt)
pct=$(grep -Eo '[0-9]+%' <<<"$batt" | tr -d %)
[[ -n $pct ]] || { sketchybar --set "$NAME" drawing=off; exit 0; }

case $pct in
  9[0-9] | 100) icon=󰁹 ;; 8[0-9]) icon=󰂂 ;; 7[0-9]) icon=󰂁 ;; 6[0-9]) icon=󰂀 ;; 5[0-9]) icon=󰁿 ;;
  4[0-9]) icon=󰁾 ;; 3[0-9]) icon=󰁽 ;; 2[0-9]) icon=󰁼 ;; 1[0-9]) icon=󰁻 ;; *) icon=󰂃 ;;
esac
color=$FG
((pct <= 20)) && color=$RED
((pct > 20 && pct <= 40)) && color=$YELLOW
grep -q 'AC Power' <<<"$batt" && { icon=󰂄; color=$GREEN; }

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$color" label="${pct}%"
