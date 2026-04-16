#!/usr/bin/env bash
# screenshot.sh — compositor-agnostic screenshot wrapper
# Uses: grim, slurp, wl-clipboard
# Called from compositor keybind configs.
#
# Usage:
#   screenshot.sh full     — capture full screen
#   screenshot.sh region   — interactive region select
#   screenshot.sh window   — capture active window (Hyprland only via hyprctl)

set -euo pipefail

SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SAVE_DIR"
FILE="${SAVE_DIR}/$(date +%Y-%m-%d_%H-%M-%S).png"

case "${1:-full}" in
  full)
    grim "$FILE"
    ;;
  region)
    grim -g "$(slurp)" "$FILE"
    ;;
  window)
    if command -v hyprctl &>/dev/null; then
      GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
      grim -g "$GEOM" "$FILE"
    else
      grim -g "$(slurp)" "$FILE"
    fi
    ;;
  *)
    echo "Usage: screenshot.sh [full|region|window]" >&2
    exit 1
    ;;
esac

wl-copy < "$FILE"
echo "$FILE"
