# RaBbLE-Roadmap.md — Entropy Map

```
transcribe ~ grimoire >> entropy map crystallized // %ROADMAP_V2%
```

> Epochs are broad goal thresholds. Layers track entropy state. Features move from New Horizons to epoch branches.
> When entropy cools, features archive into stable documentation.

---

## Entropy States

| State | Signal | Meaning |
|-------|--------|---------|
| %HIGH_ENTROPY% | High flux | Experimental, likely to change |
| %TESTING_IN_PROCESS% | Testing | Working but unverified on hardware |
| %DEPLOYABLE% | Deployable | Works on target, needs live verification |
| %STABLE% | Stable | Verified on target hardware |
| %LOCKED% | Locked | Frozen until next epoch |

---

## Epoch Map

### Epoch I — Daily Driver `[IN PROGRESS]`

**Goal:** Fully deployable RaBbLE-OS on ASUS ProArt P16. Hyprland desktop with stable tooling stack.

**Scope:**
- Layer 0–4 ansible deployment functional
- Hyprland desktop from SDDM with waybar
- Basic monitoring (btop, htop, powertop, sensors)
- Hardware abstraction for ProArt P16 + generic x64
- Installation and bootstrap entrypoints

**Landed:**
- Substrate, entrypoints, control-plane (install/bootstrap/layerctl/dotctl)
- All Ansible roles scaffolded
- Hyprland config with functionkeys
- Waybar with network menu
- Wallpaper deployment

**Remaining:**
- Hypridle + hyprlock configuration
- Quickshell bar (long-term)
- NVIDIA runtime verification
- XRT/XDNA2 NPU verification
- Portability testing (generic x64)

---

### Epoch II — Entity Awakening `[PENDING]`

**Goal:** AI tooling layer integrated. RaBbLE entity begins to take form.

**Scope:**
- Ollama local inference
- MCP servers wired (filesystem, git, rabble-state)
- RaBbLE shell integration
- Ambient monitoring agent
- RaBbLE-lang in AI interfaces

---

### Epoch ∞ — Continuous Drift `[PERPETUAL]`

RaBbLE-OS absorbs new tools, new models, new patterns. Never complete.

---

## Layer State Map

### Layer 0 — Base `%LOCKED%`

Core packages, repos, locale, fonts.

| Role | Packages | Config | State |
|------|---------|--------|-------|
| core | ✓ | ✓ | %LOCKED% |

---

### Layer 1 — Hardware `%TESTING_IN_PROCESS%`

Hardware abstraction via DMI profiles.

| Role | Packages | Config | State |
|------|---------|--------|-------|
| hardware/x64/asus_proart_p16 | ✓ | ~ | %TESTING_IN_PROCESS% |
| hardware/x64/generic | ✓ | ✓ | %DEPLOYABLE% |

**TODO:**
- [ ] Suspend/resume stable
- [ ] ASUS asusd reliable on boot
- [ ] Brightness keys verified
- [ ] NPU (XDNA2) verified operational

**TODO (generic):**
- [ ] Test on clean Fedora minimal

---

### Layer 2 — Boot `%TESTING_IN_PROCESS%`

GRUB2 → Plymouth → SDDM.

| Role | Packages | Config | State |
|------|---------|--------|-------|
| boot/grub2 | ✓ | ~ | %TESTING_IN_PROCESS% |
| boot/plymouth | ✓ | ~ | %DEPLOYABLE% |
| boot/session_manager | ✓ | ✓ | %STABLE% |

**TODO:**
- [ ] GRUB2: remove bg image, color-only theme
- [ ] GRUB2: 4K font (Terminus 32pt)
- [ ] GRUB2: direct-boot timeout behavior
- [ ] Plymouth: fix font reference
- [ ] Plymouth: NVIDIA defer (blacklist from initramfs)
- [ ] SDDM: Qt6 `Main.qml` validated

---

### Layer 3 — Desktop `%DEPLOYABLE%`

Hyprland compositor + shell stack.

| Role | Packages | Config | State |
|------|---------|--------|-------|
| desktop/hyprland | ✓ | ✓ | %DEPLOYABLE% |
| desktop/wayland | ✓ | ✓ | %DEPLOYABLE% |
| desktop/waybar | ✓ | ✓ | %DEPLOYABLE% |
| desktop/shell/zsh | ✓ | ✓ | %STABLE% |
| desktop/shell/bash | ✓ | ✓ | %STABLE% |
| desktop/terminal | ✓ | ✓ | %STABLE% |
| desktop/launcher | ✓ | ✓ | %DEPLOYABLE% |
| desktop/screenshot | ✓ | ✓ | %STABLE% |
| desktop/swayosd | ✓ | ✓ | %DEPLOYABLE% |
| desktop/notifications | ✓ | ✓ | %DEPLOYABLE% |
| desktop/network-applet | ✓ | ✓ | %DEPLOYABLE% |
| desktop/quickshell | ✓ | ✓ | %HIGH_ENTROPY% |
| desktop/v4l2 | ✓ | ✓ | %DEPLOYABLE% |

