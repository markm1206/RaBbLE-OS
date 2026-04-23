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

**Landed on New Horizons since last Epoch I sync (needs porting):**
- Shell stack: ZSH + Bash configs, p10k, colors, aliases, functions
- Terminal: Kitty config (RaBbLE palette)
- Launcher: Fuzzel config (RaBbLE palette)
- Notifications: Mako config (urgency-tiered neon borders)
- Idle/lock: canonical hypridle.conf + hyprlock.conf with clock overlay
- Lid suspend: logind drop-in (99-rabble-lid.conf) + Ansible task
- dotctl: kitty/fuzzel/mako bundles added; missing-bundle skip fix
- Grimoire: all docs renamed RaBbLE-OS-*, Architecture rewritten, RaBbLE.md distilled

**Remaining for Epoch I landing:**
- [ ] Port 4 packages from New Horizons → Epoch I (see Assembly Plan below)
- [ ] Portability smoke-test: fresh Fedora 43 bootstrap end-to-end
- [ ] Verify all checklist items in Bootstrap Checklist below
- [ ] Mark all passing layers `%STABLE%` in Layer State Map

---

### Epoch I — Assembly Plan

**Strategy:** Use `git checkout RaBbLE-OS-New-Horizons -- <paths>` to bring files
into Epoch I without importing dev history. Commit in dependency order.
Do NOT cherry-pick — the branches have divergent history.

After Epoch I lands on main: `git rebase main` on New Horizons to restore shared history.

#### What stays in New Horizons / mend-I (NOT for Epoch I)

| Files | Reason |
|-------|--------|
| `ansible/roles/hardware/x64/asus_proart_p16/tasks/nvidia.yml` | mend-I/proart-nvidia |
| `ansible/roles/hardware/x64/asus_proart_p16/handlers/main.yml` | mend-I/proart-nvidia |
| `ansible/roles/hardware/x64/asus_proart_p16/tasks/supergfx.yml` | mend-I/proart-nvidia |

#### Package 1 — control-plane

```bash
git checkout RaBbLE-OS-New-Horizons -- RaBbLE-OS-dotctl.sh .gitignore README.md
```

What changed: kitty/fuzzel/mako bundles added; mako fixed from file→directory;
missing-bundle skip (walk_bundle warns instead of exit 1).

Commit: `harmonize ~ control-plane >> dotctl bundles: kitty, fuzzel, mako; skip missing // %CONTROL_PLANE_LIVE%`

#### Package 2 — ansible-roles

```bash
git checkout RaBbLE-OS-New-Horizons -- \
  ansible/inventory/group_vars/all.yml \
  ansible/roles/boot/session_manager/handlers/main.yml \
  ansible/roles/boot/session_manager/tasks/config.yml \
  ansible/roles/desktop/hyprland/tasks/config.yml \
  ansible/roles/desktop/hyprland/tasks/dotfiles.yml \
  ansible/roles/desktop/hyprland/vars/main.yml \
  ansible/roles/desktop/shell/zsh/tasks/packages.yml \
  ansible/roles/desktop/swayosd/tasks/service.yml \
  ansible/roles/desktop/terminal/tasks/packages.yml \
  ansible/roles/desktop/waybar/tasks/config.yml \
  ansible/roles/desktop/waybar/tasks/dotfiles.yml \
  ansible/roles/desktop/waybar/vars/main.yml \
  ansible/roles/desktop/wayland/vars/main.yml
```

What changed: logind lid policy (session_manager); kitty + zsh packages wired (terminal,
shell/zsh); swayosd service scope; waybar/hyprland vars updated for new config paths.

Commit: `ingest ~ ansible-roles >> logind lid, kitty+zsh packages, waybar/hyprland vars // %ROLES_UPDATED%`

#### Package 3 — config

```bash
git checkout RaBbLE-OS-New-Horizons -- \
  config/hypr/ \
  config/kitty/ \
  config/fuzzel/ \
  config/mako/ \
  config/shell/ \
  config/systemd/ \
  config/wallpapers/
```

What changed: hypridle.conf (canonical, with suspend chain); hyprlock.conf (clock overlay,
RaBbLE palette); autostart.conf (lid bindl removed — logind handles it); Kitty RaBbLE theme;
Fuzzel RaBbLE theme; Mako urgency-tiered neon; full ZSH + Bash shell stack; logind drop-in.

Commit: `ingest ~ config >> shell stack, kitty, fuzzel, mako, hypridle/lock, lid suspend // %CONFIG_COMPLETE%`

#### Package 4 — grimoire

