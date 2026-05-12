#!/usr/bin/env bash
# toggle-split.sh — i3-style split direction toggle with OSD
#
# Flips the focused node's split direction between horizontal (→ right)
# and vertical (↓ below). With preserve_split=true, dwindle remembers
# this per-node, so it persists for all new windows at that node.
#
# One window on workspace → primes direction before the next window opens.
# Multiple windows → also restructures their current arrangement (side-by-side ↔ stacked).
#
# Usage: bound to a key, no arguments.

STATE=/tmp/.hypr_split

current=$(cat "$STATE" 2>/dev/null || echo "h")

hyprctl dispatch layoutmsg togglesplit

if [ "$current" = "h" ]; then
    echo "v" > "$STATE"
    notify-send -t 1200 -u low "" "Split  ↓  vertical"
else
    echo "h" > "$STATE"
    notify-send -t 1200 -u low "" "Split  →  horizontal"
fi
