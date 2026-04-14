#!/usr/bin/env bash
# =============================================================================
# RaBbLE-OS Branch Restructure Script
# =============================================================================
# PURPOSE:  Creates new clean branch architecture for RaBbLE-OS
#           Cherry-picks relevant commits into the correct branches
#           Does NOT delete any existing branches
#
# NEW STRUCTURE:
#   main
#   └── RaBbLE-OS-Bootstrap   (Ansible, provisioning, Fedora Sway Spin base)
#        ├── RaBbLE-OS-UX     (Hyprland, Waybar, themes, keybinds)
#        └── RaBbLE-OS-System (GRUB2, hardware, NPU, Pipewire, boot)
#
# SAFE TO RUN: No branches are deleted. Creates only.
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Logging helpers ───────────────────────────────────────────────────────────
log()     { echo -e "${CYAN}[RaBbLE]${RESET} $*"; }
success() { echo -e "${GREEN}[  OK  ]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[ WARN ]${RESET} $*"; }
error()   { echo -e "${RED}[ FAIL ]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${RESET}"; \
            echo -e "${BOLD}${CYAN}  $*${RESET}"; \
            echo -e "${BOLD}${CYAN}══════════════════════════════════════════${RESET}"; }

# ── Config ────────────────────────────────────────────────────────────────────

# Baseline: RaBbLE-Dev-Clean (fc2ad33) — known good state, has SwayOSD
BOOTSTRAP_BASE="fc2ad33"

# New branch names
BRANCH_BOOTSTRAP="RaBbLE-OS-Bootstrap"
BRANCH_UX="RaBbLE-OS-UX"
BRANCH_SYSTEM="RaBbLE-OS-System"

# ── Commits to cherry-pick per branch ─────────────────────────────────────────
#
# Format: "HASH # comment"
# Order matters — cherry-pick is applied top to bottom
#
# NOTE: %HIGH_ENTROPY% commit (2551d37) is intentionally excluded.
#       Cherry-pick individual stable sub-changes manually if needed.

BOOTSTRAP_PICKS=(
    "c0c5539  # mend ansible >> cleanup package placements"
    "515d15d  # crystalize playbook >> new structure, new hosts, new roles"
    "f8a70ed  # mend ~ lowering entropy: better configs, living package defs"
    "d9d1939  # mend ~ ansible-wrapper path fix + inventory-axis glitch"
    "07c1655  # mend >> bootstrap.sh RaBbLE Logo capitalization fix"
)

UX_PICKS=(
    "41b8df9  # test hyprland conf >> keybinds + windowrules + backup"
    "7cc2f6e  # mend >> fix project theming >> WM/Waybar/ZSH/Kitty consistency"
    "a46de84  # user-fix >> hyprland >> mouse and workspace fixes"
)

SYSTEM_PICKS=(
    "3a93840  # reshape-reality >> Merged BaBbLE ansible >> NPU, GRUB2"
    "834b128  # mend >> fix boot and hardware roles. Mark pipewire TODO"
    "76a27d5  # transcribe >> Boot roadmap clarified, issues logged"
)

# ── Pre-flight checks ─────────────────────────────────────────────────────────

preflight_checks() {
    header "Pre-flight Checks"

    # Must be inside a git repo
    if ! git rev-parse --git-dir &>/dev/null; then
        error "Not inside a git repository. Run this from your RaBbLE-OS repo root."
        exit 1
    fi
    success "Git repository detected"

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        error "Uncommitted changes detected. Stash or commit before running."
        git status --short
        exit 1
    fi
    success "Working tree is clean"

    # Verify baseline commit exists
    if ! git cat-file -e "${BOOTSTRAP_BASE}^{commit}" 2>/dev/null; then
        error "Baseline commit ${BOOTSTRAP_BASE} not found. Fetch all remotes first."
        exit 1
    fi
    success "Baseline commit ${BOOTSTRAP_BASE} (RaBbLE-Dev-Clean) found"

    # Warn if target branches already exist
    for branch in "$BRANCH_BOOTSTRAP" "$BRANCH_UX" "$BRANCH_SYSTEM"; do
        if git show-ref --quiet "refs/heads/${branch}"; then
            warn "Branch '${branch}' already exists locally — will be skipped at creation"
        fi
    done
}

