#!/usr/bin/env bash
# bootstrap/menus/main.menu.sh

main_menu() {
    while true; do
        clear
        rabble_banner

        draw_menu "Main Menu" \
            "Preflight checks" \
            "Setup Ansible" \
            "Full system deploy" \
            "Deploy by layer →" \
            "Theme management →" \
            "Dotfile tools →" \
            "Recovery tools →" \
            "---" \
            "View last log" \
            "About" \
            "Quit"

        case "${MENU_CHOICE}" in
            1)  run_preflight_checks ;;
            2)  setup_ansible ;;
            3)  full_deploy ;;
            4)  layer_menu ;;
            5)  theme_menu ;;
            6)  dotfile_tools_menu ;;
            7)  recovery_menu ;;
            8)  show_last_log ;;
            9)  about_screen ;;
            10) exit 0 ;;
            BACK) exit 0 ;;
        esac
    done
}

# =============================================================================
# Dotfile tools — deploy / diff / pull
# =============================================================================
dotfile_tools_menu() {
    while true; do
        clear
        rabble_banner

        draw_menu "Dotfile Tools" \
            "Deploy dotfiles  (repo → ~/.config, copies)" \
            "Diff dotfiles    (show what has drifted from repo)" \
            "Pull dotfiles    (~/.config → repo, for committing edits)" \
            "← Back"

        case "${MENU_CHOICE}" in
            1)
                section "Deploying dotfiles"
                info "Copies all dotfiles/ into ~/.config — safe to run any time"
                echo ""
                run_named_playbook "deploy-dotfiles"
                ;;
            2)
                section "Diffing dotfiles (dry-run)"
                info "Showing which live files differ from the repo. Nothing is changed."
                echo ""
                run_named_playbook "pull-dotfiles"
                ;;
            3)
                section "Pull dotfiles back to repo"
                warn "This copies your live ~/.config files INTO the repo."
                warn "Use when you have edited deployed files directly and want to commit."
                echo ""
                if confirm "Pull changed deployed files into dotfiles/?" "n"; then
                    run_named_playbook "pull-dotfiles" -e "rabble_pull=true"
                    echo ""
                    info "Review with: git -C ${RABBLE_ROOT} diff dotfiles/"
                    info "Then: git -C ${RABBLE_ROOT} add dotfiles/ && git commit"
                fi
                pause
                ;;
            BACK|4) return 0 ;;
        esac
    done
}

# =============================================================================
# Layer menu
# =============================================================================
layer_menu() {
    while true; do
        clear
        rabble_banner

        draw_menu "Deploy by Layer" \
            "Core / base system" \
            "Hardware layer →" \
            "Boot layer (Grub2 + Plymouth + SDDM) →" \
            "Snapper (snapshot management)" \
            "UI / UX layer →" \
            "← Back"

        case "${MENU_CHOICE}" in
            1) run_layer "core"    "Core / Base System" ;;
            2) hardware_menu ;;
            3) boot_menu ;;
            4) run_layer "snapper" "Snapper" ;;
            5) ui_menu ;;
            6|BACK) return 0 ;;
        esac
    done
}

# =============================================================================
# Recovery menu
# =============================================================================
recovery_menu() {
    while true; do
        clear
        rabble_banner

        draw_menu "Recovery Tools" \
            "Re-run core role" \
            "Re-run boot layer" \
            "Re-run UI/UX layer" \
            "Re-run shell configs only" \
            "Rollback via Snapper (list snapshots)" \
            "Re-deploy all dotfiles from repo" \
            "← Back"

        case "${MENU_CHOICE}" in
            1) run_layer "core"   "Core (recovery)" ;;
            2) run_layer "boot"   "Boot layer (recovery)" ;;
            3) run_layer "ui_ux"  "UI/UX (recovery)" ;;
            4) run_layer "shell"  "Shell configs (recovery)" ;;
            5) snapper_rollback ;;
            6) run_named_playbook "deploy-dotfiles" ;;
            BACK|7) return 0 ;;
        esac
    done
}

snapper_rollback() {
    section "Snapper Rollback"
    if ! command -v snapper &>/dev/null; then
        warn "Snapper not installed — deploy the snapper layer first"
        pause
        return
    fi
    info "Available snapshots:"
    echo ""
    sudo snapper list
    echo ""
    warn "To rollback: sudo snapper rollback <number>"
    warn "Then reboot into the snapshot via GRUB."
    pause
}

# =============================================================================
# About screen
# =============================================================================
about_screen() {
    section "About RaBbLE"
    echo ""
    dim "  RaBbLE — Rabbit's Brilliant Linux Experience"
    dim "  Version   : ${RABBLE_VERSION}"
    dim "  Repo      : ${RABBLE_ROOT}"
    dim "  Logs      : ${RABBLE_LOG_DIR}"
    dim "  State     : ${RABBLE_STATE_DIR}"
    echo ""
    dim "  Stack: Fedora → Hyprland + Quickshell"
    dim "  Boot:  Grub2 (RaBbLE) → Plymouth (RaBbLE) → SDDM (RaBbLE)"
    echo ""
    dim "  Dotfiles strategy: COPY (not symlink)"
    dim "  Edit in repo → Deploy | Edit live → Pull back"
    echo ""
    pause
}