```bash
git checkout RaBbLE-OS-New-Horizons -- grimoire/
git rm grimoire/Architecture.md
git rm grimoire/components/RaBbLE.svg
```

What changed: docs renamed RaBbLE-OS-*; Architecture rewritten (current state only);
KnownIssues updated; RaBbLE.md distilled to manifesto+lore; ShellGuide added;
Roadmap cross-referenced to NonZense for future content.

Commit: `harmonize ~ grimoire >> rename docs RaBbLE-OS-prefix; current-state only // %GRIMOIRE_CURRENT%`

---

### Bootstrap Checklist — Epoch I (Fedora 43)

Run this after assembling the packages above. Record pass/fail against each item.
Any failure becomes a `mend-I/*` issue or a blocker that holds epoch landing.

#### Pre-Bootstrap

- [ ] All 4 packages ported to `RaBbLE/epoch-I` and committed
- [ ] `git log --oneline RaBbLE/epoch-I` — verify clean package history
- [ ] Dry run on current machine: `layerctl apply all --check`

#### Install Sequence

- [ ] Fresh Fedora 43 base (clean install or snapshot at post-install state)
- [ ] `curl -fsSL .../RaBbLE-OS-Install.sh | bash` — or clone + `bash RaBbLE-OS-Bootstrap.sh`
- [ ] `ansible-galaxy collection install -r ansible/requirements.yml`
- [ ] `./RaBbLE-OS-layerctl.sh apply all` — note any errors, do not skip them
- [ ] `./RaBbLE-OS-dotctl.sh apply all`
- [ ] Reboot

#### Session Verification

- [ ] SDDM greeter appears (not dropped to TTY)
- [ ] Hyprland session starts — wallpaper visible
- [ ] Waybar renders (clock, battery, network, workspaces)
- [ ] Function keys: volume, brightness, mic-mute (swayosd OSD fires)
- [ ] `Super+Space` → Fuzzel launcher opens
- [ ] Terminal opens (Kitty, RaBbLE palette visible)
- [ ] Screenshots: Print key (region), Shift+Print (full)
- [ ] `notify-send "test" "body"` → Mako notification fires
- [ ] Hyprlock triggers after 5 min idle (or `loginctl lock-session`)
- [ ] HDMI hotplug (if second display available)

#### Shell Verification

- [ ] ZSH loads with p10k prompt (requires p10k installed — see packages)
- [ ] Bash loads with RaBbLE two-line prompt
- [ ] `ll`, `gs`, `rabble`, `rabble-dots` aliases work
- [ ] `fcd`, `fe`, `extract` functions available in ZSH
- [ ] `LS_COLORS`, `FZF_DEFAULT_OPTS`, `BAT_THEME` set (check `colors256`)

#### Final Gate

- [ ] `layerctl verify all` — all layers report `%STABLE%` or documented exception
- [ ] Any new failures logged to `RaBbLE-OS-KnownIssues.md`
- [ ] If all gates pass: land epoch to main
  ```
  git checkout main
  git merge --squash RaBbLE/epoch-I
  git commit -m "evolve ~ substrate >> epoch-I crystallized // %EPOCH_I_LANDED%"
  git checkout RaBbLE-OS-New-Horizons
  git rebase main
  ```

---

### Fedora 44 Migration Plan

Do NOT attempt on the same day as the Epoch I bootstrap. Validate F43 first.

- [ ] Open `mend-I/fedora44` branch from New Horizons
- [ ] Check COPR availability: `dnf copr enable lionheartp/Hyprland` on F44 — verify packages exist
- [ ] Check SDDM Qt6 version bump on F44 (may affect greeter)
- [ ] Run full `layerctl apply all` on F44, diff against F43 output
- [ ] If clean: add F44 note to `AiQuickstart.md`, merge `mend-I/fedora44` → New Horizons
- [ ] If breakage: file issues, fix in mend branch before promoting

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
- Quickshell bar replaces Waybar

**Note:** Epoch II does **not** block on `mend-I/proart-nvidia`. AI stack runs
on CPU inference until the driver is stable; GPU acceleration is a bonus, not
a prerequisite.

**Detailed AI stack spec:** model roster, ChromaDB, aichat config, MCP server list,
and model selection heuristics are preserved in `DistilledNonZense.md` § VII.
The entity memory tier model (short/medium/long-term) is in `RaBbLE.md` — Memory Architecture.

---

### Epoch III — `[UNWRITTEN]`

Likely candidates: entity memory/continuity, distributed-collective
concerns, persistent agent presence, and advanced workspace design.

