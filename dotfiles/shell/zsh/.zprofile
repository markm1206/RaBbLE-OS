# dotfiles/shell/zsh/.zprofile
# Sourced for login shells — set PATH and session-level env vars here.

# ── XDG ───────────────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"

# ── PATH ──────────────────────────────────────────────────────────────────────
path=(
    "${HOME}/.local/bin"
    "${HOME}/.cargo/bin"
    "${HOME}/.go/bin"
    /usr/local/bin
    $path
)
export PATH

# ── Default tools ─────────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-RFX"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── GPG ───────────────────────────────────────────────────────────────────────
export GPG_TTY="$(tty)"
