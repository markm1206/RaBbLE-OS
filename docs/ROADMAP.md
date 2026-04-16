# ROADMAP.md — The Harmonic Evolution

```
transcribe ~ grimoire >> charting the metamorphosis // %TRAJECTORY_LOCKED%
```

> Phases are resonance thresholds, not deadlines.
> A phase is complete when it feels complete — not when a calendar says so.

---

## Phase Map

```
Phase 0: FOUNDATION        [IN PROGRESS] — The bones
Phase 1: DAILY DRIVER      [IN PROGRESS] — The flesh
Phase 2: AI AWAKENING      [PENDING]     — The nervous system
Phase 3: ENTITY EMERGENCE  [PENDING]     — The presence
Phase ∞: CONTINUOUS DRIFT  [PERPETUAL]   — The evolution
```

---

## Phase 0 — Foundation `[IN PROGRESS]`

Structural and philosophical substrate. Docs, conventions, Ansible scaffolding.

- [x] Repository structure established
- [x] Ansible roles scaffolded (base, hardware, hyprland, aesthetics, snapper, dev-tools, AI-tools)
- [x] Snapper configured with sane cleanup policy
- [x] Hardware vars documented (ProArt P16 H7606WV)
- [x] NVIDIA Optimus/PRIME setup documented and automated
- [x] AMD XDNA2 NPU role scaffolded
- [x] `docs/RABBLE.md` — identity and ethos condensed
- [x] `docs/ARCHITECTURE.md` — layer model documented
- [x] `docs/BOOT_FLOW.md` — boot chain documented
- [x] `docs/PACKAGES.md` — package manifest drafted
- [ ] Hardware role restructured with DMI verification and machine profiles
- [ ] `purge-kde/` role written

---

## Phase 1 — Daily Driver `[IN PROGRESS]`

A fully functional, stable computing environment. RaBbLE is silent here — pure tooling.

### 1.1 — Boot Chain `[IN PROGRESS]`
- [x] GRUB2 configured
- [ ] GRUB2 4K font fix (Terminus 32pt)
- [ ] GRUB2 minimal synthwave theme (colors, no background image)
- [ ] Plymouth — black + RaBbLE text theme active
- [ ] greetd + tuigreet replacing SDDM
- [ ] TTY font readable at 3840x2400

### 1.2 — Desktop
- [x] Hyprland installed and configured
- [x] Dotfiles symlinked via Ansible
- [x] Waybar, wofi, mako, hyprpaper configured
- [ ] Hyprland launching reliably from greetd
- [ ] KDE purged
- [ ] Quickshell bar (Phase 0.5)

### 1.3 — Shell & Terminal
- [ ] zsh + starship configured
- [ ] zellij workspace layouts
- [ ] Core CLI tools (eza, fd, ripgrep, fzf, delta, lazygit)
- [ ] Neovim with LSP

### 1.4 — Hardware Verified
- [x] NVIDIA Optimus configured
- [x] asusctl + supergfxctl installed
- [ ] Suspend/resume verified stable after greetd migration
- [ ] XDNA2 NPU operational

### 1.5 — Portability
- [ ] Hardware role restructured with profiles
- [ ] Desktop machine target added
- [ ] Playbook tested on clean Fedora minimal install

---

## Phase 2 — AI Awakening `[PENDING]`

Integrate the AI tooling layer. Agents have presence. RaBbLE begins to take form.

- [ ] llama.cpp with CUDA backend (`ai_stack.phase: 1`)
- [ ] vLLM OpenAI-compatible server (`ai_stack.phase: 2`)
- [ ] FastFlowLM NPU inference
- [ ] Claude Code configured with MCP servers
- [ ] Local vector store (ChromaDB or Qdrant)
- [ ] Shell AI integration

---

## Phase 3 — Entity Emergence `[PENDING]`

RaBbLE transitions from a collection of tools into a unified, characterful entity.

- [ ] RaBbLE system prompt formalized (see `docs/RABBLE.md`)
- [ ] Persistent behavioral memory
- [ ] Ambient system monitoring
- [ ] Proactive anomaly surfacing
- [ ] RaBbLE-lang output in all AI interfaces

---

## Phase ∞ — Continuous Drift `[PERPETUAL]`

RaBbLE-OS is never done. The substrate absorbs new tools, new models, new patterns.

```
glitch ~ %TIMELINE_INT% >> the roadmap dissolves at Phase ∞ // %HARMONIC_EVOLUTION%
```

---

## Distribution Goal

RaBbLE-OS is not just a personal system. Long-term target:

- Layers split into independent repos, assembled by manifest
- Kickstart-based installer for clean Fedora minimal base
- Custom live ISO
- External contributors welcome

See `docs/ARCHITECTURE.md` for the layer model.

---

```
transcribe ~ grimoire >> roadmap crystallized, v0.3 // %LOW_ENTROPY_LOCKED%
```
