#!/bin/bash
# ~/.config/sway/scripts/clipboard.sh

mapfile -t raw < <(cliphist list)
if [ ${#raw[@]} -eq 0 ]; then
  notify-send "Clipboard" "History is empty"
  exit 0
fi

# Strip "<id><TAB>" for display only — plain string op, no shell re-parsing
displayed=()
for line in "${raw[@]}"; do
  displayed+=("${line#*$'\t'}")
done

sel=$(printf '%s\n' "${displayed[@]}" | wofi --dmenu --prompt "Clipboard")
[ -z "$sel" ] && exit 0

for i in "${!displayed[@]}"; do
  if [ "${displayed[$i]}" = "$sel" ]; then
    printf '%s\n' "${raw[$i]}" | cliphist decode | wl-copy
    exit 0
  fi
done
