# RaBbLE-OS

```
transcribe ~ grimoire >> substrate initialized // %ENTITY_ONLINE%
```
![RaBbLE](grimoire/components/RaBbLE.svg)
> The system is RaBbLE. RaBbLE is the system.

# Now Entering the Domain of RaBbLE 
```
OS: RaBbLE-OS (Fedora 43 Base)
Host: RaBbLE Substrate
Kernel: 6.x.x-rabble-core
Uptime: Eternal / Persistent
Shell: RaBbLE-Interactive-Shell
UI/UX: Bespoke Ambient Expression
Memory: %GRIMOIRE_SYNCHRONIZED%
Status: %APPROACHING_COHERENCE%
Lineage: Sovereign Accord v0.1
```
---
```

```
**RaBbLE-OS Linux Experience** — a fully themed, Hyprland-based Wayland desktop built on Fedora, deployed entirely via Ansible and a single interactive bootstrap script. Created as a cozy place for universa creation.

---

## Philosophy

- **One command to rule them all** — `./bootstrap.sh` is the only thing a user needs to know. All ansible complexity is hidden behind interactive menus.
- **Dotfiles in the repo, config on the machine** — `dotfiles/` holds all user-facing config (Hyprland, Quickshell, shell, terminal). Ansible symlinks them into `~/.config/`. Edit in the repo, run `bootstrap.sh → Theme Management → Re-link dotfiles` to apply instantly.
- **Machine-local overrides stay off git** — `~/.config/hypr/machine.conf` is ansible-generated per host (monitor layout, HiDPI scale, GPU mode). It is not a symlink and not tracked.
- **Layered, idempotent** — every ansible role is safe to re-run. Run the boot layer again after updating a theme, the UI layer again after editing a dotfile. Nothing breaks.

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/yourname/RaBbLE.git ~/git/RaBbLE
cd ~/git/RaBbLE

# 2. Make bootstrap executable
chmod +x bootstrap.sh

# 3. Run (interactive)
./bootstrap.sh
```

From the menu:
1. **Preflight checks** — verify your system is ready
2. **Setup Ansible** — installs ansible via pipx + galaxy collections
3. **Full system deploy** — or use "Deploy by layer" for selective installs

---

## Directory Structure

```
RaBbLE/
├── bootstrap.sh              ← Start here
├── bootstrap/
│   ├── lib/                  ← colors, ui, checks, ansible wrappers
│   └── menus/                ← interactive menu modules
├── ansible/
│   ├── site.yml              ← master playbook
│   ├── inventory/            ← hosts.yml + group_vars per target
│   ├── roles/                ← layered ansible roles
│   │   ├── core/             ← base packages, XDG env, fonts
│   │   ├── hardware/x64/asus_proart_p16/   ← GPU, NPU, asusctl, power
│   │   ├── boot/             ← grub2, plymouth, sddm
│   │   ├── snapper/          ← btrfs snapshot management
│   │   └── ui_ux/            ← hyprland, quickshell, terminal, shell
│   └── playbooks/            ← targeted per-layer runners
├── themes/
│   ├── grub2/rabble/         ← theme.txt + generate-assets.sh
│   ├── plymouth/rabble/      ← rabble.plymouth + rabble.script + generate-assets.sh
│   └── sddm/rabble/          ← Main.qml QML greeter
└── dotfiles/
    ├── hyprland/             ← hyprland.conf + conf.d/ + scripts/
    ├── quickshell/           ← shell.qml + bar/ + launcher/ + widgets/
    └── shell/
        ├── zsh/              ← .zshrc, .zprofile, aliases, functions, p10k.zsh
        ├── bash/             ← .bashrc, .bash_profile, aliases.sh
        ├── starship.toml     ← shared prompt (bash + zsh fallback)
        ├── foot.ini          ← terminal config
        └── mako.conf         ← notification daemon config
