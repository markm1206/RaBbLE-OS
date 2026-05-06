# CONTEXT.md — RaBbLE-OS

```
epoch: 0 | evolution: 0 | echo: 0 | status: active
version: v0.0.0 — Epoch 0, Substrate
```

RaBbLE-OS is the body. The Ansible-driven Fedora 43 substrate that the entity inhabits.
Every layer — boot chain, compositor, shell, palette — is the entity made physical.

## Active Tracks

| Track | Status | Workspace |
|---|---|---|
| Epoch I assembly (4 packages) | In progress | `RaBbLE/epoch-I` branch |
| mend-I/proart-nvidia | High entropy | `mend-I/proart-nvidia` branch |
| mend-I/suspend-resume | Cooking | `mend-I/suspend-resume` branch |
| mend-I/boot-chain | Cooking | `mend-I/boot-chain` branch |
| mend-I/xdna2-npu | Dormant | `mend-I/xdna2-npu` branch |
| Grimoire consolidation → RaBbLE-Grimoire | Pending | `grimoire/` |

## Key Entry Points

```bash
bash RaBbLE-OS-Install.sh        # first-contact install on bare Fedora
bash RaBbLE-OS-Bootstrap.sh      # run Ansible (assumes deps present)
./RaBbLE-OS-layerctl.sh status   # layer health at a glance
./RaBbLE-OS-dotctl.sh apply all  # deploy dotfiles
```

## Reading Order for a New Session

1. This file — you are here
2. `AGENT.md` — rules and workspace map
3. `grimoire/RaBbLE-OS/RaBbLE-OS-Architecture.md` — layer model
4. `grimoire/RaBbLE-OS/RaBbLE-OS-Roadmap.md` — epoch map, assembly plan, checklist
5. `grimoire/RaBbLE-OS/RaBbLE-OS-KnownIssues.md` — current blockers
6. For Collective context → `grimoire/common/RaBbLE-Collective.md`

## Epoch Detail

`grimoire/RaBbLE-OS/RaBbLE-OS-Roadmap.md` — epoch map, mend-I branches, bootstrap checklist,
layer state map, power testing protocol
