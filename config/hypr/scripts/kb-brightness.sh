#!/bin/bash
# kb-brightness.sh — set asus keyboard backlight and show SwayOSD with keyboard icon
# Usage: kb-brightness.sh up|down|toggle
DEVICE="asus::kbd_backlight"
MAX=$(brightnessctl --device="$DEVICE" max 2>/dev/null)
CURRENT=$(brightnessctl --device="$DEVICE" get 2>/dev/null)

case "${1:-up}" in
    up)
        brightnessctl --device="$DEVICE" set +1 >/dev/null 2>&1
        CURRENT=$(brightnessctl --device="$DEVICE" get 2>/dev/null)
        ;;
    down)
        brightnessctl --device="$DEVICE" set 1- >/dev/null 2>&1
        CURRENT=$(brightnessctl --device="$DEVICE" get 2>/dev/null)
        ;;
    toggle)
        if [ "${CURRENT:-0}" -gt 0 ]; then
            brightnessctl --device="$DEVICE" set 0 >/dev/null 2>&1
            CURRENT=0
        else
            brightnessctl --device="$DEVICE" set 1 >/dev/null 2>&1
            CURRENT=1
        fi
        ;;
esac

# Show OSD with keyboard icon and progress bar
if [ -n "$MAX" ] && [ "$MAX" -gt 0 ]; then
    PROGRESS=$(awk "BEGIN {printf \"%.4f\", ${CURRENT:-0} / $MAX}")
    swayosd-client \
        --custom-icon input-keyboard-symbolic \
        --custom-progress "$PROGRESS"
fi