# ── Branch creation ───────────────────────────────────────────────────────────

create_branch() {
    local branch="$1"
    local base="$2"

    if git show-ref --quiet "refs/heads/${branch}"; then
        warn "Branch '${branch}' already exists — skipping creation"
    else
        git checkout -b "${branch}" "${base}"
        success "Created branch '${branch}' from ${base}"
    fi
}

# ── Cherry-pick with conflict guard ──────────────────────────────────────────

cherry_pick_commit() {
    local raw="$1"
    # Strip inline comment to get just the hash
    local hash
    hash=$(echo "${raw}" | awk '{print $1}')
    local comment
    comment=$(echo "${raw}" | sed 's/^[^ ]* *//')

    log "Cherry-picking ${hash}  ${comment}"

    if git cherry-pick "${hash}" --allow-empty; then
        success "  Applied ${hash}"
    else
        error "  CONFLICT on ${hash} — ${comment}"
        error "  Resolve manually, then run: git cherry-pick --continue"
        error "  Or abort this run:           git cherry-pick --abort"
        echo ""
        echo -e "${YELLOW}  Hint: This is likely a conflict between the fedora43 Ansible"
        echo -e "  structure and the RaBbLE-Dev-Testing playbook structure."
        echo -e "  Prefer the RaBbLE-Dev-Testing structure (515d15d) as the newer source.${RESET}"
        exit 1
    fi
}

apply_picks() {
    local branch="$1"
    shift
    local picks=("$@")

    header "Cherry-picking into ${branch}"
    git checkout "${branch}"

    for pick in "${picks[@]}"; do
        cherry_pick_commit "${pick}"
    done

    success "All cherry-picks applied to ${branch}"
}

# ── Push to remote ────────────────────────────────────────────────────────────

push_branches() {
    header "Pushing New Branches to Remote"

    for branch in "$BRANCH_BOOTSTRAP" "$BRANCH_UX" "$BRANCH_SYSTEM"; do
        log "Pushing ${branch}..."
        if git push -u origin "${branch}"; then
            success "Pushed ${branch}"
        else
            warn "Push failed for ${branch} — check remote connectivity or existing remote branch"
        fi
    done
}

# ── KDE / ML4W audit ─────────────────────────────────────────────────────────

kde_audit() {
    header "KDE + ML4W Remnant Audit (scan only — no changes)"

    log "Scanning for KDE, ML4W, Plasma, SDDM references..."
    echo ""

    local found=0
    while IFS= read -r match; do
        echo -e "  ${YELLOW}${match}${RESET}"
        found=1
    done < <(grep -rn -i \
        --include="*.yml" \
        --include="*.yaml" \
        --include="*.sh" \
        --include="*.md" \
        --include="*.conf" \
        -e "kde" -e "ml4w" -e "plasma" -e "sddm" \
        . 2>/dev/null || true)

    if [[ $found -eq 0 ]]; then
        success "No KDE/ML4W/Plasma/SDDM references found"
    else
        warn "Matches found above — review and purge manually per branch"
        warn "Commit purge with tag: %KDE_SUNSET%"
    fi
}

# ── Summary ───────────────────────────────────────────────────────────────────

