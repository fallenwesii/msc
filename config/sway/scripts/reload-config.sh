#!/bin/bash

# Comprehensive sway reload - mimics hyprland hot reload
# Reloads config, re-applies window rules, reloads waybar/swaync

notify-send "Sway" "Reloading configuration..." -a "sway" -t 1000

# 1. Reload sway config (keybinds, input, output, etc.)
swaymsg reload

# 2. Re-apply window rules to all existing windows
# This mimics hyprland's behavior of re-evaluating rules on reload
swaymsg -t get_tree | jq -r '.. | select(.window_properties? or .app_id?) | .id' | while read -r win_id; do
    [ -n "$win_id" ] && swaymsg "[con_id=$win_id]" >/dev/null 2>&1
done

# 3. Reload waybar (picks up new colors/config)
pkill -SIGUSR2 waybar 2>/dev/null || waybar &

# 4. Reload swaync (picks up new colors)
swaync-client -rs 2>/dev/null || true

# 5. Reload dunst (if running)
dunstctl reload 2>/dev/null || true

# 6. Reload gtklock (if running)
pkill -SIGUSR1 gtklock 2>/dev/null || true

# 7. Reload terminal colors (ghostty, kitty)
pkill -SIGUSR2 ghostty 2>/dev/null || true
pkill -SIGUSR1 kitty 2>/dev/null || true

notify-send "Sway" "Configuration reloaded" -a "sway" -t 2000