**WM usage vision** (workspaces as task-spaces, tiling/floating hybrid,
draggable windows with intelligent snapping, per-workspace defaults) is
preserved in `DistilledNonZense.md` § IX for when this epoch is scoped.

**Long-term architecture** (multi-repo layer model, Yocto-style manifest)
is preserved in `DistilledNonZense.md` § XI.

---

### Epoch ∞ — Continuous Drift `[PERPETUAL]`

RaBbLE-OS absorbs new tools, new models, new patterns. Never complete.

---

## Layer State Map

> **Key:** ✓ live  ✗ stub  ~ partial  → after assembly plan

### Layer 0 — Base

| Role | Pkgs (epoch-I now) | Pkgs (after assembly) | Config | State |
|------|-------------------|----------------------|--------|-------|
| core | ✗ stub | ✗ stub | ✗ stub | %DORMANT% — relies on Fedora Sway spin defaults |

---

### Layer 1 — Hardware

| Role | Pkgs | Config | State | Target |
|------|------|--------|-------|--------|
| hardware/x64/generic | ✓ | ✗ stub | %DORMANT% | Epoch I scaffold |
| hardware/x64/asus_proart_p16 | ✗ stub | ✗ stub | %DORMANT% | Epoch I scaffold only |
| asus_proart_p16/nvidia | ✗ stub | ✗ stub | %DORMANT% | mend-I/proart-nvidia |
| asus_proart_p16/supergfx | ✗ stub | ✗ stub | %DORMANT% | mend-I/proart-nvidia |
| asus_proart_p16/npu | ✗ stub | ✗ stub | %DORMANT% | mend-I/xdna2-npu |

---

### Layer 2 — Boot

| Role | Pkgs | Config | State | Target |
|------|------|--------|-------|--------|
| boot/grub2 | ✓ | ~ partial | %TESTING_IN_PROCESS% | mend-I/boot-chain |
| boot/plymouth | ✓ | ~ partial | %TESTING_IN_PROCESS% | mend-I/boot-chain |
| boot/session_manager | ✗ stub | ✗ stub → ✓ | %DORMANT% → %DEPLOYABLE% | Epoch I (logind lid config via assembly) |

---

### Layer 3 — Desktop

| Role | Pkgs (now) | Pkgs (after) | Config (now) | Config (after) | State |
|------|-----------|-------------|-------------|---------------|-------|
| desktop/wayland | ✓ | ✓ | ~ partial | ~ partial | %DEPLOYABLE% |
| desktop/hyprland | ✓ | ✓ | ✓ | ✓ updated | %DEPLOYABLE% |
| desktop/waybar | ✓ | ✓ | ✓ | ✓ updated | %DEPLOYABLE% |
| desktop/terminal | ✗ stub | ✓ kitty | ✗ stub | ✓ kitty.conf | %DORMANT% → %DEPLOYABLE% |
| desktop/launcher | ✓ fuzzel | ✓ fuzzel | ✗ stub | ✓ fuzzel.ini | %DORMANT% → %DEPLOYABLE% |
| desktop/notifications | ✓ mako | ✓ mako | ✗ stub | ✓ mako/config | %DORMANT% → %DEPLOYABLE% |
| desktop/shell/zsh | ✗ stub | ✓ zsh+plugins | ✗ stub | ✓ full stack | %DORMANT% → %DEPLOYABLE% |
| desktop/shell/bash | ✗ stub | ✗ stub | ✗ stub | ✓ .bashrc | %DORMANT% → %DEPLOYABLE% |
| desktop/screenshot | ✓ | ✓ | ✓ | ✓ | %STABLE% |
| desktop/swayosd | ✓ | ✓ | ✓ | ✓ updated | %DEPLOYABLE% |
| desktop/network-applet | ✓ | ✓ | ✓ | ✓ | %DEPLOYABLE% |
| desktop/v4l2 | ✓ | ✓ | ✓ | ✓ | %DEPLOYABLE% |
| desktop/quickshell | ✓ pkgs | ✓ pkgs | ✗ build | ✗ build | %HIGH_ENTROPY% — Epoch II |

---

### Layer 4 — Apps

| Role | Pkgs | Config | State |
|------|------|--------|-------|
| apps | ✗ stub | ✗ stub | %DORMANT% — no packages defined yet |

---

### Cross-cutting

| Role | State | Notes |
|------|-------|-------|
| monitoring | %DEPLOYABLE% | btop, htop, powertop, lm_sensors live |
| snapper | %DEPLOYABLE% | Btrfs snapshots wired |
| runtime | %DORMANT% | XRT/CUDA/ROCm — mend-I/proart-nvidia + mend-I/xdna2-npu |

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
