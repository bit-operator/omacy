#!/usr/bin/env bash
ncpu=$(sysctl -n hw.ncpu)
load=$(ps -A -o %cpu= | awk -v n="$ncpu" '{ s += $1 } END { printf "%.0f", s / n }')
sketchybar --set "$NAME" label="${load}%"
