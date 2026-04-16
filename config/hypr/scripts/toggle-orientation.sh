#!/usr/bin/env bash
# ~/.config/hypr/scripts/toggle-orientation.sh
# Passively toggles the orientation new windows will spawn in.
# Does NOT move any existing windows.

STATE_FILE="/tmp/hypr-orient"

if [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "top" ]]; then
    hyprctl keyword master:orientation left
    echo "left" > "$STATE_FILE"
    notify-send -t 1500 "Layout" "Next window → right (column)"
else
    hyprctl keyword master:orientation top
    echo "top" > "$STATE_FILE"
    notify-send -t 1500 "Layout" "Next window → below (row)"
fi