print_summary() {
    header "Restructure Complete"

    echo -e "${BOLD}New branch state:${RESET}"
    git log --oneline --graph --decorate \
        "main" \
        "${BRANCH_BOOTSTRAP}" \
        "${BRANCH_UX}" \
        "${BRANCH_SYSTEM}" \
        2>/dev/null || git log --oneline --graph --decorate --all

    echo ""
    echo -e "${BOLD}${GREEN}Branches NOT deleted (manual cleanup when ready):${RESET}"
    echo -e "  ${YELLOW}RaBbLE-Dev-Clean${RESET}         (local + origin)"
    echo -e "  ${YELLOW}RaBbLE-Dev-Testing${RESET}       (local + origin)"
    echo -e "  ${YELLOW}origin/RaBbLE-dev-fedora43${RESET}"
    echo -e "  ${YELLOW}origin/RaBbLE-dev${RESET}"
    echo -e "  ${YELLOW}origin/BaBbLE-dev${RESET}"
    echo ""
    echo -e "${BOLD}When ready to purge dead branches, run:${RESET}"
    echo -e "  ${CYAN}git branch -d RaBbLE-Dev-Clean RaBbLE-Dev-Testing${RESET}"
    echo -e "  ${CYAN}git push origin --delete RaBbLE-Dev-Clean RaBbLE-Dev-Testing RaBbLE-dev-fedora43 RaBbLE-dev BaBbLE-dev${RESET}"
    echo ""
    echo -e "${BOLD}Remaining manual tasks:${RESET}"
    echo -e "  1. Review KDE/ML4W audit output above and purge per branch"
    echo -e "  2. Validate Ansible playbooks run cleanly on Fedora Sway Spin baseline"
    echo -e "  3. Consolidate duplicate GRUB2 roles into RaBbLE-OS-System"
    echo -e "  4. Merge RaBbLE-OS-UX + RaBbLE-OS-System → Bootstrap when stable"
    echo -e "  5. Merge Bootstrap → main as %SWAY_BASELINE% checkpoint"
    echo ""
    echo -e "${BOLD}Commit tag to mark Sway baseline:${RESET}  ${CYAN}%SWAY_BASELINE%${RESET}"
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
    echo -e "\n${BOLD}${CYAN}"
    # Render the RaBbLE wordmark with correct mixed-case branding.
    # Tries figlet (font: big) → toilet (font: pagga) → plain fallback.
    # figlet and toilet both respect actual character casing unlike raw
    # box-drawing art which cannot faithfully represent x-height differences.
    if command -v figlet &>/dev/null; then
        figlet -f big "RaBbLE"
    elif command -v toilet &>/dev/null; then
        toilet -f pagga "RaBbLE"
    else
        # Plain fallback — preserves branding casing even without figlet/toilet
        echo "  ██╗    ██████╗  ██╗"
        echo "  ██╗    ██╔══██╗ ██╗"
        echo "  ██╗    ██████╔╝ ██╗"
        echo ""
        echo -e "  ${BOLD}RaBbLE${RESET} — Branch Restructure"
        echo ""
        warn "Install 'figlet' for the full wordmark:  sudo dnf install figlet"
    fi
    echo -e "  Branch Restructure Script${RESET}"
    echo -e "  ${YELLOW}No branches will be deleted.${RESET}\n"

    preflight_checks

    # Phase 1 — Create new branches from clean baseline
    header "Phase 1 — Create New Branches"
    create_branch "$BRANCH_BOOTSTRAP" "$BOOTSTRAP_BASE"
    create_branch "$BRANCH_UX"        "$BOOTSTRAP_BASE"
    create_branch "$BRANCH_SYSTEM"    "$BOOTSTRAP_BASE"

    # Phase 2 — Cherry-pick commits into each branch
    apply_picks "$BRANCH_BOOTSTRAP" "${BOOTSTRAP_PICKS[@]}"
    apply_picks "$BRANCH_UX"        "${UX_PICKS[@]}"
    apply_picks "$BRANCH_SYSTEM"    "${SYSTEM_PICKS[@]}"

    # Phase 3 — Push to remote
    push_branches

    # Phase 4 — KDE/ML4W scan
    kde_audit

    # Summary
    print_summary
}

main "$@"
