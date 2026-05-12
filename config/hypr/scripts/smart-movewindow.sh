#!/usr/bin/env bash
# smart-movewindow.sh — directional window move with split-creation fallback
#
# For l/r: movewindow as normal.
# For u/d: tries movewindow first. If the window didn't move (no vertical
# neighbor because the current split is horizontal), it creates the vertical
# arrangement via togglesplit, then swaps to put the window in the right slot.
#
# Usage: smart-movewindow.sh [l|r|u|d]

dir="${1:-d}"

before=$(hyprctl activewindow -j 2>/dev/null | jq -r '.at | join(",")')
hyprctl dispatch movewindow "$dir" 2>/dev/null
after=$(hyprctl activewindow -j 2>/dev/null | jq -r '.at | join(",")')

# Moved successfully — done
[[ "$before" != "$after" ]] && exit 0

# Didn't move — handle u/d by flipping the split
case "$dir" in
    d)
        # togglesplit turns A|B into A/B with focused window on top.
        # Swap down to put focused window in the bottom slot.
        hyprctl dispatch layoutmsg togglesplit
        hyprctl dispatch swapwindow d 2>/dev/null
        ;;
    u)
        # togglesplit turns A|B into A/B with focused window on top already.
        hyprctl dispatch layoutmsg togglesplit
        ;;
    l) hyprctl dispatch movewindow r ;;
    r) hyprctl dispatch movewindow l ;;
esac
