#!/usr/bin/env bash
# smart-focus.sh — directional focus with cyclenext fallback (i3-style)
#
# In dwindle, movefocus silently does nothing when there's no window in the
# requested direction. This script detects that and cycles to next/prev window
# so up/down always does something useful.
#
# Usage: smart-focus.sh [u|d|l|r]

dir="${1:-d}"

before=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')
hyprctl dispatch movefocus "$dir" 2>/dev/null
after=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')

[[ -n "$before" && "$before" != "$after" ]] && exit 0

# Focus didn't move — cycle
case "$dir" in
    u|l) hyprctl dispatch cyclenext prev ;;
    d|r) hyprctl dispatch cyclenext ;;
esac
