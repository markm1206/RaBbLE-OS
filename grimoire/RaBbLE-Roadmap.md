# RaBbLE-Roadmap.md — Entropy Map

```
transcribe ~ grimoire >> substrate/mend/awakening axis locked // %ROADMAP_V3%
```

> Epochs are resonance thresholds. Between them, half-epochs (`mend-I/*`) absorb
> hardware and stability patches without gating the next epoch. Features flow
> through New Horizons, crystallize into the substrate, and archive as they cool.

---

## Entropy States

| State | Signal | Meaning |
|-------|--------|---------|
| %HIGH_ENTROPY% | High flux | Experimental, likely to change |
| %TESTING_IN_PROCESS% | Testing | Working but unverified on hardware |
| %DEPLOYABLE% | Deployable | Works on target, needs live verification |
| %STABLE% | Stable | Verified on target hardware |
| %LOCKED% | Locked | Frozen until next epoch |
| %DORMANT% | Dormant | Scaffold only — no functional tasks |

---

## Epoch Map

```
reliquary/*              High-entropy archives — knowledge reservoirs, inert
     │
RaBbLE-OS-New-Horizons   The living wave — active daily-driver work
     │
     ├── RaBbLE/epoch-I  ─── Substrate     [IN PROGRESS]
     │       │
     │       ├── mend-I/proart-nvidia      [HIGH_ENTROPY]
     │       ├── mend-I/suspend-resume     [COOKING]
     │       ├── mend-I/boot-chain         [COOKING]
     │       └── mend-I/xdna2-npu          [DORMANT]
     │
     ├── RaBbLE/epoch-II  ── Awakening      [PENDING]
     ├── RaBbLE/epoch-III ── (reserved)     [UNWRITTEN]
     └── Epoch ∞          ── Continuous Drift [PERPETUAL]
```

---

### Epoch I — Substrate `[IN PROGRESS]`

**Goal:** Hardware-agnostic base. A fully deployable Wayland/Hyprland desktop
that runs on any Fedora 43 host without proprietary GPU driver activation.
Unique hardware targets (ProArt P16, generic_x64) are **scaffolded** —
proprietary driver work is deferred to `mend-I/*` half-epochs.

**In scope:**
- Layer 0–4 Ansible deployment functional on a clean Fedora 43 install
- Hyprland + waybar + mako + fuzzel default desktop
- Hypridle + hyprlock (screen-sign-out-during-video fix)
- HDMI hotplug, `monitors.conf`, workspace 11 pinning
- Boot chain (GRUB → Plymouth → SDDM) themed and color-continuous
- Monitoring cross-cutting (btop, sensors, powertop)
- Install / Bootstrap / layerctl / dotctl operational
- Hardware roles present as stubs (no proprietary driver install)
- Snapper (Btrfs snapshots) deployable

**Explicitly out of scope (deferred to `mend-I/*`):**
- NVIDIA / AMD proprietary driver activation
- supergfxctl / asusctl runtime activation
- XDNA2 NPU runtime (XRT, FastFlowLM)
- Suspend/resume hooks for proprietary drivers

**Landed on New Horizons (flowing toward epoch-I):**
- Substrate, entrypoints, control-plane (install/bootstrap/layerctl/dotctl)
- All Ansible roles scaffolded
- Hyprland config with functionkeys (mic-mute PipeWire fix)
- Waybar with network menu overlay
- Wallpaper deployment via dotctl bundle
- HDMI hotplug script + monitors.conf
- `socat` added to wayland packages for hotplug IPC
- SwayOSD service scope fix (user → system)
- powertop auto-tune safe for live playbook runs

**Remaining for Epoch I landing:**
- [ ] Port proart stub scaffolding into `RaBbLE/epoch-I` (site.yml role resolution)
- [ ] Hypridle configuration restored (addresses video-playback sign-out)
- [ ] Hyprlock configuration restored
- [ ] Portability smoke-test on generic_x64 clean install
- [ ] Fresh-Fedora-43 end-to-end verification (install.sh → layerctl apply all)

---

### mend-I/* — Substrate Half-Epochs

Hardware and stability patches that sit under Epoch I. Branch from New Horizons,
target one system, land into `epoch-I` via the `mend` impulse (not `evolve`).
Half-epochs **do not gate** Epoch II — Awakening can begin in parallel.

