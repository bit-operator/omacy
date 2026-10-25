#!/usr/bin/env bash
# EN / HE indicator — updates on every input-source switch.
if command -v macism >/dev/null; then
  src=$(macism)
else
  src=$(defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null | grep -m1 'KeyboardLayout Name')
fi
case $src in
  *Hebrew*) label=HE ;;
  *) label=EN ;;
esac
sketchybar --set "$NAME" label="$label"
