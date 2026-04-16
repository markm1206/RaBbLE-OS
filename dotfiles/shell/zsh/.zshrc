# =============================================================================
# RaBbLE — ~/.config/zsh/.zshrc
# Loaded by: ZDOTDIR (set in ~/.zshenv → export ZDOTDIR="$HOME/.config/zsh")
# =============================================================================

# ── Instant prompt (p10k — must be near top) ──────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Zinit plugin manager ───────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit && (( ${+_comps} )) && _comps[zinit]=_zinit

# ── Prompt: Powerlevel10k ──────────────────────────────────────────────────────
zinit ice depth=1; zinit light romkatv/powerlevel10k

# ── Essential plugins ──────────────────────────────────────────────────────────
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    blockf \
        zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions

# ── fzf-tab (replaces default completion menu) ────────────────────────────────
zinit light Aloxaf/fzf-tab

# ── Useful extras ─────────────────────────────────────────────────────────────
zinit wait lucid for \
    MichaelAquilina/zsh-you-should-use \
    hlissner/zsh-autopair \
    zsh-users/zsh-history-substring-search

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
mkdir -p "$(dirname $HISTFILE)"

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# ── Completion ────────────────────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always --group-directories-first $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# ── Key bindings ──────────────────────────────────────────────────────────────
bindkey -e   # emacs-style (Ctrl+A/E, etc.)
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ── Shell options ─────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt GLOB_DOTS
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt CORRECT
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# ── Source aliases and functions ──────────────────────────────────────────────
[[ -f "${ZDOTDIR}/aliases.zsh"   ]] && source "${ZDOTDIR}/aliases.zsh"
[[ -f "${ZDOTDIR}/functions.zsh" ]] && source "${ZDOTDIR}/functions.zsh"

# ── Tool integrations ─────────────────────────────────────────────────────────
# fzf
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
    export FZF_DEFAULT_OPTS="
        --color=fg:#e8e6f0,fg+:#e8e6f0,bg:#0d0f1a,bg+:#1a1b2e
        --color=hl:#7c6fe0,hl+:#9d8ff0,info:#4ecdc4,marker:#f7a8d4
        --color=prompt:#7c6fe0,spinner:#4ecdc4,pointer:#f7a8d4,header:#6b6880
        --color=border:#2a2840,gutter:#0d0f1a
        --border rounded --prompt '  ' --pointer '' --marker ''
        --layout reverse --height 60% --info inline"
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# zoxide (smarter cd)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# direnv
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# ── Powerlevel10k config ───────────────────────────────────────────────────────
[[ -f "${ZDOTDIR}/p10k.zsh" ]] && source "${ZDOTDIR}/p10k.zsh"
