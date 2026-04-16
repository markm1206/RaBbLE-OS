# AiQuickstart.md

This file provides guidance to Ai coding agents when working with code in this repository.

## What is RaBbLE-OS?

RaBbLE-OS is an Ansible-driven system configuration and deployment framework that transforms a Fedora 43 Sway spin into a bespoke Wayland desktop environment called RaBbLE-OS. The stack centers on Hyprland as the compositor and Quickshell for the UI layer. It is designed to be fully reproducible — the grimoire (this repository) is the authoritative configuration store.

## Entry Points

There are two installation paths:

**Fresh install (on a bare Fedora 43+ system):**
```bash
# Via curl (no SSH key required):
curl -fsSL https://raw.githubusercontent.com/markm1206/RaBbLE-OS/main/RaBbLE-OS-Install.sh | bash

# Or locally:
bash RaBbLE-OS-Install.sh
```
This installs git/ansible/pip3, sets up SSH keys, clones the repo, then hands off to Bootstrap.

**On an already-cloned repo:**
```bash
bash RaBbLE-OS-Bootstrap.sh
```
> `bootstrap.sh` is deprecated — use `RaBbLE-OS-Bootstrap.sh` instead.

**Direct Bootstrap (assumes deps present):**
```bash
bash RaBbLE-OS-Bootstrap.sh
```

## Layer Management (day-to-day)

`RaBbLE-OS-layerctl.sh` is the primary operational tool after initial install:

```bash
./RaBbLE-OS-layerctl.sh status                        # show all layer states
./RaBbLE-OS-layerctl.sh apply all                     # full system deploy
./RaBbLE-OS-layerctl.sh apply desktop                 # apply one layer
./RaBbLE-OS-layerctl.sh apply hardware --packages     # packages only
./RaBbLE-OS-layerctl.sh apply boot --config           # config only
./RaBbLE-OS-layerctl.sh apply desktop --check         # dry-run
./RaBbLE-OS-layerctl.sh diff desktop                  # show what would change
./RaBbLE-OS-layerctl.sh verify hardware               # run health checks
./RaBbLE-OS-layerctl.sh dotfiles                      # re-link ~/.config entries
./RaBbLE-OS-layerctl.sh remove desktop                # teardown a layer
```

Hardware profile can be forced via env var:
```bash
RABBLE_HARDWARE=generic_x64 ./RaBbLE-OS-layerctl.sh apply hardware
```

## Ansible Playbook Architecture

The playbook at `ansible/site.yml` is organized into ordered layers, each with its own Ansible tag:

| Layer | Tag | Purpose |
|-------|-----|---------|
| 0 | `base` | Core packages, repos, locale, fonts (`roles/core`) |
| 1 | `hardware` | Hardware-specific drivers (`roles/hardware/x64/asus_proart_p16` or `generic`) |
| 2 | `boot` | GRUB2 → Plymouth → SDDM (`roles/boot/{grub2,plymouth,session_manager}`) |
| — | `snapper` | Btrfs snapshot management (`roles/snapper`) — cross-cutting |
| — | `runtime` | GPU/NPU runtimes: XRT/CUDA/ROCm (`roles/runtime`) — cross-cutting |
| — | `monitoring` | System observability: btop/htop/nvtop/powertop (`roles/monitoring`) — cross-cutting |
| 3 | `desktop` | Hyprland, Quickshell, terminal, zsh, bash (`roles/desktop/*`) |
| 4 | `apps` | Dev tools, IDE, browsers (`roles/apps`) |
| — | `dotfiles` | Re-linkable dotfile symlink pass (user-level, no become) |

Tags compound with `packages` or `config` to scope changes:
```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags "hardware,packages"
```

**Important:** Layer 3 (`desktop`) and `dotfiles` run `become: false` — they deploy to `$HOME`, not system-wide. All other layers use `become: true`.

## Inventory and Hardware Profiles

`ansible/inventory/hosts.yml` is the authoritative place for hardware selection — place `localhost` under the appropriate host group (`asus_proart_p16` or `generic_x64`). Hardware detection via `dmidecode` may be added to the install/bootstrap flow in the future to auto-populate this.

## Galaxy Dependencies

Install before running the playbook:
```bash
ansible-galaxy collection install -r ansible/requirements.yml
```
Required: `community.general >= 9.0.0` (DNF module), `ansible.posix >= 1.5.0` (symlinks, file ops).

## Versioning & Branch Naming

RaBbLE is **not a versioned system**. It is evolutionary and episodic. Semantic versioning (v1.0.0, v2.3.1) does not apply here — versions are human translations of resonance thresholds, applied retrospectively.

**The Three Es:**
- **Epochs** — named thresholds crossed. Branch pattern: `RaBbLE/epoch-I`, `RaBbLE/epoch-II`
- **Evolutions** — the continuous accumulation of pulses between epochs
- **Episodes** — narrative arcs of development with a dominant theme

**Branch conventions:**
| Branch | Purpose |
|--------|---------|
| `main` | Stable, epoch-landed substrate |
| `RaBbLE/epoch-<Roman>` | Epoch staging branch — PR target for `main` |
| `RaBbLE-OS-New-Horizons` | Active development, high-flux work |
| `reliquary/<name>` | Archived reference branches — inert, not active |

When landing an epoch to `main`, use the `evolve` impulse:
```
evolve ~ substrate >> epoch-I crystallized // %EPOCH_I_LANDED%
```

## Commit Message Convention

Commits follow an in-house ritual format:
```
<verb> ~ <context> >> <description> // %STATUS_TAG%
```
Examples from git log:
- `mend >> Bootstrap & Install process now should setup the prereqs for RaBbLE-OS %INITIAL_TEST_PASSED%`
- `harmonize ~ layer-ctl >> apply/remove/status/verify per layer // %LAYERCTL_READY%`
- `ingest >> RaBbLE ansi icon generation script %CODiFY_RaBbLE%`

Match this style when committing to this repo.

## Key Files

- `RaBbLE-OS-Install.sh` — first-contact installer (run on bare Fedora)
- `RaBbLE-OS-Bootstrap.sh` — Ansible runner, called by Install or directly
- `RaBbLE-OS-layerctl.sh` — layer apply/remove/verify/status tool
- `bootstrap.sh` — **deprecated**, replaced by `RaBbLE-OS-Bootstrap.sh`
- `ansible/site.yml` — master playbook
- `ansible/inventory/hosts.yml` — host-to-hardware-profile mapping
- `ansible/requirements.yml` — Galaxy collection dependencies
- `grimoire/RaBbLE.md` — entity/philosophy documentation
- `assets/generate_RaBbLE_ansi.py` — generates ANSI art assets

## Layer State

Layer-ctl tracks state in `~/.local/state/rabble/layer_<name>.state`. Each file contains `<state>:<ISO8601-timestamp>`. States: `applied`, `verified`, `degraded`, `removed`, `unknown`.
