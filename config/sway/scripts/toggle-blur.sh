#!/bin/bash

# Toggle systemwide blur by flipping the global wildcard opacity rules
# in windowrules.conf (swayfx only blurs windows with opacity < 1).
# Terminals are exempted by fixed rules and always stay at opacity 1.

RULES="$HOME/.config/sway/conf/windowrules.conf"

if [ ! -f "$RULES" ]; then
  notify-send -u critical "Blur Toggle" "Missing $RULES"
  exit 1
fi

# Read the current value of the [app_id=".*"] wildcard rule
current=$(grep -m1 -oP '^\s*for_window\s+\[app_id="\.\*"\]\s+opacity\s+\K[0-9.]+' "$RULES")

if [ -z "$current" ]; then
  notify-send -u critical "Blur Toggle" "No wildcard opacity rule found in windowrules.conf"
  exit 1
fi

# 0.86 (blur on) -> 1 (blur off), anything else -> 0.86
if awk "BEGIN{exit !($current < 1)}"; then
  new=1
  state="OFF"
else
  new=0.8
  state="ON"
fi

# Flip both wildcard rules (class + app_id)
sed -i -E \
  -e "s|^(\s*for_window\s+\[class=\"\.\*\"\]\s+opacity\s+)[0-9.]+|\1$new|" \
  -e "s|^(\s*for_window\s+\[app_id=\"\.\*\"\]\s+opacity\s+)[0-9.]+|\1$new|" \
  "$RULES"

# 1. Reload config so NEW windows get the new opacity
swaymsg reload >/dev/null 2>&1

# 2. Re-apply every opacity rule to EXISTING windows, in file order,
#    so wildcard rules run first and terminal/special exemptions win
grep -E '^\s*for_window .* opacity ' "$RULES" | while IFS= read -r line; do
  rule="${line#for_window }"
  swaymsg "$rule" >/dev/null 2>&1
done

notify-send -u low -a "Blur" "Blur $state" "Systemwide blur is now $state (opacity $new)"
