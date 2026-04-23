# ShellGuide.md — RaBbLE-OS Shell & Desktop Reference

```
transcribe ~ grimoire >> shell and desktop user guide // %STABLE%
```

> This document describes what RaBbLE-OS provides out of the box in the shell
> and desktop environment. Everything listed here is deployed via dotctl.

---

## Shells

RaBbLE-OS configures both ZSH (default) and Bash with a consistent experience:
parallel prompt design, shared aliases, shared color environment, and sane
history defaults. ZDOTDIR is set so ZSH reads all config from `~/.config/zsh/`.

---

## ZSH

### Prompt (Powerlevel10k)

Two-line layout:

```
╭─ ~/path/to/dir  branch
╰─ ❯
```

| Element | Color | Meaning |
|---------|-------|---------|
| Directory path | violet | current working directory |
| Branch name | cyan | git branch (clean) / yellow (modified) / magenta (untracked) |
| `❯` | magenta | ready (green on success, red on error) |
| Exit code | red | shown on right when non-zero |
| Exec time | muted | shown on right when command took > 3s |

Prompt only shows `user@host` when connected via SSH or running as root.

### History

- 50,000 entries, persisted to `~/.config/zsh/.zsh_history`
- Shared across all open sessions in real time (`SHARE_HISTORY`)
- Timestamps stored (`EXTENDED_HISTORY`)
- Duplicates removed automatically
- Lines starting with a space are not saved
- Up/down arrows search history by prefix (type a partial command, then ↑)

### Completion

- Case-insensitive tab completion
- Menu-select (arrow-navigate through options)
- Colored output using LS_COLORS (RaBbLE palette)
- Cached for speed

### Key Bindings (emacs mode)

| Key | Action |
|-----|--------|
| `Ctrl+A` | beginning of line |
| `Ctrl+E` | end of line |
| `Ctrl+W` | delete word backward |
| `Ctrl+R` | reverse history search |
| `Ctrl+U` | kill line |
| `↑` / `↓` | history search by current prefix |

### Shell Options

| Behaviour | Option |
|-----------|--------|
| Type a directory name to `cd` into it | `AUTOCD` |
| Push old directory onto stack on `cd` | `AUTO_PUSHD` |
| Suggest corrections for mistyped commands | `CORRECT` |
| `#` comments work in interactive shell | `INTERACTIVE_COMMENTS` |

---

## Bash

### Prompt

Same two-line layout as ZSH, same palette:

```
╭─ ~/path  on  branch
╰─ ❯
```

Magenta `❯` on success, red on error. Git branch shown when inside a repo.

### History

- 50,000 entries, persisted to `~/.bash_history`
- Timestamps stored (`HISTTIMEFORMAT`)
- Duplicates and space-prefixed lines ignored (`HISTCONTROL=ignoreboth:erasedups`)
- Appends on exit, syncs between sessions (`history -a; history -n`)

### Shell Options

| Behaviour | Option |
|-----------|--------|
| Type a directory name to `cd` | `autocd` |
| Minor typo correction on `cd` | `cdspell` |
| Typo correction in completion | `dirspell` |
| `**` recursive glob | `globstar` |
| Case-insensitive tab completion | `nocaseglob` |
| Tab cycles through completions | `TAB:menu-complete` |

---

## Shared Aliases

Both shells source the same `aliases.zsh`. Key aliases:

### Navigation

| Alias | Expands to |
|-------|------------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |

### File listing (eza)

| Alias | Output |
|-------|--------|
| `ls` | icons, grouped dirs first |
| `ll` | long list with git status |
| `lt` | tree (2 levels) |
| `lta` | tree (3 levels, including hidden) |

Falls back to standard `ls --color=auto` if eza is not installed.

### cat (bat)

| Alias | Output |
|-------|--------|
| `cat` | `bat --style=plain` |
| `bcat` | `bat` (with line numbers and syntax) |

### Git shortcuts

| Alias | Command |
|-------|---------|
| `gs` | `git status -sb` |
| `gl` | `git log --oneline --graph --decorate --all` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gcm` | `git commit -m` |
| `gp` | `git push` |
| `gpl` | `git pull` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gst` / `gstp` | `git stash` / `git stash pop` |

### System

| Alias | Command |
|-------|---------|
| `top` | `btop` |
| `v` / `vim` | `nvim` |
| `py` | `python3` |
| `pip` | `pip3` |
| `df` / `du` / `free` | human-readable versions |
| `ip` | `ip --color=auto` |
| `cls` | `clear` |
| `reload` | `exec $SHELL` |
| `now` | current datetime |
| `weather` | `curl wttr.in/?format=3` |

### RaBbLE-OS

| Alias | Action |
|-------|--------|
| `rabble` | `cd ~/RaBbLE-OS` |
| `rabble-apply` | `layerctl apply all` |
| `rabble-dots` | `dotctl apply all` |
| `hypr-reload` | `hyprctl reload` |
| `hws` / `hcl` / `hmon` | hyprctl workspaces / clients / monitors |

### DNF

| Alias | Command |
|-------|---------|
| `dnfi` | `sudo dnf install` |
| `dnfr` | `sudo dnf remove` |
| `dnfu` | `sudo dnf upgrade` |
| `dnfs` | `dnf search` |
| `dnfq` | `dnf info` |