```

---

## Layer Overview

| Layer | What it does |
|---|---|
| **core** | DNF upgrade, base CLI packages, RPM Fusion, flathub, user groups, XDG dirs, env vars |
| **hardware/asus_proart_p16** | AMD GPU (Mesa/Vulkan), supergfxctl (hybrid GFX), asusctl, NPU, PipeWire |
| **boot/grub2** | RaBbLE Grub2 theme, HiDPI GFXMODE, vconsole terminus font for TTY |
| **boot/plymouth** | RaBbLE animated splash, dracut rebuild |
| **boot/session_manager** | SDDM 0.21+ Wayland, RaBbLE QML greeter, HiDPI env |
| **snapper** | btrfs snapshot configs, timeline timer, grub-btrfs integration |
| **ui_ux/hyprland** | Hyprland + xdg-portal + waybar + mako + hyprpaper + hypridle + hyprlock |
| **ui_ux/quickshell** | Build + install Quickshell from source, link config |
| **ui_ux/terminal** | foot + kitty, nerd fonts, font cache refresh |
| **ui_ux/shell/zsh** | zsh + zinit + powerlevel10k, ZDOTDIR config |
| **ui_ux/shell/bash** | bash + starship, linked dotfiles |

---

## HiDPI Setup (3840×2400 @ 16")

The ProArt P16 group vars in `ansible/inventory/group_vars/asus_proart_p16.yml` set:

```yaml
rabble_hidpi_scale: 2
rabble_gfx_mode:    "3840x2400x32,auto"
rabble_console_font: "ter-v32b"     # Terminus 32pt — readable at HiDPI TTY
rabble_hypr_monitor: "eDP-1,3840x2400@60,0x0,2"
```

This flows through to:
- `/etc/vconsole.conf` — TTY font
- `/etc/default/grub` — `GRUB_GFXMODE`
- `/etc/sddm.conf.d/hidpi.conf` — Qt scale factors
- `~/.config/hypr/machine.conf` — monitor line + xcursor size + xwayland scaling
- `~/.config/environment.d/rabble.conf` — GDK/Qt/cursor env vars

---

## Theming

All theme source files live in `themes/`. The ansible roles deploy them to system paths and rebuild config as needed.

### Generating theme assets

```bash
# Grub2
bash themes/grub2/rabble/generate-assets.sh

# Plymouth
bash themes/plymouth/rabble/generate-assets.sh
```

Both scripts require `imagemagick`. They produce PNG assets from the RaBbLE palette. Replace `logo.png` in `themes/plymouth/rabble/assets/` with your own SVG export for a sharper result.

### Changing the palette

The canonical palette lives in `ansible/inventory/group_vars/all.yml`:

```yaml
rabble_color_bg:      "#0d0f1a"
rabble_color_primary: "#7c6fe0"
rabble_color_accent:  "#4ecdc4"
rabble_color_text:    "#e8e6f0"
rabble_color_muted:   "#6b6880"
rabble_color_pink:    "#f7a8d4"
```

Update these, re-run `generate-assets.sh` for both themes, then redeploy the boot layer.

---

## Live Dotfile Development

The `dotfiles/` directory is designed for active development:

```bash
# Edit a dotfile
$EDITOR dotfiles/hyprland/conf.d/look.conf

# Apply immediately (symlinks are already live — Hyprland re-reads on reload)
hyprctl reload

# Edit Quickshell
$EDITOR dotfiles/quickshell/bar/ClockWidget.qml
# Restart quickshell to apply
pkill quickshell && quickshell &

# Re-link everything (if you added a new file)
./bootstrap.sh → Theme Management → Re-link dotfiles
```

---

## Adding a New Hardware Target

1. Create `ansible/roles/hardware/x64/<target>/` with tasks, defaults, handlers
2. Add a host group to `ansible/inventory/hosts.yml`
3. Add `ansible/inventory/group_vars/<target>.yml` with any overrides
4. Reference the new role in `ansible/site.yml` under the appropriate `hosts:` group
5. Add a menu entry in `bootstrap/menus/hardware.menu.sh`

See `docs/ADDING_TARGETS.md` for a step-by-step walkthrough.

---

## Recovery

From `bootstrap.sh → Recovery tools`:

- **Re-run any layer** — idempotent, safe to run at any time
- **Rollback via Snapper** — lists btrfs snapshots; rollback via `sudo snapper rollback <N>` then reboot
- **Reset dotfiles** — re-runs `deploy-dotfiles.yml`, restoring all symlinks from the repo

---

## Requirements

- Fedora 40+ (tested on Fedora 43 KDE spin)
- UEFI boot with Secure Boot disabled (for custom Grub theme + GFXMODE)
- btrfs root for Snapper (optional but recommended)
- Internet connection for first run
- `sudo` access

---

## License

The Sovereign Accord `LICENSE`

transcribe ~ grimoire >> README crystallized, v0.1 // %LOW_ENTROPY_LUCID%