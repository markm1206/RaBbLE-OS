#!/usr/bin/env bash
# bootstrap/menus/boot.menu.sh

boot_menu() {
    while true; do
        clear; rabble_banner

        draw_menu "Boot Layer" \
            "Deploy full boot layer (Grub2 + Plymouth + SDDM)" \
            "Grub2 theme only" \
            "Plymouth theme only" \
            "SDDM session manager only" \
            "HiDPI TTY (vconsole + terminus fonts)" \
            "← Back"

        case "${MENU_CHOICE}" in
            1) run_named_playbook "deploy-boot" ;;
            2) run_named_playbook "deploy-boot" --tags grub ;;
            3) run_named_playbook "deploy-boot" --tags plymouth ;;
            4) run_named_playbook "deploy-boot" --tags sddm ;;
            5) run_named_playbook "deploy-boot" --tags tty ;;
            BACK|6) return 0 ;;
        esac
    done
}
