#!/usr/bin/env bash
# Palette from the active omamac theme, as SketchyBar 0xAARRGGBB colors.
THEME_ENV="$HOME/.config/omamac/current/theme.env"
[[ -r $THEME_ENV ]] || THEME_ENV="$HOME/.config/omamac/themes/tokyonight/theme.env"
# shellcheck disable=SC1090
source "$THEME_ENV"

BAR_COLOR="0xe6$BG_DARK"
for _c in BG BG_DARK BG_HL FG MUTED ACCENT ACCENT2 RED GREEN YELLOW ORANGE CYAN; do
  printf -v "$_c" '0xff%s' "${!_c}"
done
unset _c
TRANSPARENT=0x00000000
FONT="JetBrainsMono Nerd Font"
