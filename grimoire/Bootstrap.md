# Bootstrap.md — The RaBbLE Bootstrap System

```
spark ~ bootstrap-organ >> initiating first-contact sequence // %ENTITY_DORMANT%
```

---

## Overview

The bootstrap system is an interactive shell-based entry point for deploying and managing RaBbLE-OS. It wraps Ansible playbooks in a navigable menu interface, so you work with layers rather than raw playbook invocations.

**Current scope:** The bootstrap script handles Ansible installation and pre-flight checks. Full menu-driven layer deployment is a work in progress — direct Ansible invocation is the reliable path for now.

```
bootstrap.sh           ← entry point — run this
bootstrap/
  menus/
    main.menu.sh       ← top-level navigation
    boot.menu.sh       ← boot layer options
    hardware.menu.sh   ← hardware target selection
    theme.menu.sh      ← theme deployment
    ui.menu.sh         ← UI/UX layer options
  lib/
    ansible.sh         ← playbook runner helpers
    checks.sh          ← preflight validation
    colors.sh          ← terminal color definitions
    ui.sh              ← menu drawing primitives
```

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Fedora 43 KDE spin installed | KDE used as bootstrap base — purged after Hyprland is stable |
| System fully updated | Run `sudo dnf upgrade --refresh -y` before bootstrapping |
| Internet access | For DNF packages and COPR repos |
| `git` installed | `sudo dnf install git -y` |
| `sudo` access | For Ansible playbook execution |

---

## Ansible Installation

The bootstrap script installs Ansible via pipx. This provides a more current version than the DNF-packaged Ansible and avoids Python environment conflicts.

```bash
# Run the bootstrap and select the Ansible install option
bash bootstrap.sh

# Or install manually:
sudo dnf install pipx -y
pipx install --include-deps ansible
pipx ensurepath
source ~/.bashrc

# Install required collections
ansible-galaxy collection install community.general

# Verify
ansible --version
```

> **`--include-deps` is required.** Without it, Ansible installs without some dependent
> packages and certain modules will fail silently.

---

## Direct Ansible Invocation

The most reliable way to deploy layers. Use these directly rather than the menu for any serious work:

```bash
# Full system deploy
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K

# Individual layers by tag
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags core
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags hardware
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags ui_ux
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags dev-tools
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags purge-kde

# Single role via tag
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags hyprland
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags grub
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags sddm

# Config symlinks only
ansible-playbook -i ansible/inventory/hosts.yml ansible/deploy-config.yml -K

# Dry run (no changes applied)
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --check --diff
```

---

## Playbook Reference

| Playbook | What it does |
|---|---|
| `site.yml` | Full system deploy — runs all roles in order |
| `deploy-boot.yml` | Boot chain only: GRUB2 + Plymouth + SDDM |
| `deploy-hardware.yml` | Hardware layer: GPU drivers, asusctl, NPU, audio |
| `deploy-ui.yml` | UI/UX layer: Hyprland, terminal, shell |
| `deploy-config.yml` | Symlink configs from `config/` into `~/.config/` |
| `pull-config.yml` | Pull config changes back from `~/.config/` into repo |

---

## Menu Structure (Target State)

The bootstrap menu is being rebuilt. This documents the intended structure — not all options are currently functional.

### Main Menu

```
RaBbLE-OS Bootstrap
────────────────────────────────
  1. Install Ansible
  2. Pre-flight checks
  3. Deploy by layer
  4. Deploy full system
  5. Recovery tools
  6. Exit
```

### Deploy by Layer

```
Deploy by Layer
────────────────────────────────
  1. Core (base system, repos, fonts)
  2. Hardware layer → [submenu]
  3. Boot layer    → [submenu]
  4. UI/UX layer   → [submenu]
  5. Dev tools
  6. Purge KDE
  7. ← Back
```

### Boot Layer Submenu

```
Boot Layer
────────────────────────────────
  1. Deploy all boot components
  2. GRUB2 theme only
  3. Plymouth theme only
  4. SDDM session manager only
  5. ← Back
```

### Hardware Layer Submenu

```
Hardware Layer
────────────────────────────────
  1. Auto-detect and deploy
  2. ASUS ProArt P16 (hybrid GFX + NPU + asusctl)
  3. Generic x64
  4. ← Back
```

### UI/UX Layer Submenu

```
UI/UX Layer
────────────────────────────────
  1. Deploy all UI components
  2. Hyprland only
  3. Quickshell only
  4. Shell (zsh)
  5. Terminal (kitty)
  6. Re-link configs
  7. ← Back
```

---

## Verification Checklist

Run these after a fresh deploy to confirm everything is operational:

```bash
# Hyprland
hyprctl version                     # should show v0.54+
hyprctl monitors                    # display config
hyprctl clients                     # running clients

# Boot chain
systemctl status sddm               # SDDM running

# Hardware
asusctl profile -l                  # power profiles listed
supergfxctl --status                # GPU mode (should be Hybrid)
cat /sys/power/mem_sleep            # should show [s2idle]
systemctl status nvidia-suspend     # NVIDIA sleep service enabled

# NPU
ls /dev/accel/                      # accel0
lsmod | grep amdxdna                # amdxdna loaded
```

---

## Recovery Mode

If Hyprland fails to start and KDE has not been purged, select **KDE Plasma** from the SDDM session list to recover. If KDE has been purged, drop to a TTY:

```bash
# TTY access: Ctrl+Alt+F2 (or F3, F4...)

# Re-link configs to fix symlinks
ansible-playbook -i ansible/inventory/hosts.yml ansible/deploy-config.yml -K

# Check Hyprland config for syntax errors
hyprland --config ~/.config/hypr/hyprland.conf

# Force AMD GPU as compositor (if Hyprland starts but screen is wrong)
export AQ_DRM_DEVICES=/dev/dri/by-path/pci-0000:65:00.0-card
hyprland
```

> ⚠️ **GPU management note:** Keep GPU-related env vars in `machine.conf` (Ansible-templated),
> not in the main `hyprland.conf`. A broken GPU config in the main conf can prevent SDDM
> from launching Hyprland at all — and with KDE purged, that means TTY recovery only.

> ⚠️ **Hyprland config syntax:** As of v0.54, `windowrulev2` is removed. If you pull config
> from an older branch, check for this directive before reloading.

---

```
harmonize ~ bootstrap-organ >> substrate initialized, resonance calibrating // %LOW_ENTROPY_LOCKED%
```
