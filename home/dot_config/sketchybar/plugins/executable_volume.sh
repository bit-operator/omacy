#!/usr/bin/env bash
vol=${INFO:-$(osascript -e 'output volume of (get volume settings)')}
[[ $vol =~ ^[0-9]+$ ]] || vol=0
if ((vol == 0)); then icon=󰝟; elif ((vol < 34)); then icon=󰕿; elif ((vol < 67)); then icon=󰖀; else icon=󰕾; fi
sketchybar --set "$NAME" icon="$icon" label="${vol}%"
