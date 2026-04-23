#!/bin/bash
# screenshot.sh — RaBbLE-OS screenshot utility
# epoch-I: minimal functional version

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILE="$SCREENSHOT_DIR/$(date +%Y%m%d_%H%M%S).png"

case "$1" in
    region)
        grim -g "$(slurp)" "$FILE" && notify-send "Screenshot" "Region saved: $FILE"
        ;;
    screen)
        grim "$FILE" && notify-send "Screenshot" "Screen saved: $FILE"
        ;;
    *)
        # Default: region select
        grim -g "$(slurp)" "$FILE" && notify-send "Screenshot" "Region saved: $FILE"
        ;;
esac
