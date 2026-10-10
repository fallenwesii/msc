#!/usr/bin/env bash
# light-mode.sh — toggle between light and dark desktop mode.
#
# Source of truth for the current mode is ~/.cache/matugen_mode ("dark"/"light",
# defaults to dark). Toggling swaps ALL THREE of: palette (matugen), wallpaper
# (awww), and the GTK color-scheme (gsettings), so nothing ever desyncs.
#
#   LIGHT: picks a RANDOM wallpaper from ~/Pictures/wallpapers/light-mode/.
#   DARK:  picks a RANDOM wallpaper from ~/Pictures/wallpapers/.
# No wallpaper is remembered between toggles — every switch surfaces a fresh
# random pick from the respective directory.

set -u

MODE_FILE="$HOME/.cache/matugen_mode"
LIGHT_DIR="$HOME/Pictures/wallpapers/light-mode"
MAIN_DIR="$HOME/Pictures/wallpapers"
TRANSITION_DURATION=1

# Current mode (default dark)
mode="dark"
[[ -f "$MODE_FILE" ]] && mode="$(cat "$MODE_FILE" 2>/dev/null)"

apply_wallpaper() {
  local img="$1"
  command -v awww >/dev/null 2>&1 &&
    awww img --transition-type grow --transition-duration "$TRANSITION_DURATION" "$img" >/dev/null 2>&1
  # Let the transition start before matugen's `swaymsg reload` (which would
  # otherwise freeze the animation mid-flight).
  sleep "$TRANSITION_DURATION"
}

apply_gsettings() {
  local scheme="$1"
  command -v gsettings >/dev/null 2>&1 &&
    gsettings set org.gnome.desktop.interface color-scheme "$scheme"
}

notify_mode() {
  local label="$1" img="$2"
  command -v notify-send >/dev/null 2>&1 &&
    notify-send -a 'Theme Mode' -i "$img" "Switched to $label Mode" "${img##*/}" 2>/dev/null
}

if [[ "$mode" == "dark" ]]; then
  # ---- Switch to LIGHT ----------------------------------------------------
  if [[ ! -d "$LIGHT_DIR" ]] || [[ -z "$(find "$LIGHT_DIR" -maxdepth 1 -type f 2>/dev/null | head -n1)" ]]; then
    notify-send -u critical -a 'Theme Mode' "No light wallpapers" \
      "Add images to $LIGHT_DIR first." 2>/dev/null
    exit 1
  fi

  # Random wallpaper from the light-mode directory.
  light_wall="$(find "$LIGHT_DIR" -maxdepth 1 -type f 2>/dev/null | shuf -n1)"
  if [[ -z "$light_wall" || ! -f "$light_wall" ]]; then
    notify-send -u critical -a 'Theme Mode' "No light wallpapers" \
      "Could not pick a wallpaper from $LIGHT_DIR." 2>/dev/null
    exit 1
  fi

  apply_wallpaper "$light_wall"
  if command -v matugen >/dev/null 2>&1; then
    matugen image "$light_wall" -m light --source-color-index 0 --lightness-light 0 >/dev/null 2>&1
  fi
  apply_gsettings 'prefer-light'
  echo light >"$MODE_FILE"
  notify_mode "Light" "$light_wall"

else
  # ---- Switch to DARK -----------------------------------------------------
  # Random wallpaper from the main wallpapers dir (no memory between toggles).
  dark_wall="$(find "$MAIN_DIR" -maxdepth 1 -type f 2>/dev/null | shuf -n1)"

  if [[ -z "$dark_wall" || ! -f "$dark_wall" ]]; then
    notify-send -u critical -a 'Theme Mode' "No dark wallpapers" \
      "Could not pick a wallpaper from $MAIN_DIR." 2>/dev/null
    exit 1
  fi

  apply_wallpaper "$dark_wall"
  if command -v matugen >/dev/null 2>&1; then
    matugen image "$dark_wall" -m dark --source-color-index 0 --contrast 0 --lightness-dark 0.14 >/dev/null 2>&1
  fi
  apply_gsettings 'prefer-dark'
  echo dark >"$MODE_FILE"
  notify_mode "Dark" "$dark_wall"
fi
