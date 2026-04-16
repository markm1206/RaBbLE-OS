#!/usr/bin/env bash
# bootstrap/lib/colors.sh — ANSI color and style helpers

# --- Reset ---
RST='\033[0m'

# --- Text colors ---
BLACK='\033[0;30m';   GRAY='\033[1;30m'
RED='\033[0;31m';     LRED='\033[1;31m'
GREEN='\033[0;32m';   LGREEN='\033[1;32m'
YELLOW='\033[0;33m';  LYELLOW='\033[1;33m'
BLUE='\033[0;34m';    LBLUE='\033[1;34m'
PURPLE='\033[0;35m';  LPURPLE='\033[1;35m'
CYAN='\033[0;36m';    LCYAN='\033[1;36m'
WHITE='\033[0;37m';   LWHITE='\033[1;37m'

# --- RaBbLE palette (256-color) ---
R_VIOLET='\033[38;5;135m'   # Primary brand purple
R_TEAL='\033[38;5;80m'      # Accent teal
R_PINK='\033[38;5;218m'     # Soft pink
R_DARK='\033[38;5;237m'     # Dark background text
R_MUTED='\033[38;5;245m'    # Muted/secondary text
R_DIM='\033[2m'

# --- Status symbols ---
SYM_OK="${LGREEN}✓${RST}"
SYM_WARN="${LYELLOW}⚠${RST}"
SYM_ERR="${LRED}✗${RST}"
SYM_INFO="${LCYAN}→${RST}"
SYM_WAIT="${R_VIOLET}◈${RST}"
SYM_ARROW="${R_TEAL}▸${RST}"

# --- Helpers ---
ok()   { echo -e "  ${SYM_OK}  ${LWHITE}$*${RST}"; }
warn() { echo -e "  ${SYM_WARN}  ${LYELLOW}$*${RST}"; }
err()  { echo -e "  ${SYM_ERR}  ${LRED}$*${RST}" >&2; }
info() { echo -e "  ${SYM_INFO}  ${LWHITE}$*${RST}"; }
step() { echo -e "\n${R_VIOLET}  ▸ ${LWHITE}$*${RST}"; }
dim()  { echo -e "  ${R_MUTED}$*${RST}"; }

# Print a horizontal rule
hr() {
    local char="${1:--}"
    local col="${2:-${R_DARK}}"
    local width=60
    echo -e "${col}$(printf '%*s' "${width}" | tr ' ' "${char}")${RST}"
}

# Print a section header
section() {
    echo ""
    hr "─" "${R_VIOLET}"
    echo -e "  ${R_VIOLET}${LWHITE}$*${RST}"
    hr "─" "${R_VIOLET}"
}
