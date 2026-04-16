#!/usr/bin/env bash
# RaBbLE-OS-dotctl.sh — Dotfile / Config Deployment Control
#
# spark ~ config >> dotfile apply/pull/status/diff // %DOTCTL_READY%
#
# Usage:
#   ./RaBbLE-OS-dotctl.sh apply  [bundle|all]   — copy repo configs → ~/.config/
#   ./RaBbLE-OS-dotctl.sh pull   BUNDLE         — copy ~/.config/ → repo (capture live edits)
#   ./RaBbLE-OS-dotctl.sh status [bundle|all]   — show in-sync / drifted / missing per file
#   ./RaBbLE-OS-dotctl.sh diff   [bundle|all]   — line diff: repo vs deployed
#   ./RaBbLE-OS-dotctl.sh list                  — list all known bundles

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors ────────────────────────────────────────────────────────────────────

if [[ -t 1 ]]; then
  MAGENTA='\033[38;2;255;45;120m'
  CYAN='\033[38;2;0;245;255m'
  VIOLET='\033[38;2;191;95;255m'
  MUTED='\033[38;2;107;104;128m'
  TEXT='\033[38;2;232;230;240m'
  RED='\033[38;2;224;92;111m'
  GREEN='\033[38;2;80;250;123m'
  YELLOW='\033[38;2;241;250;140m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  MAGENTA='' CYAN='' VIOLET='' MUTED='' TEXT='' RED='' GREEN='' YELLOW='' BOLD='' RESET=''
fi

pulse()   { echo -e "${MAGENTA}${BOLD}::${RESET} ${TEXT}$*${RESET}"; }
info()    { echo -e "${CYAN}  →${RESET} ${TEXT}$*${RESET}"; }
ok()      { echo -e "${GREEN}  ✓${RESET} ${TEXT}$*${RESET}"; }
warn()    { echo -e "${VIOLET}  !${RESET} ${TEXT}$*${RESET}"; }
fail()    { echo -e "${RED}${BOLD}  ✗${RESET} ${RED}$*${RESET}"; exit 1; }
muted()   { echo -e "${MUTED}    $*${RESET}"; }
divider() { echo -e "${MUTED}────────────────────────────────────────────────${RESET}"; }

# ── Bundle definitions ────────────────────────────────────────────────────────
#
# Add new bundles here as config/ grows (waybar, mako, quickshell, etc.)
# SRC paths are relative to SCRIPT_DIR.

declare -A BUNDLE_SRC=(
  [hypr]="config/hypr"
  [waybar]="config/waybar"
)

declare -A BUNDLE_DEST=(
  [hypr]="${HOME}/.config/hypr"
  [waybar]="${HOME}/.config/waybar"
)

declare -A BUNDLE_DESC=(
  [hypr]="Hyprland compositor config"
  [waybar]="Waybar status bar config + scripts"
)

BUNDLE_ORDER=(hypr waybar)

declare -A BUNDLE_RELOAD=(
  [hypr]="hyprctl reload"
  [waybar]="pkill -x waybar || true; setsid --fork waybar &>/dev/null"
)

# ── Helpers ───────────────────────────────────────────────────────────────────

bundle_exists() {
  [[ -n "${BUNDLE_SRC[$1]+_}" ]]
}

resolve_bundles() {
  local arg="${1:-all}"
  if [[ "$arg" == "all" ]]; then
    echo "${BUNDLE_ORDER[@]}"
  else
    bundle_exists "$arg" || fail "Unknown bundle: '$arg'. Known: ${BUNDLE_ORDER[*]}"
    echo "$arg"
  fi
}

# Walk all source files in a bundle, invoke: callback src_file dest_file rel_path
walk_bundle() {
  local bundle="$1"
  local callback="$2"
  local src_root="${SCRIPT_DIR}/${BUNDLE_SRC[$bundle]}"
  local dest_root="${BUNDLE_DEST[$bundle]}"

  [[ -d "$src_root" ]] || fail "Bundle source not found: ${src_root}"

  while IFS= read -r -d '' src_file; do
    local rel="${src_file#${src_root}/}"
    local dest_file="${dest_root}/${rel}"
    "$callback" "$src_file" "$dest_file" "$rel"
  done < <(find "$src_root" -type f -print0 | sort -z)
}

