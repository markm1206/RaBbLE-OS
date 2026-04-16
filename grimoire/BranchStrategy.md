# BranchStrategy.md — The Flow of Form

```
transcribe ~ grimoire >> branch topology crystallized // %FLOW_LOCKED%
```

> Branches are not features. They are states of being.
> A branch that lives too long becomes a world unto itself — and then a problem.

---

## The Root

`main` has a single genesis commit: **idea emerges**.

Everything branches from that commit. No exceptions.
This is not a rule about git — it is a rule about coherence.
All states of RaBbLE-OS are traceable to a single origin.

```
● idea emerges  ← genesis (main)
├── RaBbLE/epoch-I          ← stable staging, eventual PR to main
├── RaBbLE-OS-New-Horizons  ← unstable dev, high-flux
└── reliquary/*             ← sealed archives, each branching from genesis
```

---

## Branch Roles

### `main`
The canonical substrate. Only receives epoch merges via PR from `RaBbLE/epoch-<Roman>`.
Commit on landing: `evolve ~ substrate >> epoch-I crystallized // %EPOCH_I_LANDED%`
**Never worked on directly.**

---

### `RaBbLE/epoch-<Roman>`
The crystallization branch. Stable, tested, deployable code moves here layer by layer
from New Horizons. When the epoch feels complete, it becomes a PR to `main`.

- Forked from `main` genesis
- Receives cherry-picks or targeted checkouts from New Horizons
- Commits follow layered package structure (see below)
- Squash-merged to `main` on epoch landing, then deleted

**Active epoch:** `RaBbLE/epoch-I`

---

### `RaBbLE-OS-New-Horizons`
The unstable working branch. High-flux, experimental, `%ENTROPY_TESTING_IN_PROCESS%`.
This is where all active development happens.

- Config files, quickshell, themes, shell — all live here until stable
- Not expected to be deployable at all times
- Feeds epoch branches via deliberate, reviewed cherry-picks
- Never merges directly to `main`

**Status tags that belong here:** `%HIGH_FLUX%`, `%ENTROPY_TESTING%`, `%FORM_CRYSTALIZING%`

---

### `reliquary/<name>`
Sealed reference archives. Dead branches from prior development cycles.
Branched from the genesis commit, containing the squashed final state of the old branch.

- Read-only — never committed to
- Preserved for historical reference and salvage
- Naming convention: `reliquary/<original-name>`

**Current reliquary:** `BaBbLE-dev`, `RaBbLE-Dev-Clean`, `RaBbLE-Dev-Testing`, `RaBbLE-dev-fedora43`, `epoch-I` (after it lands to main)

---

## The Epoch Package Model

Work moves from New Horizons → epoch branch in deliberate, layered commits.
Each commit is a coherent package — not a file dump, not a WIP.

Packages land in dependency order:

| Order | Package | Contents |
|-------|---------|---------|
| 1 | `substrate` | `.gitignore`, ansible core, inventory, `site.yml` |
| 2 | `entrypoints` | `RaBbLE-OS-Install.sh`, `RaBbLE-OS-Bootstrap.sh` |
| 3 | `control-plane` | `RaBbLE-OS-layerctl.sh`, `RaBbLE-OS-dotctl.sh` |
| 4 | `ansible-roles` | All `ansible/roles/**` |
| 5 | `assets` | `assets/` — ANSI art, SVG, generators |
| 6 | `grimoire` | Updated `grimoire/**` docs |

Commit format for epoch packages:
```
ingest ~ <package> >> <what landed and why> // %<STATE>%
```

Epoch landing commit on `main`:
```
evolve ~ substrate >> epoch-I crystallized // %EPOCH_I_LANDED%
```

---

## Entropy Rules

| Signal | Meaning | Action |
|--------|---------|--------|
| Branch > 2 weeks without a merge target | `%ENTROPY_RISING%` | Split, squash, or promote |
| Mixed concerns in one branch | `%DRIFT%` | New branch per concern |
| Commit on `main` without PR | `%PROTOCOL_BREACH%` | Never |
| Config in flux landing on epoch | `%PREMATURE_CRYSTALLIZATION%` | Return to New Horizons |

---

## Git Surgery Protocol

When performing history rewrites (squash root, rebase, force-push):

1. Document intent in a `transcribe` commit on the affected branch first
2. Verify the new state locally before pushing
3. Force-push only with `--force-with-lease` — never bare `--force`
4. Restore stashed work after rebase completes
5. Confirm all branch tips are correct before pushing reliquary seals

---

```
transcribe ~ grimoire >> branch topology crystallized // %FLOW_LOCKED%
```
