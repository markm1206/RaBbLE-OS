# p10k.zsh — RaBbLE-OS Powerlevel10k prompt configuration
# Mirrors the Bash prompt exactly:
#   Line 1: ╭─ ~/path on branch
#   Line 2: ╰─ ❯ 
# Colors: 97=dim, 135=violet, 51=cyan, 198=magenta, 160=red

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
    emulate -L zsh -o extended_glob

    unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

    autoload -Uz is-at-least && is-at-least 5.1 || return

    # ── Prompt elements ────────────────────────────────────────────────
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        dir
        vcs
        context
        virtualenv
        newline
        prompt_char
    )

    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        status
        command_execution_time
        background_jobs
        direnv
        asdf
        virtualenv
    )

    # ── Common — transparent backgrounds ──────────────────────────────
    typeset -g POWERLEVEL9K_MODE=nerdfont-complete
    typeset -g POWERLEVEL9K_ICON_PADDING=none
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=238
    typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%F{97}╭─%f '
    typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
    typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=
    typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
    typeset -g POWERLEVEL9K_BACKGROUND=

    # ── Prompt char ───────────────────────────────────────────────────
    typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%F{97}╰─%f '
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=198  # magenta
    typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=160  # red
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
    typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

    # ── Dir — violet ──────────────────────────────────────────────────
    typeset -g POWERLEVEL9K_DIR_BACKGROUND=
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=135               # violet
    typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=   # hide folder icon
    typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=97      # muted violet
    typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=135
    typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
    typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
    typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
    typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40
    typeset -g POWERLEVEL9K_DIR_HOME_SYMBOL='~'
    typeset -g POWERLEVEL9K_DIR_PREFIX=
    typeset -g POWERLEVEL9K_DIR_SUFFIX=

    # ── VCS (git) — show "on branch" ──────────────────────────────
    typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='%F{97}on%f %F{51}'
    typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
    typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=
    typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=51          # cyan — clean
    typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=
    typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=51       # cyan
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=51      # cyan
    typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=
    typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=160    # red — conflict
    typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=
    typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=97
    # Suppress VCS status icons
    typeset -g POWERLEVEL9K_VCS_STAGED_ICON=
    typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON=
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON=
    typeset -g POWERLEVEL9K_VCS_CONFLICTED_ICON=
    typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_ICON=
    typeset -g POWERLEVEL9K_VCS_COMMITS_BEHIND_ICON=

    # ── Status ────────────────────────────────────────────────────────
    typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
    typeset -g POWERLEVEL9K_STATUS_OK=false
    typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=84          # green
    typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=
    typeset -g POWERLEVEL9K_STATUS_ERROR=true
    typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160      # red
    typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=
    typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=198
    typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_BACKGROUND=
    typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false

    # ── Command execution time ─────────────────────────────────────────
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=97  # muted
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

    # ── Python virtualenv ─────────────────────────────────────────────
    typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=
    typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=51         # cyan
    typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
    typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

    # ── Context (user@host — SSH and root only) ───────────────────────
    typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%F{160}root@%m%f%b'
    typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%F{97}%n%f@%F{135}%m%f'
    typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%F{97}%n%f@%F{135}%m%f'
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=

    # ── Background jobs ───────────────────────────────────────────────
    typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
    typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_EXPANSION='⇶'
    typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=
    typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=84    # green

    # ── Instant prompt ────────────────────────────────────────────────
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

    (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
