#!/usr/bin/env bash
# =============================================================================
# RaBbLE Bootstrap — System Setup & Recovery
# =============================================================================
# Entry point for deploying and managing the RaBbLE OS experience.
# Wraps ansible so users never need to interact with it directly.
#
# Run from anywhere:
#   ./bootstrap.sh          — interactive menu
#   ./bootstrap.sh --help   — show usage
#
# The repo can live anywhere. Deployed dotfiles are copies — they work
# independently of where this repo is or whether it still exists.
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

RABBLE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RABBLE_LOG_DIR="${HOME}/.rabble/logs"
RABBLE_STATE_DIR="${HOME}/.rabble/state"
RABBLE_VERSION="0.1.0"

# Source library modules
source "${RABBLE_ROOT}/bootstrap/lib/colors.sh"
source "${RABBLE_ROOT}/bootstrap/lib/ui.sh"
source "${RABBLE_ROOT}/bootstrap/lib/checks.sh"
source "${RABBLE_ROOT}/bootstrap/lib/ansible.sh"

# Source menu modules
source "${RABBLE_ROOT}/bootstrap/menus/main.menu.sh"
source "${RABBLE_ROOT}/bootstrap/menus/hardware.menu.sh"
source "${RABBLE_ROOT}/bootstrap/menus/boot.menu.sh"
source "${RABBLE_ROOT}/bootstrap/menus/ui.menu.sh"
source "${RABBLE_ROOT}/bootstrap/menus/theme.menu.sh"

# =============================================================================
# Initialisation
# =============================================================================
init() {
    mkdir -p "${RABBLE_LOG_DIR}" "${RABBLE_STATE_DIR}"
    RABBLE_LOG="${RABBLE_LOG_DIR}/bootstrap-$(date +%Y%m%d-%H%M%S).log"
    exec > >(tee -a "${RABBLE_LOG}") 2>&1
}

# =============================================================================
# Entry point
# =============================================================================
main() {
    init
    clear
    rabble_banner
    sleep 0.4
    main_menu
}

main "$@"
