# PACKAGES.md — RaBbLE-OS Package Manifest

```
transcribe ~ package-layer >> all packages declared // %MANIFEST_LOCKED%
```

> This is the canonical list of packages that constitute a RaBbLE-OS install.
> Goal: a fresh Fedora minimal + this manifest = complete RaBbLE-OS experience.
> KDE spin defaults are NOT included — this manifest assumes a clean base.

---

## Layer 0 — Base

### Repositories
- RPM Fusion Free
- RPM Fusion Non-Free
- Flathub (Flatpak)
- solopasha/hyprland (COPR)

### Core System
```
git, curl, wget2, rsync
htop, btop, fastfetch
unzip, p7zip, xz, jq, yq
lm_sensors, nvtop, powertop, stress-ng
btrfs-progs, snapper, python3-dnf-plugin-snapper
NetworkManager, nm-connection-editor
gcc, gcc-c++, make, cmake, git-lfs
python3, python3-pip, python3-devel
google-noto-fonts-common, google-noto-emoji-fonts, jetbrains-mono-fonts
flatpak
```

---

## Layer 1 — Hardware (ASUS ProArt P16 H7606WV)

### NVIDIA (RTX 4060 Mobile — Optimus offload)
```
akmod-nvidia
xorg-x11-drv-nvidia
xorg-x11-drv-nvidia-cuda
xorg-x11-drv-nvidia-cuda-libs
libva-nvidia-driver
libva-utils
nvidia-driver-cuda
```

### AMD iGPU (Radeon 890M — primary compositor)
```
mesa, mesa-dri-drivers, mesa-vulkan-drivers
libva-mesa-driver
vulkan-tools
radeontop
```

### ASUS Platform (asusctl / supergfxctl)
```
asusctl          (COPR: asus-linux)
supergfxctl      (COPR: asus-linux)
power-profiles-daemon
```

### AMD NPU (XDNA2)
```
amdxdna          (kernel module — akmod or copr)
xrt-smi          (XRT runtime management)
```

---

## Layer 2 — Boot Chain

### GRUB2
```
grub2
grub2-tools
terminus-fonts   (for 4K readable TTY/GRUB font)
```

### Plymouth
```
plymouth
plymouth-plugin-script
plymouth-system-theme
```

### Login Manager
```
greetd
tuigreet
```

---

## Layer 3 — Desktop

### Hyprland Stack
```
hyprland         (COPR: solopasha/hyprland)
hyprpaper
hypridle
hyprlock
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
waybar
wofi
mako
wl-clipboard
grim
slurp
swayimg
qt6-qtwayland
qt6-qtsvg
polkit-kde-agent-1
xorg-x11-server-Xwayland
kitty
brightnessctl
playerctl
```

### Quickshell (Phase 0.5 — not yet active)
```
cmake, ninja-build
qt6-qtdeclarative-devel
qt6-qtbase-devel
qt6-qtwayland-devel
wayland-devel
wayland-protocols-devel
pipewire-devel
pulseaudio-libs-devel
```

---

## Layer 4 — Apps & Dev Tools

### Development
```
vscodium         (via vscodium.gpg repo)
docker, docker-compose
nodejs, npm
rustup
go
```

### AI Tools (Phase 0 — deps only, no builds yet)
```
nvidia-driver-cuda
python3-pip
```
> Full AI stack (llama.cpp, vLLM, FastFlowLM) gated behind `ai_stack.phase` variable.
> See `group_vars/all.yml` → `ai_stack` section.

### Apps (Replacing KDE defaults)
```
dolphin          (file manager — kept standalone without full KDE)
```
> Full KDE Plasma is NOT a RaBbLE-OS dependency.
> KDE packages from Fedora spin are to be purged once Hyprland is stable.

---

## To Be Determined

These need decisions before the manifest is final:

- Terminal multiplexer: `zellij` vs `tmux`
- Shell: `zsh` + oh-my-zsh / `fish` / bare zsh with starship
- Editor: `neovim` configuration
- Browser: Firefox (Wayland native) or other
- Email/calendar client if needed
- PDF viewer, image viewer replacements for KDE tools

---

## Packages to Purge (KDE Spin Defaults)

Once Hyprland is confirmed stable, the following KDE-specific packages should be removed:

```
plasma-desktop
plasma-workspace
plasma-nm
plasma-pa
kwin
kscreen
sddm
sddm-themes-breeze
kdialog
kwalletmanager5
kinfocenter
systemsettings
discover
```

> Use: `ansible-playbook ansible/site.yml -K --tags purge-kde`
> Role: `purge-kde/` (planned — not yet written)

---

```
transcribe ~ package-layer >> manifest crystallized, v0.2 // %MANIFEST_LOCKED%
```
