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

# 4. Reload gtklock (if running)
pkill -SIGUSR1 gtklock 2>/dev/null || true

# 5. Reload terminal colors (ghostty, kitty)
pkill -SIGUSR2 ghostty 2>/dev/null || true
pkill -SIGUSR1 kitty 2>/dev/null || true

notify-send "Sway" "Configuration reloaded" -a "sway" -t 2000