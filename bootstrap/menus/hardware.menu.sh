#!/usr/bin/env bash
# bootstrap/menus/hardware.menu.sh

hardware_menu() {
    while true; do
        clear; rabble_banner

        draw_menu "Hardware Layer" \
            "Auto-detect and deploy" \
            "ASUS ProArt P16 (hybrid GFX + NPU + asusctl)" \
            "Generic x64" \
            "← Back"

        case "${MENU_CHOICE}" in
            1)
                _select_target_interactive
                run_named_playbook "deploy-hardware" --extra-vars "rabble_target=${RABBLE_DETECTED_TARGET}"
                ;;
            2) run_named_playbook "deploy-hardware" --extra-vars "rabble_target=asus_proart_p16" ;;
            3) run_named_playbook "deploy-hardware" --extra-vars "rabble_target=generic_x64" ;;
            BACK|4) return 0 ;;
        esac
    done
}
