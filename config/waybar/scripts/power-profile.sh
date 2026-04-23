#!/usr/bin/env bash
# power-profile.sh — cycle power-profiles-daemon profiles; output Waybar JSON.
# Requires: power-profiles-daemon (dnf install power-profiles-daemon)
# FIX: removed %PROFILE_SHIFT% placeholder from notify-send.
# FIX: cycle now sends SIGRTMIN+8 to waybar to force immediate refresh.
#
# Usage:
#   power-profile.sh get    — print current profile as Waybar JSON
#   power-profile.sh cycle  — advance to next profile, notify

PROFILES=("power-saver" "balanced" "performance")
ICONS=("󰌪" "󰗑" "󱐋")
TIPS=("Power Saver — max battery life" "Balanced — auto tuning" "Performance — max clocks")

get_current_index() {
    local current
    current=$(powerprofilesctl get 2>/dev/null)
    for i in "${!PROFILES[@]}"; do
        [[ "${PROFILES[$i]}" == "$current" ]] && echo "$i" && return
    done
    echo 1  # default to balanced if unknown
}

case "$1" in
    get)
        idx=$(get_current_index)
        printf '{"text":"%s  %s","tooltip":"%s","class":"%s"}\n' \
            "${ICONS[$idx]}" "${PROFILES[$idx]}" "${TIPS[$idx]}" "${PROFILES[$idx]}"
        ;;
    cycle)
        idx=$(get_current_index)
        next=$(( (idx + 1) % ${#PROFILES[@]} ))
        powerprofilesctl set "${PROFILES[$next]}"
        notify-send "Power Profile" "${TIPS[$next]}" \
            --icon=battery-symbolic -t 2000
        # Signal Waybar to refresh this custom module immediately
        pkill -SIGRTMIN+8 waybar
        ;;
    *)
        echo "Usage: $0 {get|cycle}" >&2
        exit 1
        ;;
esac
