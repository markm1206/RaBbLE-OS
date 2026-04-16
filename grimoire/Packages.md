# Packages.md — RaBbLE-OS Package Manifest

```
transcribe ~ package-layer >> all packages declared // %MANIFEST_LOCKED%
```

> This is the canonical list of packages that constitute a RaBbLE-OS install.
> Goal: a fresh Fedora minimal + this manifest = complete RaBbLE-OS experience.
> The KDE spin is used as the bootstrap base and purged after Hyprland is stable —
> KDE packages are not part of the RaBbLE-OS manifest.

---

## Layer 0 — Base

### Repositories
- RPM Fusion Free
- RPM Fusion Non-Free
- Flathub (Flatpak)

### Core System
```
# Shell and file operations
bash, git, git-lfs, curl, wget, rsync
unzip, p7zip, xz, tar

# Build primitives (required by roles that compile from source)
gcc, gcc-c++, make, cmake, pkg-config

# Network
NetworkManager, nm-connection-editor

# Filesystem
btrfs-progs             # Btrfs userspace tools — subvolume management, scrub
                        # snapper deferred — grub-btrfs not available on Fedora 43

# Python base
python3, python3-pip, python3-devel, pipx

# System fonts (not aesthetic — required by boot chain and TTY)
terminus-fonts, terminus-fonts-console
google-noto-fonts-common, google-noto-emoji-fonts

# Misc
flatpak
os-prober               # GRUB removable media detection
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
> NVIDIA kernel modules are deferred from initramfs — loaded at `graphical.target` after SDDM.
> Prevents Plymouth black flash caused by mid-boot DRM reset.
> See `hardware/x64/asus_proart_p16/tasks/nvidia_defer.yml` and `KnownIssues.md`.

### AMD iGPU (Radeon 890M — primary compositor)
```
mesa, mesa-dri-drivers, mesa-vulkan-drivers
libva-mesa-driver
vulkan-tools
radeontop
```

### ASUS Platform
```
asusctl          (COPR: asus-linux)
supergfxctl      (COPR: asus-linux)
power-profiles-daemon
```

### AMD NPU (XDNA2)
```
amdxdna          (kernel module — akmod or COPR)
xrt-smi          (XRT runtime — verify availability on Fedora 43)
```

---

## Layer 2 — Boot Chain

### GRUB2
```
grub2
grub2-tools
terminus-fonts          (ter-v32b — 4K readable GRUB and TTY font)
```

### Plymouth
```
plymouth
plymouth-plugin-script
plymouth-system-theme
```

### Session Manager
```
sddm
qt6-qtdeclarative       (QML rendering for SDDM theme)
qt6-qtwayland           (Wayland backend for Qt6)
```

---

## Layer 3 — Desktop

### Hyprland Stack
```
# COPR: lionheartp/Hyprland (v0.54+, March 2026)
# Replaces: solopasha/hyprland (last used v0.51)
hyprland
hyprland-devel          # hyprpm plugin support
xdg-desktop-portal-hyprland
hyprpaper               # wallpaper daemon
hypridle                # idle daemon
hyprlock                # screen locker
hyprcursor              # cursor management
hyprpicker              # colour picker
polkit                  # privilege escalation framework
hyprpolkitagent         # Polkit auth agent for Hyprland
```

> **v0.54 breaking change:** `windowrulev2` removed — unified into `windowrule`.
> Matcher syntax is identical; only the directive name changed.

### Wayland Utilities
```
waybar                  # status bar (active — Quickshell pending Phase 1.2)
mako                    # notification daemon
fuzzel                  # app launcher (replaces wofi)
grim                    # screenshot capture
slurp                   # screen region selector
wl-clipboard            # clipboard read/write primitives
cliphist                # clipboard history manager
xdg-desktop-portal-gtk  # GTK portal backend — file pickers
network-manager-applet  # NetworkManager systray applet
kanshi                  # display profile manager
wlr-randr               # monitor configuration utility
qt6-qtwayland           # Wayland backend for Qt6 apps
qt5-qtwayland           # Wayland backend for Qt5 apps
xorg-x11-server-Xwayland
brightnessctl
playerctl
```

### Terminal
```
kitty                   # GPU-accelerated terminal (also provided by lionheartp COPR)
```
> foot removed — kitty is the single terminal target.

### Quickshell (Phase 1.2 — build from source)
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

### Shell
```
zsh
zinit              (zsh plugin manager)
starship           (cross-shell prompt — single winner over p10k)
```

### Aesthetic Fonts (desktop/terminal — not system fonts)
```
fontawesome-fonts
jetbrains-mono-fonts
```

---

## Layer 4 — Apps & Dev Tools

### CLI Tools
```
ripgrep         # fast recursive grep replacement
fd-find         # fast find replacement
fzf             # fuzzy finder
zoxide          # smart cd
jq              # JSON processor
yq              # YAML/JSON processor
bat             # cat with syntax highlighting
eza             # modern ls replacement
fastfetch       # system info display
```

### Monitoring
```
htop            # interactive process viewer
btop            # resource monitor
lm_sensors      # hardware sensor readings
nvtop           # GPU process monitor
powertop        # power usage analyser
```

### Editors & Multiplexer
```
neovim          # terminal editor (LSP config pending Phase 1.3)
tmux            # terminal multiplexer
```

### Python Tooling
```
python3-uv      # fast Python package manager
```

### Development
```
vscodium        (via vscodium.gpg repo)
docker, docker-compose
nodejs, npm
rustup
go
```

### AI Tools (Phase 2 — deps only until ai_stack.phase advances)
```
nvidia-driver-cuda
python3-pip
```
> Full AI stack gated behind `ai_stack.phase` variable in `group_vars/all.yml`.

### Apps
> File manager and archive tool (dolphin, ark) removed from system.
> No replacement selected yet — decision pending before adding to manifest.
> Candidates: Nautilus, Thunar, nnn/yazi.

---

## To Be Determined

- File manager: replacement for dolphin/ark
- Qt theme: `kvantum` (full synthwave control) vs `adwaita-dark` (interim, zero-config)
- Browser: Firefox (Wayland native) or other
- PDF viewer, image viewer
- OSD overlay: `swayosd` vs `wob` (for volume/brightness key feedback)

---

## Packages to Purge (KDE Spin Defaults)

KDE has been manually removed. The `purge-kde/` role codifies this for clean installs.

**Managed by `ansible/roles/purge-kde/tasks/main.yml`:**
```
plasma-desktop, plasma-workspace, plasma-nm, plasma-pa
kwin, kscreen, kdialog, kwalletmanager5
kinfocenter, systemsettings, discover
plasma-systemmonitor, plasma-vault
kdeconnectd, bluedevil, powerdevil, kactivitymanagerd
```

> Use: `ansible-playbook ansible/site.yml -K --tags purge-kde`
> Role uses `autoremove: true` to pull orphaned KDE dependencies.

**Do NOT purge:**
- `polkit-kde-agent-1` — if present, still useful; `hyprpolkitagent` is the Hyprland-native replacement
- `qt6-*` packages — needed for SDDM QML theming

---

```
transcribe ~ package-layer >> manifest crystallized, v0.5 // %MANIFEST_LOCKED%
```
