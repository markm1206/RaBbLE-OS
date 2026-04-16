#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  RaBbLE-OS Bootstrap Script                                      ║
# ║  Zero → Ansible on a fresh Fedora 43 install                    ║
# ║                                                                  ║
# ║  Usage: sudo bash scripts/bootstrap.sh                           ║
# ║  Run from: inside the cloned RaBbLE-OS repo directory            ║
# ╚══════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Color output ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
MAGENTA='\033[0;35m'; YELLOW='\033[1;33m'; NC='\033[0m'

log()  { echo -e "${CYAN}[RaBbLE]${NC} $1"; }
ok()   { echo -e "${GREEN}[  OK  ]${NC} $1"; }
warn() { echo -e "${YELLOW}[ WARN ]${NC} $1"; }
fail() { echo -e "${RED}[ FAIL ]${NC} $1"; exit 1; }

echo -e "${MAGENTA}"
cat << 'EOF'
  ____       ____  _     _     _____        ___  ____
 |  _ \ __ _| __ )| |__ | |   | ____|      / _ \/ ___|
 | |_) / _` |  _ \| '_ \| |   |  _|       | | | \___ \
 |  _ < (_| | |_) | |_) | |___| |___      | |_| |___) |
 |_| \_\__,_|____/|_.__/|_____|_____|      \___/|____/
 Low Entropy. Infinite Resonance.
EOF
echo -e "${NC}"

# ─── Verify running as root ───────────────────────────────────────
[[ $EUID -ne 0 ]] && fail "Run as root: sudo bash scripts/bootstrap.sh"

# ─── Detect repo root ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
log "Repo root: $REPO_ROOT"

[[ -f "$REPO_ROOT/ansible/site.yml" ]] || \
  fail "ansible/site.yml not found. Run bootstrap from inside the RaBbLE-OS repo."

# ─── 1. System update ─────────────────────────────────────────────
log "Updating system packages..."
dnf upgrade -y --quiet
ok "System updated"

# ─── 2. Install Ansible and dependencies ──────────────────────────
log "Installing Ansible..."
dnf install -y ansible ansible-core python3-pip python3-devel git curl
ok "Ansible installed: $(ansible --version | head -1)"

# ─── 3. Ansible Galaxy collections ───────────────────────────────
log "Installing Ansible Galaxy collections..."
ansible-galaxy collection install community.general --upgrade
ok "Galaxy collections installed"

# ─── 4. Verify Btrfs layout ──────────────────────────────────────
log "Verifying Btrfs subvolume layout..."
SUBVOLS=$(btrfs subvolume list / 2>/dev/null || echo "ERROR")
if echo "$SUBVOLS" | grep -q "path root"; then
  ok "Btrfs subvolume 'root' confirmed"
else
  warn "Unexpected Btrfs layout — review before running snapper role"
  echo "$SUBVOLS"
fi

# ─── 5. Verify NPU ────────────────────────────────────────────────
log "Checking AMD XDNA2 NPU..."
if [ -e /dev/accel/accel0 ]; then
  ok "NPU device /dev/accel/accel0 present"
else
  warn "/dev/accel/accel0 not found — check: dmesg | grep amdxdna"
fi

# ─── 6. Check nouveau status ──────────────────────────────────────
log "Checking nouveau (open NVIDIA driver) status..."
if lsmod | grep -q "^nouveau"; then
  warn "nouveau is loaded — will be blacklisted by hardware role"
  warn "A REBOOT is required after first hardware role run"
else
  ok "nouveau is not loaded"
fi

# ─── 7. Verify dotfiles directory ────────────────────────────────
# dotfiles/ is the source of truth for all UI/UX config.
# If it is empty the aesthetics and DE roles will deploy nothing.
log "Checking dotfiles directory..."
DOTFILES_DIR="$REPO_ROOT/dotfiles"
if [ -d "$DOTFILES_DIR" ] && [ "$(ls -A "$DOTFILES_DIR")" ]; then
  ok "dotfiles/ directory present and populated"
else
  warn "dotfiles/ is empty or missing — aesthetics/DE roles will deploy no configs"
  warn "Populate dotfiles/ before running aesthetics, hyprland, or kde roles"
fi

# ─── 8. Create initial Snapper snapshot (pre-bootstrap) ──────────
log "Attempting pre-bootstrap Snapper snapshot..."
if command -v snapper &>/dev/null && [ -f /etc/snapper/configs/root ]; then
  snapper -c root create --description "pre-bootstrap-$(date +%Y%m%d-%H%M%S)" && \
    ok "Snapper snapshot created" || warn "Snapper snapshot failed (non-fatal)"
else
  warn "Snapper not yet configured — will be set up by ansible snapper role"
fi

# ─── 9. Run Ansible ───────────────────────────────────────────────
echo ""
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo -e "${MAGENTA}  Ready to run Ansible playbook                    ${NC}"
echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
echo ""
echo "Choose what to run:"
echo "  1) Base + Snapper only (safe, no GPU changes)  ← START HERE on fresh install"
echo "  2) Base + Snapper + dev-tools"
echo "  3) Full playbook (all roles)"
echo "  4) Skip Ansible — run manually"
echo ""
read -rp "Choice [1/2/3/4]: " choice

cd "$REPO_ROOT"

case "$choice" in
  1)
    log "Running: base + snapper roles..."
    ansible-playbook ansible/site.yml \
      -i ansible/inventory/localhost.yml \
      --tags "base,snapper" \
      --ask-become-pass
    echo ""
    ok "Base + Snapper complete."
    echo -e "${YELLOW}Next: run hardware role, then REBOOT${NC}"
    echo "  ansible-playbook ansible/site.yml -K --tags hardware"
    ;;
  2)
    log "Running: base + snapper + dev-tools..."
    ansible-playbook ansible/site.yml \
      -i ansible/inventory/localhost.yml \
      --tags "base,snapper,dev-tools" \
      --ask-become-pass
    echo ""
    ok "Base + Snapper + dev-tools complete."
    echo -e "${YELLOW}Next: run hardware role, then REBOOT${NC}"
    echo "  ansible-playbook ansible/site.yml -K --tags hardware"
    ;;
  3)
    warn "Running full playbook — this will blacklist nouveau and install NVIDIA drivers"
    warn "A reboot will be required afterward"
    read -rp "Are you sure? [y/N]: " confirm
    [[ "$confirm" == "y" ]] || { log "Aborted."; exit 0; }
    ansible-playbook ansible/site.yml \
      -i ansible/inventory/localhost.yml \
      --ask-become-pass
    echo ""
    ok "Full playbook complete. REBOOT NOW: sudo reboot"
    ;;
  4)
    log "Skipping Ansible run."
    echo ""
    echo "Run manually from repo root:"
    echo "  ansible-playbook ansible/site.yml -K --tags base,snapper"
    echo "  ansible-playbook ansible/site.yml -K --tags hardware   (then reboot)"
    echo "  ansible-playbook ansible/site.yml -K --tags dev-tools"
    echo "  ansible-playbook ansible/site.yml -K --tags aesthetics"
    ;;
  *)
    fail "Invalid choice"
    ;;
esac

echo ""
echo -e "${MAGENTA}RaBbLE bootstrap complete.${NC}"
echo "Repo:     $REPO_ROOT"
echo "Dotfiles: $REPO_ROOT/dotfiles"
echo "Docs:     $REPO_ROOT/docs/"
