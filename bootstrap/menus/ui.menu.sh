#!/usr/bin/env bash
# bootstrap/menus/ui.menu.sh

ui_menu() {
    while true; do
        clear; rabble_banner

        draw_menu "UI / UX Layer" \
            "Deploy full UI/UX layer" \
            "Hyprland + xdg-portal only" \
            "Quickshell only" \
            "Terminal (foot + kitty) only" \
            "Shell configs (zsh + bash) only" \
            "Link dotfiles (hyprland + quickshell)" \
            "← Back"

        case "${MENU_CHOICE}" in
            1) run_named_playbook "deploy-ui" ;;
            2) run_named_playbook "deploy-ui" --tags hyprland ;;
            3) run_named_playbook "deploy-ui" --tags quickshell ;;
            4) run_named_playbook "deploy-ui" --tags terminal ;;
            5) run_named_playbook "deploy-ui" --tags shell ;;
            6) run_named_playbook "deploy-dotfiles" ;;
            BACK|7) return 0 ;;
        esac
    done
}
