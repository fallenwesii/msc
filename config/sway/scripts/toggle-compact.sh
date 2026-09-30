#!/bin/bash

# Toggle compact mode - no borders, no gaps, no border radius
# Saves current state to restore on toggle

STATE_FILE="$HOME/.cache/sway_compact_mode"

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "compact" ]; then
    # Restore normal mode
    swaymsg "gaps inner 3"
    swaymsg "gaps outer 5"
    swaymsg "default_border pixel 3"
    swaymsg "default_floating_border pixel 3"
    echo "normal" > "$STATE_FILE"
    notify-send "Compact Mode" "Disabled" -a "sway" -t 2000
else
    # Enable compact mode
    swaymsg "gaps inner 0"
    swaymsg "gaps outer 0"
    swaymsg "default_border none"
    swaymsg "default_floating_border none"
    echo "compact" > "$STATE_FILE"
    notify-send "Compact Mode" "Enabled" -a "sway" -t 2000
fi