#!/bin/bash

# Toggle ghostty scratchpad - launch if not exists, show if hidden, hide if focused

CLASS="ghostty-scratchpad"

# Get the window ID of the scratchpad
WIN_ID=$(swaymsg -t get_tree | jq -r '.. | select(.class? == "'$CLASS'") | .id' | head -1)

if [ -z "$WIN_ID" ]; then
    # Not exists - launch it
    exec ghostty --class="$CLASS"
else
    # Exists - check if focused
    FOCUSED=$(swaymsg -t get_tree | jq -r '.. | select(.focused == true) | .id')
    
    if [ "$WIN_ID" = "$FOCUSED" ]; then
        # Focused - hide it (move to scratchpad)
        swaymsg "[con_id=$WIN_ID] move scratchpad"
    else
        # Not focused - show it
        swaymsg "[con_id=$WIN_ID] scratchpad show"
    fi
fi