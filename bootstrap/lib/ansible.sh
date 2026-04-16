#!/usr/bin/env bash
# bootstrap/lib/ansible.sh — Ansible install, config, and run wrappers

ANSIBLE_INVENTORY="${RABBLE_ROOT}/ansible/inventory/hosts.yml"
ANSIBLE_SITE="${RABBLE_ROOT}/ansible/site.yml"
ANSIBLE_PLAYBOOKS="${RABBLE_ROOT}/ansible/"
ANSIBLE_ROLES="${RABBLE_ROOT}/ansible/roles"

# =============================================================================
# Install ansible via pipx (isolated, no system pollution)
# =============================================================================
setup_ansible() {
    section "Ansible Setup"
    echo ""

    # Check if already installed
    if command -v ansible-playbook &>/dev/null; then
        local ver; ver=$(ansible --version | head -1 | awk '{print $NF}' | tr -d ']')
        ok "Ansible already installed: ${ver}"
        echo ""

        # Still check/install requirements
        _install_requirements
        pause
        return 0
    fi

    step "Installing pipx (ansible host)"
    spinner "Installing pipx" sudo dnf install -y pipx python3-pip

    step "Installing ansible via pipx"
    spinner "Installing ansible-core" pipx install ansible-core
    spinner "Ensuring pipx path in shell" pipx ensurepath

    # Make ansible available in current session
    export PATH="${HOME}/.local/bin:${PATH}"

    step "Installing ansible community collections"
    _install_requirements

    ok "Ansible setup complete"
    pause
}

_install_requirements() {
    if [[ -f "${RABBLE_ROOT}/ansible/requirements.yml" ]]; then
        spinner "Installing ansible collections" \
            ansible-galaxy collection install \
            -r "${RABBLE_ROOT}/ansible/requirements.yml" \
            --upgrade
    fi
}

# =============================================================================
# Run a playbook with standard options
# Usage: run_playbook <playbook_path> [extra_args...]
# =============================================================================
run_playbook() {
    local playbook="$1"; shift
    local extra_args=("$@")

    if ! command -v ansible-playbook &>/dev/null; then
        err "Ansible not found — run 'Setup Ansible' first"
        pause
        return 1
    fi

    # Resolve localhost inventory if no hosts file
    local inventory_arg="-i ${ANSIBLE_INVENTORY}"

    echo ""
    info "Running: ansible-playbook ${playbook}"
    echo ""

 # Hard-quote the inventory path to prevent shell-split 'ghosts'
    ansible-playbook \
        -i "${ANSIBLE_INVENTORY}" \
        -K \
        "${playbook}" \
        "${extra_args[@]}"

    local rc=$?
    echo ""
    if (( rc == 0 )); then
        ok "Playbook completed successfully"
    else
        err "Playbook failed (exit ${rc}) — check log: ${RABBLE_LOG}"
    fi
    pause
    return "${rc}"
}

# =============================================================================
# Run site.yml for a specific layer via tags
# =============================================================================
run_layer() {
    local tag="$1"
    local label="${2:-${tag}}"
    section "Deploying: ${label}"
    run_playbook "${ANSIBLE_SITE}" --tags "${tag}"
}

# =============================================================================
# Run a named playbook from ansible/playbooks/
# =============================================================================
run_named_playbook() {
    local name="$1"; shift
    local playbook="${ANSIBLE_PLAYBOOKS}/${name}.yml"

    if [[ ! -f "${playbook}" ]]; then
        err "Playbook not found: ${playbook}"
        pause
        return 1
    fi

    section "Running: ${name}"
    run_playbook "${playbook}" "$@"
}

# =============================================================================
# Run full site.yml (all layers)
# =============================================================================
full_deploy() {
    section "Full System Deploy"

    if ! confirm "This will deploy all enabled layers. Continue?" "n"; then
        return 0
    fi

    _select_target_interactive
    run_playbook "${ANSIBLE_SITE}"
}

# =============================================================================
# Interactively select hardware target if not auto-detected
# =============================================================================
_select_target_interactive() {
    load_detected_state

    if [[ "${RABBLE_DETECTED_TARGET}" != "generic" ]] && \
       [[ -n "${RABBLE_DETECTED_TARGET}" ]]; then
        info "Using auto-detected target: ${RABBLE_DETECTED_TARGET}"
        return 0
    fi

    draw_menu "Select hardware target" \
        "ASUS ProArt P16 (x64, hybrid GFX, NPU)" \
        "Generic x64 (no hardware-specific tuning)" \
        "Skip hardware layer"

    case "${MENU_CHOICE}" in
        1) RABBLE_DETECTED_TARGET="asus_proart_p16" ;;
        2) RABBLE_DETECTED_TARGET="generic_x64" ;;
        3) RABBLE_DETECTED_TARGET="skip" ;;
        BACK) return 0 ;;
    esac

    # Persist selection
    sed -i "s/RABBLE_DETECTED_TARGET=.*/RABBLE_DETECTED_TARGET=\"${RABBLE_DETECTED_TARGET}\"/" \
        "${RABBLE_STATE_DIR}/detected.env" 2>/dev/null || true
}

# =============================================================================
# Show last ansible log
# =============================================================================
show_last_log() {
    section "Last Ansible Log"
    local last_log
    last_log=$(ls -t "${RABBLE_LOG_DIR}"/*.log 2>/dev/null | head -1 || true)

    if [[ -z "${last_log}" ]]; then
        warn "No logs found in ${RABBLE_LOG_DIR}"
    else
        info "Log: ${last_log}"
        echo ""
        tail -80 "${last_log}" | less -R
    fi
    pause
}
