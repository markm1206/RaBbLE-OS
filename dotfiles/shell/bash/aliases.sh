#!/usr/bin/env bash
# dotfiles/shell/bash/aliases.sh
# Symlinked to ~/.bash_aliases — sourced from .bashrc
# Kept in sync with dotfiles/shell/zsh/aliases.zsh

# ── Navigation ────────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# ── eza (ls replacement) ──────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first --color=auto'
    alias ll='eza --icons --group-directories-first -lah --git'
    alias lt='eza --icons --tree --level=2'
    alias lta='eza --icons --tree --level=3 -a'
else
    alias ls='ls --color=auto'
    alias ll='ls -lahF'
fi

# ── bat ───────────────────────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
fi

# ── Grep ──────────────────────────────────────────────────────────────────────
alias grep='grep --color=auto'

# ── Git ───────────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gcb='git checkout -b'

# ── System ────────────────────────────────────────────────────────────────────
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias top='btop'
alias vim='nvim'
alias v='nvim'
alias py='python3'
alias pip='pip3'

# ── RaBbLE ────────────────────────────────────────────────────────────────────
alias rabble='cd ~/git/RaBbLE && ./bootstrap.sh'
alias hypr-reload='hyprctl reload'
alias qs-restart='pkill quickshell; sleep 0.5; quickshell &'

# ── DNF ───────────────────────────────────────────────────────────────────────
alias dnfi='sudo dnf install'
alias dnfr='sudo dnf remove'
alias dnfu='sudo dnf upgrade'
alias dnfs='dnf search'

# ── Wayland ───────────────────────────────────────────────────────────────────
alias ss='~/.config/hypr/scripts/screenshot.sh region'
alias ssf='~/.config/hypr/scripts/screenshot.sh full'

# ── Misc ──────────────────────────────────────────────────────────────────────
alias cls='clear'
alias reload='exec $SHELL'
alias path='echo $PATH | tr ":" "\n"'
alias ip='ip --color=auto'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias weather='curl -s wttr.in/?format=3'
