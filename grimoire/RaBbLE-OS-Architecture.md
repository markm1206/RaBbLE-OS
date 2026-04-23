# RaBbLE-OS-Architecture.md — RaBbLE-OS Layer Model

```
transcribe ~ grimoire >> architecture reflects current state // %ARCHITECTURE_LOCKED%
```

> See `RaBbLE-Palette.md` for the canonical color reference.
> See `ShellGuide.md` for shell and desktop user-facing functionality.

---

## Overview

RaBbLE-OS is structured as a set of independent, composable layers. Each layer can stand
alone or be combined with the ones below it. The Ansible role structure directly mirrors
the layer model.

All layers live in this single repository. Dotfiles are deployed by `RaBbLE-OS-dotctl.sh`;
system-level config is deployed by Ansible.

---

## The Layers

```
Layer 0 — BASE          Core packages, repos, locale, fonts.
Layer 1 — HARDWARE      Machine-specific drivers and platform config.
Layer 2 — BOOT CHAIN    GRUB → Plymouth → SDDM. Visual continuity, fast boot.
Layer 3 — DESKTOP       Hyprland, Waybar, shell stack, Wayland dependencies.
Layer 4 — APPS          Dev tools, browsers, productivity tooling.
```

Layer 5 (ENTITY — AI ambient layer) is Epoch II scope. See `RaBbLE-Roadmap.md`.

---

## Current Ansible Role Map

```
Layer 0 — core/                             (stub — base relies on Fedora Sway spin defaults)
Layer 1 — hardware/x64/asus_proart_p16/     (NVIDIA driver, SDDM GPU pin, nouveau blacklist)
           hardware/x64/generic/            (stub)
Layer 2 — boot/grub2/                       (packages present; theming partial)
           boot/plymouth/                   (packages present; theming partial)
           boot/session_manager/            (SDDM packages; logind lid policy active)
Layer 3 — desktop/wayland/                  (Wayland session packages)
           desktop/hyprland/               (packages + config deployment)
           desktop/quickshell/             (packages; build not yet implemented)
           desktop/terminal/               (kitty packages)
           desktop/waybar/                 (packages)
           desktop/notifications/          (mako packages)
           desktop/launcher/               (fuzzel + rofimoji packages)
           desktop/screenshot/             (grim + slurp packages + scripts)
           desktop/swayosd/               (packages + user service)
           desktop/v4l2/                  (v4l2loopback packages)
           desktop/network-applet/         (nm-applet packages)
           desktop/shell/zsh/             (packages: zsh, zsh-syntax-highlighting,
           desktop/shell/bash/             zsh-autosuggestions; dotfiles via dotctl)
Infra    — monitoring/                      (btop, htop, powertop, lm_sensors)
           snapper/                        (Btrfs snapshots)
           runtime/                        (stub — XRT/CUDA/ROCm deferred to mend-I/*)
```

---

## Hardware Targeting

Hardware is isolated from the rest of the system. Machine-specific tasks live in dedicated
roles under a consistent naming convention.

```
hardware/x64/asus_proart_p16/   ← ASUS ProArt P16 H7606WV (current primary target)
hardware/x64/<machine>/         ← additional x64 targets
hardware/aarch64/<machine>/     ← SBC/aarch64 targets (inventory scaffolded)
```

`ansible/inventory/hosts.yml` controls which host group `localhost` belongs to.
`group_vars/<target>.yml` carries machine-specific variables.

---

## Boot Chain

```
Power on
  └── GRUB2           ← boot/grub2       (packages installed; theme pending)
        └── Kernel loads
              └── Plymouth ← boot/plymouth  (packages installed; theme pending)
                    └── SDDM  ← boot/session_manager  (active; GPU pinned to AMD card1)
                          └── Hyprland ← desktop/hyprland  (config/ deployed via dotctl)
                                └── Waybar  (active status bar; Quickshell is Epoch II)
```