# ── apply ─────────────────────────────────────────────────────────────────────

_apply_file() {
  local src="$1" dest="$2" rel="$3"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  [[ "$src" == */scripts/* ]] && chmod 755 "$dest"
  info "$rel"
}

cmd_apply() {
  local -a bundles
  read -ra bundles <<< "$(resolve_bundles "${1:-all}")"

  for bundle in "${bundles[@]}"; do
    pulse "Applying: ${BUNDLE_DESC[$bundle]}"
    walk_bundle "$bundle" _apply_file
    ok "Bundle '${bundle}' deployed. // %CONFIG_APPLIED%"
    echo
  done
}

# ── pull ──────────────────────────────────────────────────────────────────────

_pull_file() {
  local src="$1" dest="$2" rel="$3"
  if [[ -f "$dest" ]]; then
    mkdir -p "$(dirname "$src")"
    cp "$dest" "$src"
    info "$rel"
  else
    muted "not deployed, skipping: $rel"
  fi
}

cmd_pull() {
  local bundle="${1:-}"
  [[ -z "$bundle" ]] && fail "pull requires a specific bundle. Usage: dotctl pull BUNDLE"
  bundle_exists "$bundle" || fail "Unknown bundle: '$bundle'. Known: ${BUNDLE_ORDER[*]}"

  pulse "Pulling deployed config → repo: ${BUNDLE_DESC[$bundle]}"
  warn "This overwrites repo files with whatever is live in ${BUNDLE_DEST[$bundle]}."
  read -rp "$(echo -e "${RED}  Confirm pull for '${bundle}'? [y/N]: ${RESET}")" confirm
  [[ "${confirm:-N}" =~ ^[Yy]$ ]] || { info "Aborted."; return; }

  echo
  walk_bundle "$bundle" _pull_file
  ok "Bundle '${bundle}' pulled. Review with 'diff ${bundle}' then commit what you want to keep."
}

# ── status ────────────────────────────────────────────────────────────────────

_status_file() {
  local src="$1" dest="$2" rel="$3"
  local state color

  if [[ ! -f "$dest" ]]; then
    state="missing"
    color="$RED"
  else
    local src_sum dest_sum
    src_sum=$(sha256sum  "$src"  | cut -d' ' -f1)
    dest_sum=$(sha256sum "$dest" | cut -d' ' -f1)
    if [[ "$src_sum" == "$dest_sum" ]]; then
      state="in-sync"
      color="$GREEN"
    else
      state="drifted"
      color="$YELLOW"
    fi
  fi

  printf "  ${MUTED}%-44s${RESET} ${color}%s${RESET}\n" "$rel" "$state"
}

cmd_status() {
  local -a bundles
  read -ra bundles <<< "$(resolve_bundles "${1:-all}")"

  echo
  pulse "RaBbLE-OS Dotfile Status"

  for bundle in "${bundles[@]}"; do
    divider
    printf "  ${BOLD}${CYAN}%s${RESET}  —  %s\n" "$bundle" "${BUNDLE_DESC[$bundle]}"
    printf "  ${MUTED}%-44s %s${RESET}\n" "FILE" "STATE"
    divider
    walk_bundle "$bundle" _status_file
  done

  divider
  echo
  muted "Repo config root: ${SCRIPT_DIR}/config/"
  echo
}

# ── diff ──────────────────────────────────────────────────────────────────────

_diff_file() {
  local src="$1" dest="$2" rel="$3"
  if [[ ! -f "$dest" ]]; then
    warn "not deployed: ${rel}"
    return
  fi
  if ! diff -q "$src" "$dest" &>/dev/null; then
    echo -e "${CYAN}── ${rel} ──────────────────────────────────────${RESET}"
    # diff -u repo deployed → '+' means live has something repo doesn't
    diff -u "$src" "$dest" || true
    echo
  fi
}

cmd_diff() {
  local -a bundles
  read -ra bundles <<< "$(resolve_bundles "${1:-all}")"

  for bundle in "${bundles[@]}"; do
    pulse "Diff: ${BUNDLE_DESC[$bundle]}  (− repo  + deployed)"
    walk_bundle "$bundle" _diff_file
    echo
  done
}

# ── reload ───────────────────────────────────────────────────────────────────

cmd_reload() {
  local -a bundles
  read -ra bundles <<< "$(resolve_bundles "${1:-all}")"

  for bundle in "${bundles[@]}"; do
    local reload_cmd="${BUNDLE_RELOAD[$bundle]:-}"
    if [[ -z "$reload_cmd" ]]; then
      muted "no reload defined for '${bundle}' — skipping"
      continue
    fi
    pulse "Reloading: ${BUNDLE_DESC[$bundle]}"
    eval "$reload_cmd"
    ok "Bundle '${bundle}' reloaded. // %RELOADED%"
  done
}

# ── list ──────────────────────────────────────────────────────────────────────

cmd_list() {
  echo
  pulse "Known bundles"
  divider
  for bundle in "${BUNDLE_ORDER[@]}"; do
    local src_root="${SCRIPT_DIR}/${BUNDLE_SRC[$bundle]}"
    local count
    count=$(find "$src_root" -type f 2>/dev/null | wc -l)
    printf "  ${CYAN}%-16s${RESET} %-32s ${MUTED}%s files${RESET}\n" \
      "$bundle" "${BUNDLE_DESC[$bundle]}" "$count"
  done
  echo
}

# ── help ──────────────────────────────────────────────────────────────────────

cmd_help() {
  echo
  echo -e "${MAGENTA}${BOLD}dotctl${RESET} — RaBbLE-OS Dotfile Deployment"
  echo
  echo -e "${BOLD}COMMANDS${RESET}"
  echo -e "  ${CYAN}apply${RESET}  [bundle|all]"
  echo -e "          Copy repo configs → ~/.config/. Creates dirs, sets +x on scripts."
  echo
  echo -e "  ${CYAN}pull${RESET}   BUNDLE"
  echo -e "          Copy deployed configs → repo. Use after live edits you want to keep."
  echo -e "          Requires explicit bundle — no accidental full pulls."
  echo
  echo -e "  ${CYAN}status${RESET} [bundle|all]"
  echo -e "          Show per-file state: in-sync / drifted / missing."
  echo
  echo -e "  ${CYAN}diff${RESET}   [bundle|all]"
  echo -e "          Line diff between repo and deployed. (+) = live has it, (−) = repo has it."
  echo
  echo -e "  ${CYAN}reload${RESET} [bundle|all]"
  echo -e "          Reload a running bundle. Detached — no shell ownership."
  echo
  echo -e "  ${CYAN}list${RESET}"
  echo -e "          List all known bundles and file counts."
  echo
  echo -e "${BOLD}BUNDLES${RESET}"
  for bundle in "${BUNDLE_ORDER[@]}"; do
    printf "  ${CYAN}%-16s${RESET} %s\n" "$bundle" "${BUNDLE_DESC[$bundle]}"
  done
  echo
  echo -e "${BOLD}EXAMPLES${RESET}"
  echo -e "  ${MUTED}./RaBbLE-OS-dotctl.sh apply hypr${RESET}"
  echo -e "  ${MUTED}./RaBbLE-OS-dotctl.sh status${RESET}"
  echo -e "  ${MUTED}./RaBbLE-OS-dotctl.sh diff hypr${RESET}"
  echo -e "  ${MUTED}./RaBbLE-OS-dotctl.sh pull hypr${RESET}"
  echo -e "  ${MUTED}./RaBbLE-OS-dotctl.sh reload waybar${RESET}"
  echo
}

# ── Dispatch ──────────────────────────────────────────────────────────────────

COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
  apply)   cmd_apply  "${1:-}" ;;
  pull)    cmd_pull   "${1:-}" ;;
  status)  cmd_status "${1:-}" ;;
  diff)    cmd_diff   "${1:-}" ;;
  reload)  cmd_reload "${1:-}" ;;
  list)    cmd_list ;;
  help|-h|--help) cmd_help ;;
  *)
    warn "Unknown command: '${COMMAND}'"
    cmd_help
    exit 1
    ;;
esac
