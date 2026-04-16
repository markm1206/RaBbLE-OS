#!/usr/bin/env bash
# bootstrap/lib/checks.sh — Preflight system checks

# Detected values populated by run_preflight_checks
RABBLE_DETECTED_ARCH=""
RABBLE_DETECTED_TARGET=""
RABBLE_PREFLIGHT_PASSED=false

# =============================================================================
# Individual checks — each returns 0 (pass) or 1 (fail)
# =============================================================================

check_os() {
    if [[ -f /etc/fedora-release ]]; then
        local ver
        ver=$(rpm -E %fedora 2>/dev/null || grep -oP '\d+' /etc/fedora-release | head -1)
        RABBLE_FEDORA_VERSION="${ver}"
        if (( ver >= 40 )); then
            status_row "OS" "Fedora ${ver}" "ok"
            return 0
        else
            status_row "OS" "Fedora ${ver} (≥40 required)" "err"
            return 1
        fi
    else
        status_row "OS" "Not Fedora — unsupported" "err"
        return 1
    fi
}

check_arch() {
    RABBLE_DETECTED_ARCH="$(uname -m)"
    case "${RABBLE_DETECTED_ARCH}" in
        x86_64)  status_row "Architecture" "x86_64" "ok" ;;
        aarch64) status_row "Architecture" "aarch64" "ok" ;;
        *)       status_row "Architecture" "${RABBLE_DETECTED_ARCH} (unsupported)" "err"; return 1 ;;
    esac
}

check_sudo() {
    if sudo -n true 2>/dev/null; then
        status_row "sudo" "passwordless available" "ok"
    elif sudo -v 2>/dev/null; then
        status_row "sudo" "available (password required)" "ok"
    else
        status_row "sudo" "not available" "err"
        return 1
    fi
}

check_internet() {
    if curl -fsS --max-time 5 https://dns.google > /dev/null 2>&1; then
        status_row "Internet" "connected" "ok"
    else
        status_row "Internet" "no connection" "err"
        return 1
    fi
}

check_disk_space() {
    local min_gb=10
    local avail_kb
    avail_kb=$(df -k / | awk 'NR==2 {print $4}')
    local avail_gb=$(( avail_kb / 1048576 ))

    if (( avail_gb >= min_gb )); then
        status_row "Disk space (/ free)" "${avail_gb} GB" "ok"
    else
        status_row "Disk space (/ free)" "${avail_gb} GB (need ≥${min_gb} GB)" "warn"
    fi
}

check_wayland() {
    if [[ "${XDG_SESSION_TYPE}" == "wayland" ]] || \
       [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        status_row "Session type" "Wayland" "ok"
    else
        status_row "Session type" "${XDG_SESSION_TYPE:-unknown} (Wayland preferred)" "warn"
    fi
}

check_dnf() {
    if command -v dnf5 &>/dev/null; then
        status_row "Package manager" "dnf5" "ok"
    elif command -v dnf &>/dev/null; then
        status_row "Package manager" "dnf" "ok"
    else
        status_row "Package manager" "dnf not found" "err"
        return 1
    fi
}

check_git() {
    if command -v git &>/dev/null; then
        local ver; ver=$(git --version | awk '{print $3}')
        status_row "Git" "${ver}" "ok"
    else
        status_row "Git" "not installed" "warn"
    fi
}

# Detect hardware target and set RABBLE_DETECTED_TARGET
detect_target() {
    local dmi_product=""
    if [[ -r /sys/class/dmi/id/product_name ]]; then
        dmi_product=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
    fi

    case "${dmi_product}" in
        *"ProArt P16"*|*"PROART P16"*)
            RABBLE_DETECTED_TARGET="asus_proart_p16"
            status_row "Hardware target" "ASUS ProArt P16 (auto)" "ok"
            ;;
        ""|Unknown)
            RABBLE_DETECTED_TARGET="generic"
            status_row "Hardware target" "Generic / unknown — manual selection needed" "warn"
            ;;
        *)
            RABBLE_DETECTED_TARGET="generic"
            status_row "Hardware target" "${dmi_product} → generic" "info"
            ;;
    esac
}

# =============================================================================
# Run all preflight checks
# =============================================================================
run_preflight_checks() {
    section "Preflight Checks"
    echo ""

    local failed=0

    check_os      || (( failed++ )) || true
    check_arch    || (( failed++ )) || true
    check_sudo    || (( failed++ )) || true
    check_internet|| (( failed++ )) || true
    check_disk_space
    check_wayland
    check_dnf     || (( failed++ )) || true
    check_git

    echo ""
    detect_target
    echo ""

    if (( failed > 0 )); then
        warn "${failed} check(s) failed — review above before continuing"
        RABBLE_PREFLIGHT_PASSED=false
    else
        ok "All required checks passed"
        RABBLE_PREFLIGHT_PASSED=true
    fi

    # Persist detected values
    mkdir -p "${RABBLE_STATE_DIR}"
    cat > "${RABBLE_STATE_DIR}/detected.env" <<EOF
RABBLE_DETECTED_ARCH="${RABBLE_DETECTED_ARCH}"
RABBLE_DETECTED_TARGET="${RABBLE_DETECTED_TARGET}"
RABBLE_FEDORA_VERSION="${RABBLE_FEDORA_VERSION:-}"
EOF

    pause
}

# Load previously detected values if available
load_detected_state() {
    local state="${RABBLE_STATE_DIR}/detected.env"
    if [[ -f "${state}" ]]; then
        # shellcheck disable=SC1090
        source "${state}"
    fi
}
