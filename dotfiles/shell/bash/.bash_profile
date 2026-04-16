# dotfiles/shell/bash/.bash_profile
# Login shell — sources .bashrc and sets PATH

# Load .bashrc for interactive settings
[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

# ── XDG ───────────────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${HOME}/.go/bin:/usr/local/bin:${PATH}"

# ── Defaults ──────────────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-RFX"
export GPG_TTY="$(tty)"