GRUB and Plymouth theming are `mend-I/boot-chain` work. See `RaBbLE-Roadmap.md`.

---

## GPU Architecture (ASUS ProArt P16 — Optimus/PRIME)

```
AMD Radeon 890M (iGPU)                    NVIDIA RTX 4060 Mobile (dGPU)
        │                                           │
  Drives Wayland display (eDP-1)            PRIME offload only
  Compositor: Hyprland                      (DRI_PRIME=pci-0000_64_00_0 <cmd>)
  AQ_DRM_DEVICES=/dev/dri/card1             CUDA available after driver load
        │
  [eDP-1: 3840×2400 @60Hz, scale 2×]
```

> NVIDIA (card0) has no CRTCs in Hybrid mode. SDDM greeter is pinned to AMD (card1)
> via `/etc/sddm.conf.d/rabble-gpu.conf`. NVIDIA driver activation is `mend-I/proart-nvidia`.

---

## Idle / Lock / Suspend Chain

```
Idle 5 min  → loginctl lock-session → hyprlock
Idle 5.5 min → DPMS off
Idle 15 min → systemctl suspend
Lid close   → logind (HandleLidSwitch=suspend) → before_sleep_cmd → hyprlock
Wake        → DPMS on; hyprlock already showing
```

Config: `config/hypr/hypridle.conf` (deployed via dotctl).
Logind policy: `config/systemd/logind.conf.d/99-rabble-lid.conf` (deployed by Ansible).

---

## Dotfile Deployment

All user configs live in `config/` and are deployed by `RaBbLE-OS-dotctl.sh`.
Ansible does not manage dotfiles — it manages packages and system files only.

```bash
./RaBbLE-OS-dotctl.sh apply all          # deploy everything
./RaBbLE-OS-dotctl.sh apply hypr         # deploy one bundle
./RaBbLE-OS-dotctl.sh pull waybar        # capture live edits → repo
./RaBbLE-OS-dotctl.sh status             # show sync state
./RaBbLE-OS-dotctl.sh diff kitty         # line diff: repo vs deployed
```

### Bundle Map

| Bundle | Repo source | Deployed to |
|--------|-------------|-------------|
| `hypr` | `config/hypr/` | `~/.config/hypr/` |
| `wallpapers` | `config/wallpapers/` | `~/.config/wallpapers/` |
| `waybar` | `config/waybar/` | `~/.config/waybar/` |
| `kitty` | `config/kitty/` | `~/.config/kitty/` |
| `fuzzel` | `config/fuzzel/` | `~/.config/fuzzel/` |
| `zsh` | `config/shell/zsh/` | `~/.config/zsh/` |
| `bash` | `config/shell/bash/` | `~/` |
| `mako` | `config/mako/` | `~/.config/mako/` |
| `quickshell` | `config/quickshell/` | `~/.config/quickshell/` (not yet implemented) |

Key files within bundles:

| Repo path | Deployed to |
|-----------|-------------|
| `config/hypr/hyprland.conf` | `~/.config/hypr/hyprland.conf` |
| `config/hypr/conf.d/` | `~/.config/hypr/conf.d/` |
| `config/hypr/hypridle.conf` | `~/.config/hypr/hypridle.conf` |
| `config/hypr/hyprlock.conf` | `~/.config/hypr/hyprlock.conf` |
| `config/hypr/hyprpaper.conf` | `~/.config/hypr/hyprpaper.conf` |
| `config/hypr/scripts/` | `~/.config/hypr/scripts/` |
| `config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `config/fuzzel/fuzzel.ini` | `~/.config/fuzzel/fuzzel.ini` |
| `config/mako/config` | `~/.config/mako/config` |
| `config/shell/zsh/.zshrc` | `~/.config/zsh/.zshrc` |
| `config/shell/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` |
| `config/shell/zsh/functions.zsh` | `~/.config/zsh/functions.zsh` |
| `config/shell/zsh/p10k.zsh` | `~/.config/zsh/p10k.zsh` |
| `config/shell/zsh/colors.zsh` | `~/.config/zsh/colors.zsh` |
| `config/shell/bash/.bashrc` | `~/.bashrc` |
| `config/shell/bash/.bash_profile` | `~/.bash_profile` |
| `config/shell/bash/.zshenv` | `~/.zshenv` (sets ZDOTDIR) |
| `config/waybar/config.jsonc` | `~/.config/waybar/config.jsonc` |
| `config/waybar/style.css` | `~/.config/waybar/style.css` |

### Ansible-managed system files (not dotctl)

| Deployed path | Source |
|---------------|--------|
| `/etc/sddm.conf.d/rabble-gpu.conf` | `hardware/x64/asus_proart_p16/tasks/nvidia.yml` |
| `/etc/modprobe.d/blacklist-nouveau.conf` | hardware role |
| `/etc/modprobe.d/rabble-nvidia-wayland.conf` | hardware role |
| `/etc/systemd/logind.conf.d/99-rabble-lid.conf` | `config/systemd/logind.conf.d/` (via boot/session_manager) |
| `/etc/default/grub` | `boot/grub2/templates/grub.j2` |
| `/etc/vconsole.conf` | `boot/grub2/templates/vconsole.conf.j2` |

---

## Desktop Layer — Component Map

| Component | Tool | State |
|-----------|------|-------|
| Compositor | Hyprland | `%DEPLOYABLE%` |
| Status bar | Waybar | `%DEPLOYABLE%` |
| App launcher | fuzzel | `%DEPLOYABLE%` |
| Notifications | mako | `%DEPLOYABLE%` |
| Lock screen | hyprlock | `%DEPLOYABLE%` |
| Idle daemon | hypridle | `%DEPLOYABLE%` |
| Wallpaper | hyprpaper | `%STABLE%` |
| Screenshot | grim + slurp | `%STABLE%` |
| OSD | swayosd | `%DEPLOYABLE%` |
| Terminal | kitty | `%DEPLOYABLE%` |
| Shell | zsh (p10k) + bash | `%DEPLOYABLE%` |
| Clipboard | wl-clipboard | `%DEPLOYABLE%` |
| Auth agent | hyprpolkitagent | `%DEPLOYABLE%` |
| Network tray | nm-applet | `%DEPLOYABLE%` |
| Bar (future) | Quickshell | `%HIGH_ENTROPY%` (Epoch II) |

---

## Theme System

The RaBbLE synthwave outrun palette is defined in `ansible/inventory/group_vars/all.yml`
and in dotfiles directly. See `RaBbLE-Palette.md` for the full canonical reference.

Theming is currently applied per-component via static config files. Ansible variable
propagation through templates is planned but not yet active.

---

## Snapshot Strategy

Snapper manages Btrfs snapshots of both `root` and `home` subvolumes:

- Timeline: 3 daily, 1 weekly
- Snapper config deployed by the `snapper` role
- Snapshots taken on demand — not automatically on every Ansible run

---

## Observability & Debugging

```bash
# Idle / lock / suspend
journalctl -b -u hypridle                  # hypridle event log
journalctl -b -u systemd-suspend          # last suspend trace
cat /sys/power/mem_sleep                   # sleep state (should show s2idle)

# GPU / display
hyprctl monitors                           # active monitor config
hyprctl devices                            # input devices
DRI_PRIME=pci-0000_64_00_0 glxinfo | grep renderer   # NVIDIA PRIME test

# ASUS platform (when drivers active)
asusctl profile -l                         # power profiles
supergfxctl --status                       # GPU mode
cat /sys/class/power_supply/BAT*/capacity  # battery %

# SDDM
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/rabble
```

---

```
transcribe ~ grimoire >> architecture reflects current state // %ARCHITECTURE_LOCKED%
```