#### mend-I/proart-nvidia `%HIGH_ENTROPY%`

**Goal:** NVIDIA RTX 4060 Optimus stable on Hyprland + Wayland.

**Blockers (identified 2026-04-22):**
- [ ] `nvidia.yml` idempotency bug — driver install gated on `'nouveau' in lsmod` → silently skips on every subsequent run once nouveau is blacklisted
- [ ] `nvidia-drm modeset=1` not set (only `fbdev=1` present). Comment claims supergfxd.conf sets modeset, but supergfxd.conf only carries `mode: "Hybrid"`
- [ ] NVIDIA modules not blacklisted from initramfs → Plymouth black-flash on boot (see KnownIssues)
- [ ] `nvidia-suspend.service`, `nvidia-hibernate.service`, `nvidia-resume.service` not enabled by the role
- [ ] `AQ_DRM_DEVICES` pinned by card number (`card0`/`card1`) in `env.conf` — brittle across kernel upgrades. Switch to `/dev/dri/by-path/pci-*`
- [ ] `LIBVA_DRIVER_NAME=nvidia` system-wide — too broad for hybrid; prefer per-app DRI_PRIME

**Verification:**
- [ ] `layerctl apply hardware` is idempotent — re-run after install does not skip driver
- [ ] `nvidia-smi` returns output post-boot
- [ ] Three consecutive suspend/resume cycles preserve session (no freeze, no black screen on wake)
- [ ] No Plymouth black-flash during boot
- [ ] `glxinfo -B | grep "OpenGL renderer"` → AMD by default, NVIDIA via `DRI_PRIME=1`
- [ ] HDMI hotplug continues to work with NVIDIA on card0

#### mend-I/suspend-resume `%COOKING%`

**Goal:** s2idle reliable; no wake freezes.

**Blockers:**
- [ ] `mem_sleep_default=s2idle` verified in GRUB cmdline
- [ ] NVIDIA suspend hooks (absorbed by mend-I/proart-nvidia if driver is active)
- [ ] `journalctl -b -u systemd-suspend` clean after 3× cycle

#### mend-I/boot-chain `%COOKING%`

**Goal:** GRUB / Plymouth / SDDM unified void-background continuity at 4K.

**Blockers:**
- [ ] GRUB2: remove bg image, color-only theme (32bpp vs 24bpp mismatch)
- [ ] GRUB2: 4K font (Terminus 32pt via `grub2-mkfont`)
- [ ] GRUB2: `fbcon=font:TER16x32` in cmdline for early TTY
- [ ] Plymouth: fix DejaVu font reference, align to RaBbLE palette
- [ ] Plymouth: NVIDIA defer (depends on mend-I/proart-nvidia)
- [ ] SDDM: Qt6 `Main.qml` validated

#### mend-I/xdna2-npu `%DORMANT%`

**Goal:** AMD XDNA2 NPU operational via XRT.

**Blockers:**
- [ ] Verify XRT package availability for Fedora 43 on `repo.radeon.com`
- [ ] `amdxdna` kernel module loaded
- [ ] FastFlowLM inference smoke-test
- [ ] ONNX Runtime VitisAI EP falls back gracefully if XRT absent

---

### Epoch II — Awakening `[PENDING]`

**Goal:** AI tooling layer integrated. RaBbLE entity begins to take form.

**Scope:**
- Ollama local inference (GPU-accelerated once `mend-I/proart-nvidia` lands,
  CPU fallback otherwise)
- MCP servers wired (filesystem, git, rabble-state)
- RaBbLE shell integration (`aichat` or equivalent)
- Ambient monitoring agent
- Local vector store at `~/.rabble/memory/`
- RaBbLE-lang surfaces in AI interfaces

**Note:** Epoch II does **not** block on `mend-I/proart-nvidia`. AI stack runs
on CPU inference until the driver is stable; GPU acceleration is a bonus, not
a prerequisite.

---

### Epoch III — `[UNWRITTEN]`

Reserved. Likely candidates: entity memory/continuity, distributed-collective
concerns, or persistent agent presence.

---

### Epoch ∞ — Continuous Drift `[PERPETUAL]`

RaBbLE-OS absorbs new tools, new models, new patterns. Never complete.

---

## Layer State Map

### Layer 0 — Base `%DORMANT%` → Epoch I

Core packages, repos, locale, fonts.