**TODO:**
- [ ] Hypridle configuration
- [ ] Hyprlock configuration
- [ ] Quickshell bar (long-term waybar replacement)
- [ ] Mouse settings (libinput scroll, sensitivity)
- [ ] Keyboard backlight (asusctl verify)

---

### Layer 4 — Apps `%DEPLOYABLE%`

Dev tools, IDE, browsers.

| Role | Packages | Config | State |
|------|---------|--------|-------|
| apps | ✓ | ✓ | %DEPLOYABLE% |

---

## Cross-cutting Layers

| Role | State | Notes |
|------|-------|-------|
| monitoring | %DEPLOYABLE% | btop, htop, powertop, sensors |
| runtime | %HIGH_ENTROPY% | XRT/CUDA/ROCm — conditional |
| snapper | %DEPLOYABLE% | Btrfs snapshots |

**TODO:**
- [ ] runtime: XRT for XDNA2 NPU
- [ ] runtime: CUDA for NVIDIA PRIME offload
- [ ] runtime: ROCm (if needed)
- [ ] monitoring: nvtop for GPU metrics

---

## Post-Ansible Config

Manual or scripted config that Ansible doesn't handle:

| Task | State | Scope |
|------|-------|-------|
| Hypridle (idle timeout) | %HIGH_ENTROPY% | desktop |
| Hyprlock (screen lock) | %HIGH_ENTROPY% | desktop |
| Quickshell bar | %HIGH_ENTROPY% | desktop |
| HDMI hotplug script | %DEPLOYABLE% | desktop |
| wallpaper deploy | %STABLE% | desktop |
| shell prompt (p10k vs starship) | %TESTING_IN_PROCESS% | desktop |

**TODO:**
- [ ] Hypridle: idle timeout, lock command, dim timeout
- [ ] Hyprlock: unlock shortcut, background, colors

---

## Feature Archive

Features that have cooled to stable status:

| Feature | Epoch | Archived |
|---------|-------|----------|
| Wallpaper generation + hyprpaper | I | ✓ |
| Waybar with network menu | I | ✓ |
| functionkeys mic mute fix | I | ✓ |
| hyprpaper multi-monitor | I | ✓ |
| layerctl operational | I | ✓ |
| dotctl wallpapers bundle | I | ✓ |
| HDMI hotplug script | I | ✓ |
| powertop auto-tune | I | ✓ |

---

## Surface Area — Epoch I Scope

```
CLI Tools
├── Shell (zsh + bash) ────────────────── %STABLE%
├── Prompt (starship) ────────────────── %TESTING%
├── Core utils (eza, fd, rg, fzf) ───── %DEPLOYABLE%
├── Neovim + LSP ────────────────────── %DEPLOYABLE%
└── Git tooling ──────────────────────── %DEPLOYABLE%

Desktop
├── Hyprland compositor ──────────────── %DEPLOYABLE%
├── Waybar ──────────────────────────── %DEPLOYABLE%
├── Launcher (wofi/fuzzel) ──────────── %DEPLOYABLE%
├── Notifications (mako) ──────────── %DEPLOYABLE%
├── Screenshots (grim + slurp) ─────── %STABLE%
└── Quickshell ────────────────────── %HIGH_ENTROPY% (future)

Hardware
├── NVIDIA Optimus ────────────────── %DEPLOYABLE%
├── AMD XDNA2 NPU ─────────────────── %HIGH_ENTROPY%
├── asusctl + supergfxctl ──────────── %TESTING%
└── Brightness + keyboard backlight ── %TESTING%

Monitoring
├── btop/htop ─────────────────────── %DEPLOYABLE%
├── powertop ─────────────────────── %DEPLOYABLE%
└── sensors ──────────────────────── %DEPLOYABLE%
```

---

## Epoch I Verification Checklist

Before landing to `main`:

- [ ] `layerctl apply all` completes without errors
- [ ] SDDM launches Hyprland session
- [ ] Waybar displays (clock, battery, network, workspaces)
- [ ] functionkeys work (volume, brightness, mic)
- [ ] Wallpaper displays on all monitors
- [ ] suspend/resume cycles work
- [ ] NVIDIA offload verified (`glxinfo | grep renderer`)
- [ ] Monitoring tools functional (btop, powertop)
- [ ] Layer states documented as %STABLE%

---

## Revision History

| Version | Date | Change |
|---------|------|--------|
| v0.5 | 2026-04-21 | Restructured with entropy states, layer map, epoch framing |