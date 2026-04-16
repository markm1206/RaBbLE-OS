#!/usr/bin/env bash
# bootstrap/lib/ui.sh — UI rendering helpers

# =============================================================================
# Banner
# =============================================================================
rabble_banner() {
    echo ""
    echo -e "${R_VIOLET}"
    cat << 'EOF'
  ██████╗         ██████╗ ██║    ╔██╗     ███████╗
  ██╔══██╗ █████╗ ██╔══██╗██║    ║██║     ██╔════╝
  ██████╔╝██╔══██╗██████╔╝██████ ║██║     █████╗
  ██╔══██╗██████╔╝██╔══██╗██║  ██║██║     ██╔══╝
  ██║  ██║    ██║ ██████╔╝██████╔╝███████╗███████╗
  ╚═╝  ╚═╝      ╚═══════╝ ╚═════╝ ╚══════╝╚══════╝
EOF
    echo -e "${RST}"
    echo -e "  ${R_MUTED}RaBbLE-OS  ${R_VIOLET}v${RABBLE_VERSION}${RST}"
    echo -e "  ${R_MUTED}System: ${LWHITE}$(hostname)${R_MUTED}  ·  Arch: ${LWHITE}$(uname -m)${R_MUTED}  ·  Kernel: ${LWHITE}$(uname -r)${RST}"
    echo ""
}

# =============================================================================
# Menu rendering
# Renders a numbered list and reads user selection.
# Returns the chosen index (1-based) in MENU_CHOICE global.
# =============================================================================
MENU_CHOICE=""

draw_menu() {
    local title="$1"; shift
    local -a items=("$@")
    local last_idx=${#items[@]}

    echo ""
    echo -e "  ${R_VIOLET}${LWHITE}${title}${RST}"
    hr "─" "${R_DARK}"

    local i=1
    for item in "${items[@]}"; do
        # Check for a separator marker
        if [[ "${item}" == "---" ]]; then
            echo ""
        else
            printf "  ${R_TEAL}%2d${RST}  ${LWHITE}%s${RST}\n" "${i}" "${item}"
            ((i++))
        fi
    done

    echo ""
    hr "─" "${R_DARK}"
    local max_choice=$(( i - 1 ))

    while true; do
        echo -ne "  ${R_VIOLET}›${RST} Choose [1-${max_choice}] or ${R_MUTED}q${RST} to go back: "
        read -r choice
        case "${choice}" in
            q|Q|b|B) MENU_CHOICE="BACK"; return 0 ;;
            ''|*[!0-9]*) warn "Enter a number between 1 and ${max_choice}"; continue ;;
            *)
                if (( choice >= 1 && choice <= max_choice )); then
                    MENU_CHOICE="${choice}"; return 0
                else
                    warn "Enter a number between 1 and ${max_choice}"
                fi
            ;;
        esac
    done
}

# =============================================================================
# Confirmation prompt
# Returns 0 for yes, 1 for no
# =============================================================================
confirm() {
    local msg="${1:-Are you sure?}"
    local default="${2:-n}"
    local prompt

    if [[ "${default}" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi

    echo -ne "  ${R_VIOLET}?${RST}  ${LWHITE}${msg}${RST} ${R_MUTED}${prompt}${RST} "
    read -r answer
    answer="${answer:-${default}}"
    [[ "${answer,,}" == "y" ]]
}

# =============================================================================
# Spinner — run a command with animated spinner
# Usage: spinner "Message" command [args...]
# =============================================================================
spinner() {
    local msg="$1"; shift
    local pid frames=('⠋' '⠙' '⠸' '⠴' '⠦' '⠇') frame=0

    echo -ne "  ${SYM_WAIT}  ${LWHITE}${msg}...${RST}"

    "$@" &>/tmp/rabble_spinner_out &
    pid=$!

    while kill -0 "${pid}" 2>/dev/null; do
        echo -ne "\r  ${R_VIOLET}${frames[${frame}]}${RST}  ${LWHITE}${msg}...${RST}"
        frame=$(( (frame + 1) % 6 ))
        sleep 0.1
    done

    wait "${pid}"
    local rc=$?

    if (( rc == 0 )); then
        echo -e "\r  ${SYM_OK}  ${LWHITE}${msg}${RST}"
    else
        echo -e "\r  ${SYM_ERR}  ${LWHITE}${msg} — failed${RST}"
        echo ""
        cat /tmp/rabble_spinner_out | sed 's/^/      /'
    fi

    rm -f /tmp/rabble_spinner_out
    return "${rc}"
}

# =============================================================================
# Pause — wait for user keypress
# =============================================================================
pause() {
    echo ""
    echo -ne "  ${R_MUTED}Press any key to continue...${RST}"
    read -rsn1
    echo ""
}

# =============================================================================
# Status table row
# =============================================================================
status_row() {
    local label="$1"
    local value="$2"
    local status="${3:-ok}"  # ok | warn | err | info

    local sym
    case "${status}" in
        ok)   sym="${SYM_OK}" ;;
        warn) sym="${SYM_WARN}" ;;
        err)  sym="${SYM_ERR}" ;;
        *)    sym="${SYM_INFO}" ;;
    esac

    printf "  %-28s ${R_MUTED}%-30s${RST}  %s\n" \
        "${LWHITE}${label}${RST}" "${value}" "${sym}"
}
