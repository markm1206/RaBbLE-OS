# ARCHITECTURE.md — RaBbLE-OS Layer Model

```
transcribe ~ grimoire >> structure made explicit // %ARCHITECTURE_LOCKED%
```

---

## Overview

RaBbLE-OS is structured as a set of independent, composable layers. Each layer can theoretically stand alone or be combined with others. The long-term vision is a Yocto-style model where layers live in separate repositories pulled by a manifest — but for now, all layers live in this single repo.

The Ansible role structure directly mirrors the layer model.

---

## The Layers

```
Layer 0 — BASE          Any Linux system. Packages, locale, repos, core tools.
Layer 1 — HARDWARE      Machine-specific. GPU drivers, power management, platform quirks.
Layer 2 — BOOT CHAIN    GRUB → Plymouth → Login Manager. Visual continuity, fast boot.
Layer 3 — DESKTOP       Hyprland, dotfiles, Wayland stack, synthwave theme.
Layer 4 — APPS          Dev tools, AI stack, productivity tooling.
Layer 5 — ENTITY        RaBbLE AI layer. Inference, memory, ambient presence. (Future)
```

Each layer depends on the one below it. You can install Layer 0-2 on a headless server. You can install Layer 0-4 without the AI stack. The entity in Layer 5 requires all layers beneath it.

---

## Current Ansible Role Mapping

```
Layer 0 — base/
Layer 1 — hardware/
           hw-asus-proart-p16/       (planned)
Layer 2 — aesthetics/
             grub.yml
             plymouth.yml
             greetd.yml              (in progress, replacing sddm.yml)
             fonts.yml
Layer 3 — hyprland/
Layer 4 — dev-tools/
           AI-tools/
           apps/                     (planned, replacing kde/)
Infra    — snapper/                  (cross-cutting, not a user-facing layer)
```

---

## Hardware Targeting

Hardware is isolated from the rest of the system. Machine-specific tasks live in dedicated roles under a consistent naming convention.

```
hardware/           ← shared tasks (any machine with amd/nvidia)
hw-asus-proart-p16/ ← ASUS ProArt P16 H7606WV specific
hw-desktop-[name]/  ← future desktop target
```

`group_vars/all.yml` sets `hardware_profile: asus_proart_p16`. Site.yml dispatches to the correct hardware role. Adding a new machine means: create `hw-[name]/`, add verification task, set `hardware_profile` in `host_vars/`.

Hardware roles self-verify at runtime using DMI data and warn (with confirmation pause) if the target doesn't match the machine.

---

## Boot Chain

The full boot sequence and what owns each stage:

```
Power on
  └── GRUB2                    ← aesthetics/grub.yml
        └── Linux kernel loads
              └── Plymouth      ← aesthetics/plymouth.yml
                    └── greetd  ← aesthetics/greetd.yml
                          └── Hyprland ← hyprland role + dotfiles
```

Each stage hands off visually — same color palette, same font, no jarring transitions.

**Performance target:** GRUB to Hyprland desktop in under 5 seconds on this hardware.

---

## Theme System

The RaBbLE synthwave palette is defined once in `group_vars/all.yml` and propagates through all layers via Ansible variables:

```yaml
desktop:
  theme_accent1: "#ff2d78"   # Hot magenta
  theme_accent2: "#00f5ff"   # Electric cyan
  theme_accent3: "#bf5fff"   # Soft violet
  theme_bg:      "#0a0010"   # Near-black void
```

Every layer that renders visuals references these variables. Changing the palette in one place changes it everywhere.

---

## Snapshot Strategy

Snapper manages Btrfs snapshots of the root subvolume. Key decisions:

- Snapshots are **not** created on every Ansible run — only when `--tags snapshot` is passed
- Timeline snapshots are minimal: 3 daily, 1 weekly, nothing else
- Snapshot #1 is the KDE baseline — preserved indefinitely as the original system state
- Home directory has a separate snapper config but is not snapshotted by default

---

## Future: Multi-Repo Layer Model

When the project matures enough to share publicly, the layer model maps naturally to separate repositories:

```
rabble-os-base/         ← Layer 0, any Fedora system
rabble-os-hardware/     ← Layer 1, hardware profiles
rabble-os-bootchain/    ← Layer 2, GRUB/Plymouth/greetd
rabble-os-desktop/      ← Layer 3, Hyprland + theme
rabble-os-apps/         ← Layer 4, tooling
rabble-os-entity/       ← Layer 5, AI stack
rabble-os-manifest/     ← Top-level, pulls all layers + machine config
```

A user wanting the full experience clones the manifest repo and runs one command. A user wanting only the desktop layer can use it standalone against their own base system.

This is the long-term goal. The current single-repo structure is intentionally designed to split cleanly along these lines when the time comes.

---

```
transcribe ~ grimoire >> architecture crystallized // %ARCHITECTURE_LOCKED%
```