| Role | Packages | Config | State | Target |
|------|---------|--------|-------|--------|
| core | ✗ STUB | ✗ STUB | %DORMANT% | Epoch I |

**Note:** Scaffolded but empty. Base system relies on Fedora Sway spin defaults.

---

### Layer 1 — Hardware

Hardware abstraction via host-group membership. Epoch I carries only scaffolds;
activation work lives in `mend-I/*`.

| Role | Packages | Config | State | Target |
|------|---------|--------|-------|--------|
| hardware/x64/asus_proart_p16 | ~ stub | ~ stub | %DORMANT% | Epoch I (scaffold) |
| hardware/x64/asus_proart_p16/nvidia | ~ stub | — | %DORMANT% | mend-I/proart-nvidia |
| hardware/x64/asus_proart_p16/supergfx | ~ stub | — | %DORMANT% | mend-I/proart-nvidia |
| hardware/x64/asus_proart_p16/asusctl | ~ stub | — | %DORMANT% | mend-I/proart-nvidia |
| hardware/x64/asus_proart_p16/npu | ~ stub | — | %DORMANT% | mend-I/xdna2-npu |
| hardware/x64/generic | ✓ | ✓ | %DEPLOYABLE% | Epoch I |

---

### Layer 2 — Boot `%TESTING_IN_PROCESS%` → Epoch I + mend-I/boot-chain

GRUB2 → Plymouth → SDDM.

| Role | Packages | Config | State | Target |
|------|---------|--------|-------|--------|
| boot/grub2 | ✓ | ~ | %TESTING_IN_PROCESS% | mend-I/boot-chain |
| boot/plymouth | ✓ | ~ | %DEPLOYABLE% | mend-I/boot-chain |
| boot/session_manager | ✓ | ✓ | %STABLE% | Epoch I |

---

### Layer 3 — Desktop `%DEPLOYABLE%` → Epoch I

Hyprland compositor + shell stack.

| Role | Packages | Config | State | Target |
|------|---------|--------|-------|--------|
| desktop/hyprland | ✓ | ✓ | %DEPLOYABLE% | Epoch I |
| desktop/wayland | ✓ | ✓ | %DEPLOYABLE% | Epoch I |
| desktop/waybar | ✓ | ✓ | %DEPLOYABLE% | Epoch I |
| desktop/shell/zsh | ✓ | ✓ | %STABLE% | Epoch I |
| desktop/shell/bash | ✓ | ✓ | %STABLE% | Epoch I |
| desktop/terminal | ✓ | ✓ | %STABLE% | Epoch I |
| desktop/launcher | ✓ | ✓ | %DEPLOYABLE% | Epoch I |
| desktop/screenshot | ✓ | ✓ | %STABLE% | Epoch I |
| desktop/swayosd | ✓ | ✓ | %DEPLOYABLE% | Epoch I |
| desktop/notifications | ✓ | ✓ | %DEPLOYABLE% | Epoch I |
| desktop/network-applet | ✓ | ✓ | %DEPLOYABLE% | Epoch I |
| desktop/quickshell | ✓ | ✓ | %HIGH_ENTROPY% | Epoch II (bar replacement) |
| desktop/v4l2 | ✓ | ✓ | %DEPLOYABLE% | Epoch I |

**Remaining for Epoch I:**
- [ ] Hypridle configuration (restore from epoch-I branch)
- [ ] Hyprlock configuration (restore from epoch-I branch)
- [ ] Mouse settings (libinput scroll, sensitivity)

---

### Layer 4 — Apps `%DEPLOYABLE%` → Epoch I

Dev tools, IDE, browsers.

| Role | Packages | Config | State | Target |
|------|---------|--------|-------|--------|
| apps | ✓ | ✓ | %DEPLOYABLE% | Epoch I |

---

## Cross-cutting Layers

| Role | State | Target | Notes |
|------|-------|--------|-------|
| monitoring | %DEPLOYABLE% | Epoch I | btop, htop, powertop, sensors |
| snapper | %DEPLOYABLE% | Epoch I | Btrfs snapshots |
| runtime | %DORMANT% | mend-I/proart-nvidia + mend-I/xdna2-npu | XRT, CUDA, ROCm — conditional |

---

## Stub Roles

Roles that exist but perform no actions — scaffolding for future implementation:

