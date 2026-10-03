#!/bin/bash

# Battery status script for hyprlock

BAT_PATH="/sys/class/power_supply/BAT0"
if [ ! -d "$BAT_PATH" ]; then
  for b in /sys/class/power_supply/BAT*; do
    if [ -d "$b" ]; then
      BAT_PATH="$b"
      break
    fi
  done
fi

if [ ! -d "$BAT_PATH" ]; then
  echo ""
  exit 0
fi

capacity=$(cat "$BAT_PATH/capacity" 2>/dev/null)
status=$(cat "$BAT_PATH/status" 2>/dev/null)

case "$status" in
  "Charging") icon="󰂄" ;;
  "Full") icon="󰁹" ;;
  "Discharging")
    if [ "$capacity" -ge 90 ]; then icon="󰁹"
    elif [ "$capacity" -ge 70 ]; then icon="󰂂"
    elif [ "$capacity" -ge 50 ]; then icon="󰂀"
    elif [ "$capacity" -ge 30 ]; then icon="󰁾"
    elif [ "$capacity" -ge 10 ]; then icon="󰁼"
    else icon="󰂎"; fi
    ;;
  *) icon="󰂑" ;;
esac

echo "$icon $capacity%"