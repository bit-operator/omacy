#!/usr/bin/env bash
free=$(memory_pressure 2>/dev/null | awk -F': ' '/free percentage/ { gsub("%", "", $2); print $2 }')
[[ -n $free ]] && sketchybar --set "$NAME" label="$((100 - free))%"