### Screenshots (Wayland)

| Alias | Action |
|-------|--------|
| `ss` | region screenshot |
| `ssf` | full screen screenshot |
| `ssw` | active window screenshot |

---

## ZSH Functions

### Directory

| Function | What it does |
|----------|--------------|
| `mkcd <dir>` | `mkdir -p` then `cd` into it |
| `cdl <dir>` | `cd` then `ls` |
| `fcd` | fuzzy `cd` using fzf + fd (all subdirs) |

### Files

| Function | What it does |
|----------|--------------|
| `fe` | fuzzy file open in `$EDITOR` (preview with bat) |
| `extract <archive>` | extract any archive format (tar, zip, gz, xz, zst, 7z, rar…) |
| `bak <file>` | create a timestamped backup: `file.20260423-120000.bak` |

### Process / System

| Function | What it does |
|----------|--------------|
| `fkill` | fuzzy process kill using fzf |
| `serve [port]` | quick HTTP server in current dir (default: 8000) |
| `notify-done <cmd>` | run command, send desktop notification on finish |
| `colors256` | print all 256 terminal colors |

### Git

| Function | What it does |
|----------|--------------|
| `fgco` | fuzzy git branch checkout (fzf, all branches) |
| `fgl` | fuzzy git log with diff preview |
| `fgst` | fuzzy git stash pop |

### Hyprland / Wayland

| Function | What it does |
|----------|--------------|
| `wininfo` | JSON info for the active window (class, title, size, workspace) |
| `wmove <workspace>` | move focused window to workspace |
| `hreload` | reload Hyprland config |
| `qs-reload` | reload or restart Quickshell |

### Development

| Function | What it does |
|----------|--------------|
| `venv [name]` | create and activate a Python venv (default: `.venv`) |

### Notes

| Function | What it does |
|----------|--------------|
| `note <text>` | append a timestamped line to today's `~/notes/YYYY-MM-DD.md` |
| `notes` | view today's notes in `$PAGER` |

### Network

| Function | What it does |
|----------|--------------|
| `portscan [host]` | nmap port scan (default: localhost) |
| `netwatch` | `watch` active connections every second |

---

## Color Environment

Both shells set a consistent color environment derived from the RaBbLE palette:

| Variable | Effect |
|----------|--------|
| `LS_COLORS` | File type colors for `ls`/`eza` — violet dirs, cyan symlinks, magenta executables |
| `BAT_THEME` | `Dracula` (closest built-in approximation of synthwave palette) |
| `FZF_DEFAULT_OPTS` | fzf color theme: void bg, magenta highlights, cyan pointer |
| `LESS_TERMCAP_*` | man page colors: magenta headings, cyan underlines |
| `GREP_COLORS` | grep match highlight in magenta |

The terminal (Kitty) sets the 16-color ANSI palette to the RaBbLE palette directly,
so any tool using standard ANSI colors inherits the theme automatically.

---

## Terminal — Kitty

| Feature | Config |
|---------|--------|
| Font | JetBrainsMono Nerd Font Mono 12pt |
| Background | `#0a0010` at 92% opacity |
| Cursor | magenta, blinking |
| Selection | magenta background |
| Tabs | powerline-style, magenta active |
| Scrollback | 10,000 lines |
| Copy on select | to clipboard |

Kitty live-reloads config on `Ctrl+Shift+F5`.

---

## Launcher — Fuzzel

`Super+Space` opens Fuzzel. Type to search installed applications.

| Feature | Config |
|---------|--------|
| Font | JetBrainsMono Nerd Font Mono 12pt |
| Background | void `#0a0010` at 94% opacity |
| Match highlight | magenta `#ff2d78` |
| Selection | surface `#12132a` with cyan match |
| Border | magenta, 2px, 10px radius |
| Icon theme | Papirus-Dark |
| Terminal apps | opens in Kitty |

Fuzzel reads config fresh on each launch — no reload needed.

---

## Lock Screen — Hyprlock

Activates on:
- 5 minutes of idle (via hypridle)
- Lid close (via logind → before_sleep_cmd)
- Manual: `loginctl lock-session`

Visual design mirrors SDDM: void background, blurred screenshot beneath, magenta
input border, clock overlay.

| State | Color |
|-------|-------|
| Input border | magenta |
| Checking password | cyan |
| Failed | red |
| Caps Lock on | yellow |

---

## Idle / Sleep Chain

Managed by hypridle:

| Timeout | Action |
|---------|--------|
| 5 min idle | lock screen |
| 5.5 min idle | display off (DPMS) |
| 15 min idle | suspend |
| Lid close | suspend immediately (logind) |
| Docked (external display) | lid close does NOT suspend |

On wake: display is restored, hyprlock is already showing.

---

## Environment Variables Set by RaBbLE-OS

| Variable | Value |
|----------|-------|
| `EDITOR` / `VISUAL` | `nvim` |
| `PAGER` | `less` |
| `MANPAGER` | `bat` (ZSH only) |
| `RABBLE_ROOT` | `~/RaBbLE-OS` |
| `XDG_CONFIG_HOME` | `~/.config` |
| `XDG_CACHE_HOME` | `~/.cache` |
| `XDG_DATA_HOME` | `~/.local/share` |
