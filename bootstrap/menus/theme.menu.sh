#!/usr/bin/env bash
# bootstrap/menus/theme.menu.sh

theme_menu() {
    while true; do
        clear; rabble_banner

        draw_menu "Theme Management" \
            "Deploy all RaBbLE themes" \
            "Grub2 theme only  (rebuilds grub.cfg)" \
            "Plymouth theme only  (rebuilds initrd — slow)" \
            "SDDM theme only" \
            "Shell themes  (zsh + bash dotfiles)" \
            "Generate theme assets  (imagemagick — run once)" \
            "← Back"

        case "${MENU_CHOICE}" in
            1)
                run_named_playbook "deploy-boot" --tags "grub,plymouth,sddm"
                run_named_playbook "deploy-dotfiles" --tags "shell"
                ;;
            2) run_named_playbook "deploy-boot" --tags grub ;;
            3) run_named_playbook "deploy-boot" --tags plymouth ;;
            4) run_named_playbook "deploy-boot" --tags sddm ;;
            5) run_named_playbook "deploy-dotfiles" --tags shell ;;
            6) _generate_theme_assets ;;
            BACK|7) return 0 ;;
        esac
    done
}

_generate_theme_assets() {
    section "Generate Theme Assets"
    info "Requires: imagemagick (sudo dnf install imagemagick)"
    echo ""

    if ! command -v convert &>/dev/null; then
        warn "imagemagick not found — installing..."
        sudo dnf install -y imagemagick
    fi

    step "Generating Grub2 assets..."
    bash "${RABBLE_ROOT}/themes/grub2/rabble/generate-assets.sh" \
        && ok "Grub2 assets generated" \
        || err "Grub2 asset generation failed"

    step "Generating Plymouth assets..."
    bash "${RABBLE_ROOT}/themes/plymouth/rabble/generate-assets.sh" \
        && ok "Plymouth assets generated" \
        || err "Plymouth asset generation failed"

    echo ""
    info "Now deploy the boot layer to install them:"
    dim "  bootstrap.sh → Boot Layer → Deploy full boot layer"
    pause
}
