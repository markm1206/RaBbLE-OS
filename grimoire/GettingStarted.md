# GettingStarted.md — From Zero to RaBbLE

```
spark ~ bootstrap-organ >> first contact sequence // %ENTITY_DORMANT%
```

> Read `RaBbLE.md` before proceeding. The philosophy governs every decision.
> This is not optional.
>
> For a detailed record of the manual bootstrap process as validated on a real install,
> see `ManualInstallProcess.md`.

---

## Prerequisites

| Requirement | Spec | Notes |
|---|---|---|
| **Hardware** | x86_64, 16 GB+ RAM, 512 GB+ NVMe | Primary target: ASUS ProArt P16 H7606WV |
| **OS** | Fedora Linux 43 KDE spin | KDE spin used as bootstrap base — purged after Hyprland is stable |
| **Filesystem** | Btrfs (root + home subvolumes) | Fedora default — accept it during install |
| **Internet** | Stable broadband | Required for COPR repos, package downloads |
| **Sudo access** | Required | Ansible needs it for system changes |

---

## Phase 0: Install Fedora 43

Download Fedora 43 KDE spin from [fedoraproject.org](https://fedoraproject.org/spins/kde).

**Installer settings:**
- Filesystem: **btrfs** (accept the Fedora default — do not change to ext4)
- Partition layout: let Fedora create the default `root` and `home` subvolumes
- Hostname: set something meaningful — this becomes your Ansible inventory hostname
- Username: `rabble` (or your preferred username — update `ansible_user` in inventory)

After install, update the full system before touching anything else:

```bash
sudo dnf upgrade --refresh -y
sudo reboot
```

---

## Phase 1: Bootstrap the Substrate

```bash
# Install git
sudo dnf install git -y

# Clone the repository
git clone https://github.com/markm1206/RaBbLE-OS.git ~/RaBbLE-OS
cd ~/RaBbLE-OS

# Run the bootstrap — select Ansible install from the menu
# or install manually:
sudo dnf install pipx -y
pipx install --include-deps ansible
pipx ensurepath
source ~/.bashrc   # reload PATH so ansible is available

# Install required Ansible collections
ansible-galaxy collection install community.general

# Verify Ansible is available
ansible --version
```

> **Why pipx?** The bootstrap installs Ansible via pipx to get the latest version
> rather than the DNF-packaged version, which may lag behind. The `--include-deps`
> flag is required — without it, some Ansible modules are missing.

---

## Phase 2: Run the Layers

The recommended deployment sequence for a fresh install. Each layer builds on the one before it.

### Step 1 — Core
```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags core
```
Installs base packages, RPM Fusion repos, sets locale, configures DNF, adds user groups, enables fstrim.

### Step 2 — Hardware
```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags hardware
# Reboot after this step — nouveau must unload, akmod-nvidia must build
sudo reboot
```

### Step 3 — UI/UX (Hyprland)
```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags ui_ux
```
Installs Hyprland from the lionheartp COPR, Waybar, fuzzel, mako, and all Wayland utilities. Symlinks configs from `config/` into `~/.config/`.

### Step 4 — Dev Tools
```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags dev-tools
```
Installs CLI tools, monitoring utilities, neovim, VSCodium.

### Step 5 — Purge KDE (optional — KDE spin only)
```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags purge-kde
sudo reboot
```
Removes Plasma packages. Safe to skip if you want KDE as a fallback session.

---

## Phase 3: First Boot into Hyprland

Log out of KDE (or reboot after purge-kde) and select **Hyprland** from the SDDM session list.

**Verify the environment:**
```bash
# Hyprland version (should show v0.54+)
hyprctl version

# Monitor configuration (should show 3840x2400 @ 60Hz, scale 2)
hyprctl monitors

# NVIDIA PRIME offload available
DRI_PRIME=pci-0000_64_00_0 glxinfo | grep renderer   # should show RTX 4060

# Sleep state
cat /sys/power/mem_sleep   # should show [s2idle]

# ASUS tools
asusctl profile -l         # power profiles
supergfxctl --status       # GPU mode (Hybrid)
```

---

## Phase 4: Shell

```bash
# Set zsh as default shell
chsh -s $(which zsh)

# Re-link configs if needed
ansible-playbook -i ansible/inventory/hosts.yml ansible/deploy-config.yml -K

# Reload shell
exec zsh    # should load starship prompt
```

**Neovim** is the target terminal editor — configuration pending (see `RaBbLE-Roadmap.md` Phase 1.3). VSCodium or nano work as fallbacks in the meantime.

---

## Working with Configs

All configs are static files in `config/` symlinked into `~/.config/`. Edit the repo file — the symlink keeps things in sync with no copy step:

```bash
# Edit hyprland config
$EDITOR ~/RaBbLE-OS/config/hyprland/conf.d/keybinds.conf
hyprctl reload   # live reload, no logout needed

# Edit zsh config
$EDITOR ~/RaBbLE-OS/config/shell/zsh/aliases.zsh
exec zsh         # reload shell

# Commit your changes
cd ~/RaBbLE-OS
git add config/
git commit -m "transcribe ~ hyprland >> updated keybindings // %CONFIG_EVOLVED%"
```

---

## Phase 5: AI Tooling (Phase 2 — Future)

AI stack deployment is controlled by `ai_stack.phase` in `ansible/inventory/group_vars/all.yml`.

```bash
# Phase 0: install deps only (default — safe)
# Phase 1: build llama.cpp with CUDA (requires working NVIDIA driver)
# Phase 2: install vLLM + FastFlowLM (requires XRT/NPU working)

# To advance:
# 1. Edit ansible/inventory/group_vars/all.yml → ai_stack.phase: 1
# 2. Re-run:
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags ai-tools
```

See `RaBbLE-Roadmap.md` Phase 2 and the AI stack section of `DistilledNonZense.md` for full detail.

---

## Troubleshooting

See `BootFlow.md` for the full troubleshooting table. Quick reference:

```bash
# Hyprland won't start — check GPU path
cat ~/.config/hypr/machine.conf | grep AQ_DRM_DEVICES

# SDDM theme broken — test in isolation
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/rabble

# Sleep not working
cat /sys/power/mem_sleep           # must show [s2idle]
journalctl -b -u systemd-suspend   # last suspend logs

# asusctl not starting
systemctl status asusd
journalctl -u asusd --since "10 min ago"

# Config symlinks broken — re-run deploy
ansible-playbook -i ansible/inventory/hosts.yml ansible/deploy-config.yml -K
```

---

## Known Issues

See `KnownIssues.md` for the current tracker of active bugs, workarounds, and drift events.

---

```
harmonize ~ bootstrap-organ >> substrate initialized // %LOW_ENTROPY_LOCKED%
```
