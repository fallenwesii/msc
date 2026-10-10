#!/bin/bash

# Comprehensive sway reload - mimics hyprland hot reload
# Reloads config, reloads waybar/swaync
# Note: Window rules in sway only apply to NEW windows, not existing ones
# (Hyprland can re-evaluate rules on reload, sway cannot)

notify-send "Sway" "Reloading configuration..." -a "sway" -t 1000

# 1. Reload sway config (keybinds, input, output, etc.)
swaymsg reload

# 2. Reload waybar (picks up new colors/config)
pkill -SIGUSR2 waybar 2>/dev/null || waybar &

# 3. Reload swaync (picks up new colors)
swaync-client -rs 2>/dev/null || true

# 4. Reload terminal colors (ghostty, kitty)
pkill -SIGUSR2 ghostty 2>/dev/null || true
pkill -SIGUSR1 kitty 2>/dev/null || true

# 5. Hot-reload Sway window rules onto EXISTING windows (simulating Hyprland)
# Apps don't control their own borders/sizes in Sway, Sway does. So instead of
# restarting apps, we tell Sway to re-apply the rules right now.
RULES_FILE="$HOME/.config/sway/conf/windowrules.conf"
if [ -f "$RULES_FILE" ]; then
    grep "^for_window" "$RULES_FILE" | while read -r line; do
        # Extract everything after 'for_window ' (e.g., '[app_id="kitty"] floating enable')
        rule="${line#for_window }"
        swaymsg "$rule" >/dev/null 2>&1
    done
fi

# 6. Re-apply global preferences (borders, gaps, corner radius) to all windows
# Parse values dynamically from appearance.conf
APPEARANCE="$HOME/.config/sway/conf/appearance.conf"

if [ -f "$APPEARANCE" ]; then
    BORDER_WIDTH=$(grep "^default_border pixel" "$APPEARANCE" | awk '{print $3}')
    [ -n "$BORDER_WIDTH" ] && {
        swaymsg "[class=\".*\"] border pixel $BORDER_WIDTH" >/dev/null 2>&1
        swaymsg "[app_id=\".*\"] border pixel $BORDER_WIDTH" >/dev/null 2>&1
    }

    CORNER_RADIUS=$(grep "^corner_radius" "$APPEARANCE" | awk '{print $2}')
    [ -n "$CORNER_RADIUS" ] && swaymsg "corner_radius $CORNER_RADIUS" >/dev/null 2>&1

    GAPS_INNER=$(grep "^gaps inner" "$APPEARANCE" | awk '{print $3}')
    [ -n "$GAPS_INNER" ] && swaymsg "gaps inner all set $GAPS_INNER" >/dev/null 2>&1

    GAPS_OUTER=$(grep "^gaps outer" "$APPEARANCE" | awk '{print $3}')
    [ -n "$GAPS_OUTER" ] && swaymsg "gaps outer all set $GAPS_OUTER" >/dev/null 2>&1
fi

notify-send "Sway" "Sway reloaded: Configuration & Window Rules reloaded" -a "sway" -t 2000