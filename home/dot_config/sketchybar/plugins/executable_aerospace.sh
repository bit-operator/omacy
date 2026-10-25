#!/usr/bin/env bash
# Redraw every workspace pill: app icons, focused highlight, hide empty ones.
# Bash 3.2 compatible (launchd may run it with /bin/bash).
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/helpers/icon_map.sh"

focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null)

args=()
for sid in $(aerospace list-workspaces --all 2>/dev/null); do
  label=""
  while IFS= read -r app; do
    [[ -n $app ]] || continue
    __icon_map "$app"
    label+="$icon_result "
  done <<<"$(printf '%s\n' "$windows" | awk -F'|' -v s="$sid" '$1 == s { print $2 }' | sort -u)"
  label="${label% }"

  if [[ $sid == "$focused" ]]; then
    args+=(--set "space.$sid" drawing=on background.drawing=on background.color="$ACCENT"
      icon.color="$BG_DARK" label.color="$BG_DARK" label="$label" label.drawing="$([[ -n $label ]] && echo on || echo off)")
  elif [[ -n $label ]]; then
    args+=(--set "space.$sid" drawing=on background.drawing=on background.color="$BG_HL"
      icon.color="$FG" label.color="$MUTED" label="$label" label.drawing=on)
  else
    args+=(--set "space.$sid" drawing=off)
  fi
done

((${#args[@]})) && sketchybar "${args[@]}"
