#!/usr/bin/env bash
# dotfiles/hyprland/scripts/screenshot.sh
# =============================================================================
# Screenshot helper — region, window, or full screen
# Saves to ~/Pictures/Screenshots/ and copies to clipboard
# =============================================================================

SAVE_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "${SAVE_DIR}"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FILE="${SAVE_DIR}/rabble-${TIMESTAMP}.png"

MODE="${1:-region}"   # region | window | full

case "${MODE}" in
    region)
        # Interactive region select
        grim -g "$(slurp -d)" "${FILE}" && \
            wl-copy < "${FILE}" && \
            notify-send -i "${FILE}" "Screenshot saved" "${FILE}" -t 3000
        ;;
    window)
        # Focused window
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "${GEOM}" "${FILE}" && \
            wl-copy < "${FILE}" && \
            notify-send -i "${FILE}" "Window screenshot saved" "${FILE}" -t 3000
        ;;
    full)
        grim "${FILE}" && \
            wl-copy < "${FILE}" && \
            notify-send -i "${FILE}" "Full screenshot saved" "${FILE}" -t 3000
        ;;
    *)
        echo "Usage: screenshot.sh [region|window|full]" >&2
        exit 1
        ;;
esac