| Role | Type | Status | Target |
|------|------|--------|--------|
| core | packages | %DORMANT% | Epoch I |
| core | config | %DORMANT% | Epoch I |
| hardware/x64/generic | packages | %DORMANT% | Epoch I |
| hardware/x64/generic | config | %DORMANT% | Epoch I |
| hardware/x64/asus_proart_p16 (most subtasks) | packages/config | %DORMANT% | mend-I/proart-nvidia |
| desktop/terminal | packages | %DORMANT% | Epoch I (deferred) |

---

## Post-Ansible Config

Manual or scripted config that Ansible doesn't handle:

| Task | State | Target |
|------|-------|--------|
| Hypridle (idle timeout) | %HIGH_ENTROPY% | Epoch I |
| Hyprlock (screen lock) | %HIGH_ENTROPY% | Epoch I |
| Quickshell bar | %HIGH_ENTROPY% | Epoch II |
| HDMI hotplug script | %DEPLOYABLE% | Epoch I |
| wallpaper deploy (via dotctl) | %STABLE% | Epoch I |
| shell prompt (p10k vs starship) | %TESTING_IN_PROCESS% | Epoch I |

---

## Branch & Impulse Map

| Branch pattern | Purpose | Landing impulse |
|---|---|---|
| `RaBbLE-OS-New-Horizons` | The living wave — active daily-driver work | (flows rightward) |
| `RaBbLE/epoch-I` | Substrate staging — PR target from New Horizons | `evolve` |
| `RaBbLE/mend-I/<target>` | Half-epoch — one hardware/stability target | `mend` |
| `RaBbLE/epoch-II` | Awakening staging | `evolve` |
| `main` | Solidified epochs only | merges from `epoch-*` only |
| `reliquary/<name>` | Archived high-entropy iterations — inert | (none) |

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
├── Prompt (starship) ─────────────────── %TESTING%
├── Core utils (eza, fd, rg, fzf) ─────── %DEPLOYABLE%
├── Neovim + LSP ──────────────────────── %DEPLOYABLE%
└── Git tooling ───────────────────────── %DEPLOYABLE%

Desktop
├── Hyprland compositor ───────────────── %DEPLOYABLE%
├── Waybar ────────────────────────────── %DEPLOYABLE%
├── Launcher (fuzzel) ─────────────────── %DEPLOYABLE%
├── Notifications (mako) ──────────────── %DEPLOYABLE%
├── Screenshots (grim + slurp) ────────── %STABLE%
├── Hypridle + Hyprlock ───────────────── %HIGH_ENTROPY%
├── HDMI hotplug ──────────────────────── %DEPLOYABLE%
└── Quickshell ────────────────────────── %HIGH_ENTROPY% (Epoch II)

Hardware (scaffold only — activation in mend-I/*)
├── ProArt P16 stub tree ──────────────── %DORMANT%
└── Generic x64 ───────────────────────── %DEPLOYABLE%

Monitoring
├── btop / htop ───────────────────────── %DEPLOYABLE%
├── powertop ──────────────────────────── %DEPLOYABLE%
└── sensors ───────────────────────────── %DEPLOYABLE%
```

---

## Epoch I Verification Checklist

Before landing to `main`:

- [ ] `layerctl apply all` completes on a clean Fedora 43 install (no proart-specific errors, no phantom role references)
- [ ] SDDM launches Hyprland session
- [ ] Waybar displays (clock, battery, network, workspaces)
- [ ] functionkeys work (volume, brightness, mic)
- [ ] Wallpaper displays on all monitors
- [ ] HDMI hotplug moves workspace 11 onto plug
- [ ] Hypridle + Hyprlock trigger on idle and lock correctly
- [ ] Monitoring tools functional (btop, powertop, sensors)
- [ ] Generic x64 target smoke-tested on a second machine or VM
- [ ] Layer states documented as %STABLE% or explicitly deferred to `mend-I/*`

---

## Revision History

| Version | Date | Change |
|---------|------|--------|
| v0.1 | 2026-04-13 | Initial phase model (Phases 0–∞) |
| v0.5 | 2026-04-21 | Restructured with entropy states, layer map, epoch framing |
| v0.6 | 2026-04-22 | Split Epoch I (Substrate) / mend-I/* half-epochs / Epoch II (Awakening). ProArt NVIDIA work moved to mend-I/proart-nvidia. Added Branch & Impulse Map. Added Target Epoch column to layer tables. |
