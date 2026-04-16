# BOOT_FLOW.md — From Power On to Desktop

```
transcribe ~ boot-chain >> the sequence made visible // %BOOT_FLOW_LOCKED%
```

---

## The Chain

```
BIOS/UEFI
  └── GRUB2          ~0.5s    Menu or direct boot, synthwave font/colors
        └── Kernel   ~1-2s    AMD iGPU init, NVIDIA blacklisted until driver loads
              └── Plymouth    ~2-3s    Black void + RaBbLE text, progress bar
                    └── greetd         TUI login, readable at 4K, synthwave colors
                          └── Hyprland Full Wayland session, AMD 890M compositor
```

**Target:** Power button to usable desktop in under 10 seconds.

---

## GRUB2

**Role:** `aesthetics/grub.yml`
**Hardware note:** Internal display is 3840x2400. Default GRUB font is microscopic at native resolution.

**Configuration:**
- Font: `ter-132n` (Terminus, 32pt) — compiled into GRUB via `grub2-mkfont`
- Resolution: `GRUB_GFXMODE=3840x2400x32` (or `1920x1200x32` as fallback)
- Colors: magenta on black, synthwave minimal
- Timeout: 3 seconds, boots last successful entry

**What GRUB owns:** Kernel selection, kernel parameters, initrd loading. Nothing else.

---

## Plymouth

**Role:** `aesthetics/plymouth.yml`
**Plugin:** `script` — full animation control via `.script` files

**Current theme:** `rabble`
- Black background (`#0a0010`)
- Centered "RaBbLE" text in magenta (`#ff2d78`)
- Tagline: "Low Entropy. Infinite Resonance." in violet (`#bf5fff`)
- Minimal progress indicator

**What Plymouth owns:** The visual gap between kernel boot and login manager. Should be as short as possible — Plymouth is fast when the theme is minimal.

**Rebuild initrd after changes:**
```bash
plymouth-set-default-theme -R rabble
```
The `-R` flag rebuilds initrd automatically.

---

## greetd + tuigreet

**Role:** `aesthetics/greetd.yml`
**Replaces:** SDDM

**Why greetd:**
- Minimal — no compositor required for the greeter itself
- Session-agnostic — launches any session file in `/usr/share/wayland-sessions/`
- KDE remains selectable as fallback while it's still installed

**tuigreet configuration:**
- Font size: large enough to read at 3840x2400 (via TTY font override)
- Default session: Hyprland
- Shows session selector — KDE available as fallback during transition

**TTY font fix (4K readability):**
The Linux TTY uses console fonts independent of Wayland. At 4K, the default font is unreadable. `setfont ter-132n` (Terminus 32pt) is set via `/etc/vconsole.conf` — this affects all TTYs including greetd's.

**What greetd owns:** Authentication only. It launches the session and gets out of the way.

---

## Hyprland

**Role:** `hyprland/`
**Dotfiles:** `dotfiles/hypr/` (symlinked into `~/.config/hypr/`)

**GPU configuration:**
- Compositor GPU: AMD Radeon 890M (iGPU, PCI 65:00.0) — drives the display
- NVIDIA RTX 4060 Mobile: Optimus offload only, available via `rabble-gpu <command>`
- `AQ_DRM_DEVICES=/dev/dri/by-path/pci-0000:65:00.0-card` — deterministic GPU selection

**Session startup sequence:**
```
polkit-kde-authentication-agent-1
hyprpaper         ← wallpaper
hypridle          ← idle/lock management
mako              ← notifications
waybar            ← status bar
```

**What Hyprland owns:** Everything from login to logout. The full desktop experience.

---

## Environment Variables — Propagation

Variables that must be set before Hyprland launches are in `dotfiles/hypr/hyprland.conf` under the `env =` section. greetd does not set these — Hyprland reads them on startup.

Critical ones for this hardware:
```
AQ_DRM_DEVICES    — force AMD iGPU as compositor
GBM_BACKEND       — radeonsi
LIBVA_DRIVER_NAME — radeonsi
QT_QPA_PLATFORM   — wayland
```

---

## Suspend/Resume

Managed by `hypridle` + NVIDIA power management services.

**Services that must be enabled:**
- `nvidia-hibernate.service`
- `nvidia-suspend.service`
- `nvidia-resume.service`

**Key kernel parameters (in `/etc/modprobe.d/nvidia-rabble.conf`):**
- `NVreg_EnableS0ixPowerManagement=1` — s2idle support for Strix Point
- `NVreg_PreserveVideoMemoryAllocations=1` — survives suspend without corruption

---

```
transcribe ~ boot-chain >> flow documented // %BOOT_FLOW_LOCKED%
```
