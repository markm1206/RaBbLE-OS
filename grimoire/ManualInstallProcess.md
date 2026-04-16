# ManualInstallProcess.md — Validated Bootstrap from Clean Base

```
transcribe ~ grimoire >> manual process crystallized // %INSTALL_PROCESS_LOCKED%
```

> This document records the manual bootstrap process as validated on a real install
> (2026-04-13, ASUS ProArt P16 H7606WV, Fedora 43 KDE spin).
> It is the ground truth for what actually works — not what should work in theory.
>
> Use this alongside `GettingStarted.md`. Where they conflict, this document wins.
> When the bootstrap script is mature enough to replace this process, this doc
> becomes the acceptance test for the script.

---

## Starting Conditions

- Fresh Fedora 43 KDE spin install
- User: `rabble`
- System fully updated before any RaBbLE work begins
- Internet access on port 443 (public WiFi may block port 22 — SSH configured accordingly)

---

## Step 1 — System Update

Before touching anything, update the full system and reboot:

```bash
sudo dnf upgrade --refresh -y
sudo reboot
```

Do not skip this. Installing Ansible or running roles against a partially stale system
introduces unnecessary variables.

---

## Step 2 — SSH Key Setup (if using SSH git)

Public WiFi often blocks port 22. Configure SSH to use port 443 as fallback:

```bash
# ~/.ssh/config
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
```

Generate and register a key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add the public key to GitHub → Settings → SSH Keys
```

---

## Step 3 — Install Git and Clone

```bash
sudo dnf install git -y

git clone git@github.com:markm1206/RaBbLE-OS.git ~/RaBbLE-OS
cd ~/RaBbLE-OS
```

---

## Step 4 — Install Ansible

The bootstrap script provides an Ansible install option. Or install manually:

```bash
sudo dnf install pipx -y
pipx install --include-deps ansible
pipx ensurepath
source ~/.bashrc
```

**`--include-deps` is required.** Without it, Ansible installs without dependent packages
and certain modules fail silently. Do not use `ansible-core` alone — use the full `ansible`
package via pipx.

Install the required Ansible collections:

```bash
ansible-galaxy collection install community.general
```

Verify:

```bash
ansible --version
# Should show ansible 2.x or later, not ansible-core
```

---

## Step 5 — Prepare the Branch

Create a working branch before making any changes to the playbook:

```bash
git checkout -b phase/1-daily-driver
# or feature/clean-ansible-setup — whatever fits the work
```

Slim `site.yml` and `inventory/group_vars/all.yml` to only what you explicitly need right now.
Do not carry forward roles you haven't verified. Add them back as you validate them.

---

## Step 6 — Run Core Role

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags core
```

Verify:
- RPM Fusion repos enabled (`dnf repolist | grep rpmfusion`)
- Locale set (`localectl status` should show `en_US.UTF-8`)
- User in required groups (`groups $USER` should include wheel, audio, video, input, render)
- fstrim.timer active (`systemctl status fstrim.timer`)

---

## Step 7 — Run Hardware Role

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags hardware
```

**Reboot after this step.** The akmod-nvidia build completes on reboot, and nouveau must
be unloaded before the NVIDIA driver can take effect.

```bash
sudo reboot
```

Post-reboot verify:
```bash
lsmod | grep nvidia        # nvidia, nvidia_drm, nvidia_modeset should be present
supergfxctl --status       # should show Hybrid
asusctl profile -l         # should list power profiles
```

---

## Step 8 — Run UI/UX Role (Hyprland)

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags ui_ux
```

This installs Hyprland from the lionheartp COPR, all Wayland utilities, and symlinks
configs from `config/` into `~/.config/`.

**Hyprland config note — v0.54 breaking change:**

If your config uses `windowrulev2`, it will fail to parse on v0.54. The directive was
removed and unified into `windowrule`. Temporarily disable the affected files to get
a bootable session:

```bash
# In config/hyprland/hyprland.conf, comment out or remove includes for:
# - windowrules.conf
# - workspaces.conf
# Then migrate the syntax:
# windowrulev2 = rule, class:^(app)$  →  windowrule = rule, class:^(app)$
```

Verify Hyprland is launchable from SDDM before proceeding.

---

## Step 9 — Log Into Hyprland

Log out of KDE. Select **Hyprland** from the SDDM session list.

If Hyprland fails to launch:

```bash
# Drop to TTY: Ctrl+Alt+F2
# Check for config syntax errors:
hyprland --config ~/.config/hypr/hyprland.conf 2>&1 | head -40
# Fix the reported error, retry
```

Once inside Hyprland, verify:

```bash
hyprctl version       # should show v0.54+
hyprctl monitors      # should show eDP-1 at 3840x2400
```

---

## Step 10 — Run Dev Tools Role

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags dev-tools
```

---

## Step 11 — Purge KDE (Optional)

KDE is useful as a fallback session while Hyprland is being stabilised. Once Hyprland
is confirmed working, purge it:

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/site.yml -K --tags purge-kde
sudo reboot
```

After reboot, SDDM will only show Hyprland as a session option. If Hyprland fails
to start, TTY recovery is the only path.

> ⚠️ Do not purge KDE until you are confident Hyprland is stable. The reinstall cost
> is a full Fedora install + this entire process again.

---

## Ongoing Workflow

### Editing configs

All configs live in `config/` in the repo and are symlinked to `~/.config/`. Edit the
repo file — the symlink means the change is live immediately:

```bash
$EDITOR ~/RaBbLE-OS/config/hyprland/conf.d/keybinds.conf
hyprctl reload    # live reload — no logout needed
```

### Re-linking configs after a role run

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/deploy-config.yml -K
```

If symlinks are reported as created but don't appear, run it twice — there is an
intermittent idempotency issue with the `file` module.

### Committing changes

Follow the Pulse Protocol from `CommitStyle.md`:

```bash
git add config/
git commit -m "transcribe ~ hyprland >> migrated windowrulev2 to windowrule // %CONFIG_EVOLVED%"
```

---

## Known Friction Points (Validated)

These are things that tripped up the real install — not theoretical risks:

| Step | Issue | Resolution |
|---|---|---|
| Ansible install | `ansible-core` alone missing modules | Use `pipx install --include-deps ansible` |
| Hyprland v0.54 | `windowrulev2` parse failure — black screen | Disable affected conf files; migrate syntax |
| Hyprland config | GPU env vars in wrong file can break login | Keep `AQ_DRM_DEVICES` etc. in `machine.conf` only |
| Config symlinks | Intermittent — reported success but not created | Run deploy-config twice; verify manually |
| KDE purge timing | Purging before Hyprland is stable = TTY-only recovery | Confirm Hyprland stable first |
| SSH on public WiFi | Port 22 blocked | Configure `~/.ssh/config` to use port 443 |

---

## Recovery

**Hyprland won't start, KDE still installed:**
- Select KDE Plasma from SDDM session list
- Fix the Hyprland config issue
- Retry

**Hyprland won't start, KDE purged:**
- TTY: `Ctrl+Alt+F2`
- Fix config, re-run deploy-config, retry

**Complete reinstall required:**
- Fresh Fedora 43 KDE spin install
- Follow this document from Step 1
- With clean Ansible roles, recovery from reinstall to working Hyprland session
  takes approximately 30-60 minutes

---

```
transcribe ~ grimoire >> manual process crystallized // %INSTALL_PROCESS_LOCKED%
```
