# RaBbLE-OS — Ansible Usage Guide

> **Scope:** How the Ansible automation in this project is structured, how to
> verify your configuration, how to run playbooks safely, and how to roll back
> any change cleanly.

---

## Table of Contents

1. [Project Structure](#1-project-structure)
2. [Inventory Architecture](#2-inventory-architecture)
3. [Variable Hierarchy](#3-variable-hierarchy)
4. [Roles & Layers](#4-roles--layers)
5. [Power Stack Profiles](#5-power-stack-profiles)
6. [Prerequisites](#6-prerequisites)
7. [Verification — Before You Run Anything](#7-verification--before-you-run-anything)
8. [Running the Playbook](#8-running-the-playbook)
9. [Targeting Specific Layers](#9-targeting-specific-layers)
10. [Experimenting Safely](#10-experimenting-safely)
11. [Rollback Reference](#11-rollback-reference)
12. [Recommended First-Run Sequence](#12-recommended-first-run-sequence)

---

## 1. Project Structure

```
ansible/
├── ansible.cfg                         # Ansible runtime configuration
├── requirements.yml                    # Required collections
├── site.yml                            # Master playbook — entry point
├── inventory/
│   ├── hosts.yml                       # Host and group definitions
│   ├── group_vars/
│   │   ├── all.yml                     # Universal vars: identity, paths, theme, shell
│   │   ├── asus_proart_p16.yml         # ASUS-specific: power stack, NPU, GPU
│   │   ├── laptops.yml                 # form_factor: laptop
│   │   ├── generic_x64.yml             # Safe defaults for unknown x64 hardware
│   │   └── sbc_0.yml                   # SBC minimal config
│   └── host_vars/
│       └── localhost.yml               # Connection details for local deployment
└── roles/
    ├── core/                           # Headless base system — zero dependencies
    ├── hardware/                       # Kernel modules, firmware, vendor quirks
    ├── system-services/                # Power arbitration, tuned, asusd, supergfxd
    ├── runtime/                        # XRT + XDNA2 NPU userspace runtime
    ├── observability/                  # lm-sensors, powertop
    ├── dev-tools/                      # Developer tooling
    └── ui_ux/
        └── hyprland/                   # Hyprland desktop environment
```

---

## 2. Inventory Architecture

Hosts are classified on **two independent axes** that both contribute group vars:

```
Architecture axis          Hardware profile axis
─────────────────          ─────────────────────
x64/                       asus_proart_p16/
  laptops/                 generic_x64/
  desktops/                sbc_0/
aarch64/
  sbc/
```

`localhost` belongs to both `laptops` (architecture axis) and `asus_proart_p16`
(hardware profile axis). Ansible merges vars from both groups. If a var is
defined in both, `asus_proart_p16` wins because it is more specific.

### `hosts.yml` — Annotated

```yaml
all:
  children:
    # Architecture classification
    x64:
      children:
        laptops:
          hosts:
            localhost:
        desktops:
          hosts: {}
    aarch64:
      children:
        sbc:
          hosts: {}

    # Hardware profile classification — drives group_vars lookups
    asus_proart_p16:
      hosts:
        localhost:
    generic_x64:
      hosts: {}
    sbc_0:
      hosts: {}

  vars:
    rabble_repo_root: "{{ playbook_dir | dirname }}"
```

Connection details for `localhost` live in `host_vars/localhost.yml` — not
inline in `hosts.yml`:

```yaml
# inventory/host_vars/localhost.yml
ansible_connection: local
ansible_user: "{{ lookup('env', 'USER') }}"
ansible_python_interpreter: /usr/bin/python3
```

---

## 3. Variable Hierarchy

Ansible resolves variables in this order. **Last definition wins.**

```
all.yml                         ← universal fallback (identity, paths, theme, shell)
  └── group_vars/laptops.yml    ← form_factor: laptop
        └── group_vars/asus_proart_p16.yml  ← power stack, vendor, NPU, GPU
              └── host_vars/localhost.yml   ← connection details only
                    └── -e "var=value"      ← CLI override (highest precedence, never persisted)
```

### What Lives Where

| File | Contains | Does NOT contain |
|---|---|---|
| `all.yml` | Identity, paths, theme palette, shell | Power settings, hardware vendor |
| `group_vars/asus_proart_p16.yml` | `power_stack_profile`, `hardware_vendor`, `npu_enabled`, `gpu_mode` | Connection vars |
| `group_vars/laptops.yml` | `form_factor: laptop` | — |
| `host_vars/localhost.yml` | `ansible_connection`, `ansible_user` | Everything else |

> **Rule:** If a var would be wrong on any host in the inventory, it does not
> belong in `all.yml`. Power vars are wrong on an SBC. They belong in
> `group_vars/asus_proart_p16.yml`.

---

## 4. Roles & Layers

Roles run in the order defined in `site.yml`. Each layer has a strict
responsibility boundary.

```
┌─────────────────────────────────────────────┐
│  ui_ux/hyprland   Desktop environment       │  when: form_factor in [laptop, desktop]
├─────────────────────────────────────────────┤
│  dev-tools        Developer tooling         │
├─────────────────────────────────────────────┤
│  observability    lm-sensors, powertop      │  Passive — reads only, no state changes
├─────────────────────────────────────────────┤
│  runtime          XRT + XDNA2 NPU runtime   │  when: npu_enabled
├─────────────────────────────────────────────┤
│  system-services  Power arbitration         │  tuned / asusd / supergfxd
├─────────────────────────────────────────────┤
│  hardware         Kernel modules, firmware  │  Vendor tasks gated by hardware_vendor
├─────────────────────────────────────────────┤
│  core             Headless base system      │  No dependencies, no display required
└─────────────────────────────────────────────┘
```

### Role Tags

Every role and its sub-tasks are tagged. You can target any layer precisely.

| Tag | Scope |
|---|---|
| `core` | Base system packages and config |
| `hardware` | All hardware tasks |
| `hardware, npu` | AMD NPU kernel module only |
| `hardware, vendor` | ASUS platform driver tasks only |
| `system-services` | All power service tasks |
| `system-services, arbitration` | Power authority enforcement only |
| `system-services, tuned` | tuned profile tasks only |
| `system-services, asusd` | asusd (asusctl) tasks only |
| `system-services, gpu` | supergfxd GPU switching tasks only |
| `runtime` | XRT + XDNA2 userspace runtime |
| `observability` | lm-sensors + powertop |
| `verify` | Read-only status checks — safe to run any time |
| `rollback` | Rollback tasks across all roles |
| `ui_ux, hyprland` | Hyprland desktop config |
| `dev-tools` | Developer tooling |

---

## 5. Power Stack Profiles

The single most important variable on ASUS hardware. Set in
`group_vars/asus_proart_p16.yml`. Override on the CLI with `-e` for experiments
without committing anything.

| Profile | tuned | asusd | supergfxd | When to use |
|---|---|---|---|---|
| `tuned_only` | owns everything | stopped | stopped | **Safe baseline. Default.** |
| `tuned_asus` | CPU governor | fans + platform TDP | stopped | Add fan control, tuned still stable |
| `full_asus` | CPU governor | fans + platform TDP | GPU mux | Full ASUS stack + GPU switching |

### GPU Modes

Only meaningful when `power_stack_profile: full_asus`.

| `gpu_mode` | dGPU state | Use case |
|---|---|---|
| `integrated` | Fully suspended | Best battery life. **Current default.** |
| `hybrid` | PRIME offload ready | Compute workloads, plugged in |
| `dedicated` | Drives display | Maximum performance, plugged in only |

### Power Authority Matrix

`power-profiles-daemon` is **always masked** — it conflicts with both `tuned`
and `asusd`. This is enforced by `system-services/tasks/power/arbitration.yml`
on every run.

```
Concern          tuned_only    tuned_asus    full_asus
─────────────────────────────────────────────────────
CPU governor     tuned         tuned         tuned
Fan curves       —             asusd         asusd
Platform TDP     —             asusd         asusd
GPU mux          —             —             supergfxd
power-profiles-d MASKED        MASKED        MASKED
```

---

## 6. Prerequisites

```bash
# Ansible itself
sudo dnf install ansible python3-dnf

# Required Ansible collections
cd ansible/
ansible-galaxy collection install -r requirements.yml
```

**Required collections:**
- `community.general` >= 8.0.0 — provides `modprobe`, `pacman`, and other modules
- `ansible.posix` >= 1.5.0 — provides `mount`, `synchronize`, and POSIX utilities

---

## 7. Verification — Before You Run Anything

Work through these layers in order. Do not skip to `--check` without doing the
inventory checks first.

### Layer 1 — Inventory Parsing

Confirms Ansible can read your inventory and that hosts belong to the right
groups. Zero system interaction.

```bash
# Confirm which hosts the playbook targets
ansible-playbook ansible/site.yml --list-hosts

# Confirm which groups localhost belongs to
ansible -i ansible/inventory localhost -m debug -a "var=group_names"

# Dump ALL resolved vars for localhost — the most important check.
# Confirms group_vars inheritance is working correctly.
ansible -i ansible/inventory localhost -m debug -a "var=hostvars[inventory_hostname]"

# Spot-check critical vars individually
ansible -i ansible/inventory localhost -m debug -a "var=power_stack_profile"
ansible -i ansible/inventory localhost -m debug -a "var=hardware_vendor"
ansible -i ansible/inventory localhost -m debug -a "var=npu_enabled"
ansible -i ansible/inventory localhost -m debug -a "var=form_factor"
```

### Layer 2 — Task Listing

Shows which tasks would execute, in what order, with which tags. Confirms
`when:` guards are routing correctly. Zero system interaction.

```bash
# Full task list
ansible-playbook ansible/site.yml --list-tasks

# Tasks for a specific tag
ansible-playbook ansible/site.yml --list-tasks --tags hardware
ansible-playbook ansible/site.yml --list-tasks --tags system-services
ansible-playbook ansible/site.yml --list-tasks --tags rollback

# Tasks that would run with a power profile change
ansible-playbook ansible/site.yml --list-tasks \
  -e "power_stack_profile=tuned_asus"

# Confirm NPU tasks are skipped when npu_enabled=false
ansible-playbook ansible/site.yml --list-tasks \
  -e "npu_enabled=false"
```

### Layer 3 — Syntax Check

Catches YAML errors, undefined variables, and Jinja2 template problems.

```bash
ansible-playbook ansible/site.yml --syntax-check
```

### Layer 4 — Dry Run

Simulates execution and reports what would change. Add `--diff` to see exact
file content changes.

```bash
# Basic dry run
ansible-playbook ansible/site.yml -K --check

# Dry run with file diffs — recommended for all config changes
ansible-playbook ansible/site.yml -K --check --diff

# Dry run a single layer
ansible-playbook ansible/site.yml -K --check --diff --tags hardware
ansible-playbook ansible/site.yml -K --check --diff --tags system-services

# Dry run a power profile experiment
ansible-playbook ansible/site.yml -K --check --diff \
  -e "power_stack_profile=tuned_asus"
```

#### `--check` Limitations

`--check` is unreliable for tasks using `command:` or `shell:` modules. These
tasks report `skipped` or `ok` regardless of what would actually happen.

The following task types will **not** give you accurate dry-run output:

| Task file | Affected tasks |
|---|---|
| `hardware/tasks/amd-npu.yml` | `modprobe`, `sensors-detect`, kernel module load |
| `runtime/tasks/xrt.yml` | `xrt-smi examine`, `dnf copr enable` |
| `observability/tasks/sensors.yml` | `sensors-detect` |
| `system-services/tasks/power/asusd.yml` | `asusctl profile` |
| `system-services/tasks/power/supergfxd.yml` | `supergfxctl -g` |

Tasks using `dnf:`, `copy:`, `template:`, `systemd:`, `file:`, and `user:`
modules check accurately.

---

## 8. Running the Playbook

All playbook commands are run from the **repository root**, not from inside
`ansible/`.

```bash
# Full provisioning run
ansible-playbook ansible/site.yml -K

# Full run with diff output — recommended during active development
ansible-playbook ansible/site.yml -K --diff

# Dry run before any real change
ansible-playbook ansible/site.yml -K --check --diff
```

`-K` prompts for your sudo password (`--ask-become-pass`). Required because
most tasks write to system paths.

---

## 9. Targeting Specific Layers

```bash
# Hardware layer only (kernel modules, firmware, ASUS platform driver)
ansible-playbook ansible/site.yml -K --tags hardware --diff

# NPU kernel config only
ansible-playbook ansible/site.yml -K --tags "hardware,npu" --diff

# ASUS vendor tasks only
ansible-playbook ansible/site.yml -K --tags "hardware,vendor" --diff

# Power arbitration only (re-enforce service authority without changing profiles)
ansible-playbook ansible/site.yml -K --tags "system-services,arbitration" --diff

# tuned profile management only
ansible-playbook ansible/site.yml -K --tags "system-services,tuned" --diff

# asusd (fan + TDP) only
ansible-playbook ansible/site.yml -K --tags "system-services,asusd" --diff

# GPU switching only
ansible-playbook ansible/site.yml -K --tags "system-services,gpu" --diff

# NPU userspace runtime only
ansible-playbook ansible/site.yml -K --tags runtime --diff

# Observability only (sensors + powertop — lowest risk, good first real run)
ansible-playbook ansible/site.yml -K --tags observability --diff

# Read-only status checks — safe any time, no system changes
ansible-playbook ansible/site.yml -K --tags verify
```

---

## 10. Experimenting Safely

The `-e` flag overrides vars at the highest precedence. **Nothing is written to
disk.** Your committed `group_vars` remain unchanged. This is the correct way
to test power stack changes before committing them.

### Try asusctl fan control alongside tuned

```bash
# Dry run first
ansible-playbook ansible/site.yml -K --check --diff \
  -e "power_stack_profile=tuned_asus"

# Apply if dry run looks correct
ansible-playbook ansible/site.yml -K --diff \
  -e "power_stack_profile=tuned_asus"
```

### Try full ASUS stack with PRIME hybrid GPU

```bash
ansible-playbook ansible/site.yml -K --check --diff \
  -e "power_stack_profile=full_asus" \
  -e "gpu_mode=hybrid"

ansible-playbook ansible/site.yml -K --diff \
  -e "power_stack_profile=full_asus" \
  -e "gpu_mode=hybrid"
```

### Switch tuned profile only

```bash
ansible-playbook ansible/site.yml -K --diff \
  --tags "system-services,tuned" \
  -e "tuned_active_profile=balanced-asus"
```

### Commit a working experiment

Once you've verified a `-e` override works correctly, make it permanent by
updating `group_vars/asus_proart_p16.yml`:

```yaml
power_stack_profile: "tuned_asus"   # was: tuned_only
```

Then run without `-e` to confirm the committed value produces the same result.

---

## 11. Rollback Reference

Every role that modifies system state has a corresponding rollback task set
tagged `rollback`. Rollback tasks are gated on boolean flags passed via `-e` —
they never run accidentally.

Config files written with `backup: true` are preserved on disk as
`<filename>.bak.<timestamp>`. These are last-resort manual recovery points if
Ansible rollback is not sufficient.

### Full power stack rollback — return to known-good baseline

```bash
ansible-playbook ansible/site.yml -K --diff \
  -e "power_stack_profile=tuned_only" \
  -e "power_stack_rollback=true" \
  --tags "system-services,rollback"
```

### tuned only — restore stock balanced profile and remove custom profiles

```bash
ansible-playbook ansible/site.yml -K --diff \
  -e "tuned_rollback=true" \
  --tags "system-services,tuned,rollback"
```

### GPU — force back to integrated mode

```bash
ansible-playbook ansible/site.yml -K --diff \
  -e "power_stack_rollback=true" \
  --tags "system-services,gpu,rollback"
```

### XRT / NPU runtime — remove userspace packages and udev rules

```bash
ansible-playbook ansible/site.yml -K --diff \
  -e "xrt_rollback=true" \
  --tags "runtime,rollback"
```

### powertop auto-tune service — disable and remove systemd unit

```bash
ansible-playbook ansible/site.yml -K --diff \
  -e "powertop_rollback=true" \
  --tags "observability,powertop,rollback"
```

### Manual file recovery (last resort)

If you need to restore a config file that Ansible backed up:

```bash
# Find backups for a specific file
ls -lt /etc/tuned/balanced-asus/tuned.conf.bak.*

# Restore the most recent backup
sudo cp $(ls -t /etc/tuned/balanced-asus/tuned.conf.bak.* | head -1) \
  /etc/tuned/balanced-asus/tuned.conf

# Re-run playbook to bring system back to declared state
ansible-playbook ansible/site.yml -K --diff --tags "system-services,tuned"
```

---

## 12. Recommended First-Run Sequence

Follow this order on a fresh system. Each step confirms the previous one before
going further.

```bash
# ── Step 1: Install prerequisites ────────────────────────────────────────────
sudo dnf install ansible python3-dnf
ansible-galaxy collection install -r ansible/requirements.yml

# ── Step 2: Verify inventory resolves correctly ───────────────────────────────
ansible -i ansible/inventory localhost -m debug \
  -a "var=hostvars[inventory_hostname]"

# Confirm these values before proceeding:
#   hardware_vendor  → asus
#   power_stack_profile → tuned_only
#   npu_enabled      → true
#   form_factor      → laptop

# ── Step 3: Syntax check ──────────────────────────────────────────────────────
ansible-playbook ansible/site.yml --syntax-check

# ── Step 4: Confirm task list and guards ──────────────────────────────────────
ansible-playbook ansible/site.yml --list-tasks

# ── Step 5: Dry run with diff ─────────────────────────────────────────────────
ansible-playbook ansible/site.yml -K --check --diff

# ── Step 6: First real run — observability only (lowest risk) ─────────────────
ansible-playbook ansible/site.yml -K --diff --tags observability

# ── Step 7: Hardware layer ────────────────────────────────────────────────────
ansible-playbook ansible/site.yml -K --diff --tags hardware

# ── Step 8: Verify NPU kernel module loaded ───────────────────────────────────
ansible-playbook ansible/site.yml -K --tags "hardware,npu,verify"
# Also check manually:
lsmod | grep amdxdna
ls /dev/accel/

# ── Step 9: System services (power arbitration) ───────────────────────────────
ansible-playbook ansible/site.yml -K --diff --tags system-services

# ── Step 10: Runtime (XRT — may need COPR to have F43 builds) ────────────────
ansible-playbook ansible/site.yml -K --diff --tags runtime
ansible-playbook ansible/site.yml -K --tags "runtime,verify"

# ── Step 11: Full run ─────────────────────────────────────────────────────────
ansible-playbook ansible/site.yml -K --diff
```

> **Note on XRT / Fedora 43:** The `amdxrt/xrt` COPR may lag new Fedora
> releases by several weeks. If XRT packages are not yet available, Step 10
> will warn but not fail. The hardware layer (kernel module + firmware) is
> independent and will apply cleanly regardless.

---

*This document tracks the RaBbLE-OS Ansible configuration as described in
`ansible/site.yml`, `ansible/inventory/`, and the role structure under
`ansible/roles/`. Update this file when roles, tags, or var structure change.*
