# dotfiles/shell/bash/.bashrc
# =============================================================================
# RaBbLE — Bash interactive shell config (portable fallback)
# =============================================================================

# Not interactive? Return immediately.
[[ $- != *i* ]] && return

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE="${HOME}/.local/state/bash/history"
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
mkdir -p "$(dirname "$HISTFILE")"

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar
shopt -s cmdhist

# ── Completion ────────────────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

# ── Aliases ───────────────────────────────────────────────────────────────────
[[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"

# ── Starship prompt ───────────────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
else
    # Fallback minimal RaBbLE prompt
    _rabble_prompt() {
        local reset='\[\033[0m\]'
        local violet='\[\033[38;5;135m\]'
        local teal='\[\033[38;5;80m\]'
        local muted='\[\033[38;5;245m\]'
        local red='\[\033[0;31m\]'

        local exit_code=$?
        local char
        if (( exit_code == 0 )); then
            char="${teal}❯${reset}"
        else
            char="${red}❯${reset} ${red}[${exit_code}]${reset}"
        fi

        local git_branch=""
        if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
            local branch; branch=$(git symbolic-ref --short HEAD 2>/dev/null)
            [[ -n "$branch" ]] && git_branch=" ${muted}on ${violet}${branch}${reset}"
        fi

        PS1="\n${violet}\w${reset}${git_branch}\n ${char} "
    }
    PROMPT_COMMAND='_rabble_prompt'
fi

# ── fzf ───────────────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_OPTS="
        --color=fg:#e8e6f0,fg+:#e8e6f0,bg:#0d0f1a,bg+:#1a1b2e
        --color=hl:#7c6fe0,hl+:#9d8ff0,info:#4ecdc4,marker:#f7a8d4
        --color=prompt:#7c6fe0,spinner:#4ecdc4,pointer:#f7a8d4,header:#6b6880
        --color=border:#2a2840,gutter:#0d0f1a
        --border rounded --prompt '  ' --pointer '' --marker ''
        --layout reverse --height 60%"
fi

# ── zoxide ────────────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash --cmd cd)"
fi

# ── direnv ────────────────────────────────────────────────────────────────────
if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi
