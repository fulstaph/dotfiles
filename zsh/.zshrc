# ─────────────────────────────────────────────
# ZSH CONFIG
# ─────────────────────────────────────────────

# ── Completion ────────────────────────────────
fpath=(/opt/homebrew/share/zsh-completions ~/.grok/completions/zsh $fpath)
autoload -Uz compinit
# Rebuild completion dump at most once per day
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true

# ── History ───────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS      # skip consecutive dupes
setopt HIST_IGNORE_SPACE     # skip lines starting with space
setopt HIST_FIND_NO_DUPS     # no dupes when searching
setopt SHARE_HISTORY         # share across sessions
setopt EXTENDED_HISTORY      # timestamp + elapsed in history file
setopt INC_APPEND_HISTORY    # append immediately, not on exit

# ── Behaviour ─────────────────────────────────
setopt AUTO_CD               # type a dir name to cd into it
setopt AUTO_PUSHD            # cd pushes to directory stack
setopt PUSHD_IGNORE_DUPS
setopt CORRECT               # suggest corrections for mistyped commands
setopt INTERACTIVE_COMMENTS  # allow # comments in interactive shell
setopt NO_BEEP

# ── Vim mode ──────────────────────────────────
bindkey -v
KEYTIMEOUT=1    # 10 ms ESC lag (default 400 ms is unbearable)

# Restore useful emacs keys in insert mode
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '^Y' yank
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^D' delete-char-or-list
bindkey '^H' backward-delete-char     # Backspace over insert boundary
bindkey '^?' backward-delete-char     # same for terminals that send DEL

# History search works in both modes
bindkey '^[[A' history-search-backward   # ↑
bindkey '^[[B' history-search-forward    # ↓
bindkey -M vicmd 'k' history-search-backward
bindkey -M vicmd 'j' history-search-forward

# Navigation keys (insert mode)
bindkey '^[[H' beginning-of-line         # Home
bindkey '^[[F' end-of-line               # End
bindkey '^[[3~' delete-char              # Del
bindkey '^[^[[C' forward-word            # Alt-→
bindkey '^[^[[D' backward-word           # Alt-←

# v in normal mode → edit command in $EDITOR (like bash's Ctrl-X Ctrl-E)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Cursor shape + Starship vi-mode indicator
_zvm_update() {
  case $KEYMAP in
    vicmd)
      print -n '\e[2 q'                  # block cursor
      export STARSHIP_SHELL_VI_MODE=1    # Starship: use vimcmd_symbol (❮)
      ;;
    viins|main)
      print -n '\e[6 q'                  # beam cursor
      unset STARSHIP_SHELL_VI_MODE       # Starship: back to normal symbol (❯)
      ;;
  esac
  zle reset-prompt                       # redraw prompt immediately
}
zle -N zle-keymap-select _zvm_update
zle-line-init()    { print -n '\e[6 q' }  # beam on new prompt
zle-line-finish()  { print -n '\e[2 q' }  # block while command runs
zle -N zle-line-init
zle -N zle-line-finish

# ── Editors ───────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── Path (deduplicated) ───────────────────────
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/.grok/bin
  $HOME/.opencode/bin
  $HOME/.antigravity-ide/antigravity-ide/bin
  $PNPM_HOME
  "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
  "$HOME/.lmstudio/bin"
  $path
)

# ── Package managers ──────────────────────────
# NVM (lazy-load for faster startup)
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}

# pnpm
export PNPM_HOME="/Users/georgy_bokovikov/Library/pnpm"

# ── Google Cloud SDK ──────────────────────────
[[ -f /opt/homebrew/share/google-cloud-sdk/path.zsh.inc ]] &&
  source /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
[[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ]] &&
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc

# ── Aliases — navigation ──────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'           # go back

# ── Aliases — listing (eza > ls) ─────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first --git'
alias la='eza -lah --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias lta='eza --tree --icons --level=3 -a'

# ── Aliases — editor ──────────────────────────
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# ── Aliases — git ─────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glo='git log --oneline --graph --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gb='git branch'
alias gbd='git branch -d'
alias gst='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias grbi='git rebase -i'

# ── Aliases — misc ────────────────────────────
alias cat='bat --style=plain --paging=never'        # bat is installed
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias df='df -h'
alias du='du -sh'
alias ports='lsof -iTCP -sTCP:LISTEN -P'           # show listening ports
alias path='echo $PATH | tr ":" "\n"'              # readable PATH
alias reload='exec zsh'                             # reload shell
alias zshrc='$EDITOR ~/.zshrc'                     # quick edit

# ── Functions ─────────────────────────────────

# make dir and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# show process using a port
port() { lsof -iTCP:"$1" -sTCP:LISTEN -P }

# fuzzy cd with zoxide + fzf
fcd() {
  local dir
  dir=$(zoxide query -l | fzf --height=40% --reverse --preview 'eza --tree --level=1 --icons {}' 2>/dev/null) && cd "$dir"
}

# fuzzy kill
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --height=40% | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill "${1:--15}"
}

# git fuzzy branch checkout
gcob() {
  local branch
  branch=$(git branch -a | fzf --height=40% --reverse | sed 's/remotes\/origin\///' | tr -d '[:space:]*')
  [[ -n "$branch" ]] && git checkout "$branch"
}

# extract any archive
extract() {
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar)     tar xf  "$1" ;;
    *.bz2)     bunzip2 "$1" ;;
    *.gz)      gunzip  "$1" ;;
    *.zip)     unzip   "$1" ;;
    *.7z)      7z x    "$1" ;;
    *.rar)     unrar x "$1" ;;
    *) echo "Don't know how to extract '$1'" ;;
  esac
}

# quick HTTP server in current dir
serve() { python3 -m http.server "${1:-8000}" }

# ── Plugins ───────────────────────────────────
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# autosuggestion style — re-bind for viins explicitly so bindkey -v doesn't lose it
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
bindkey -M viins '^ ' autosuggest-accept   # Ctrl-Space to accept suggestion
bindkey -M viins '^L' autosuggest-accept   # Ctrl-L also accepts (feel-good fallback)

# ── FZF ───────────────────────────────────────
eval "$(fzf --zsh)"
export FZF_DEFAULT_OPTS="
  --height=50% --layout=reverse --border=rounded
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"
# use fd if available (faster than find)
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ── Zoxide (smart cd) ─────────────────────────
eval "$(zoxide init zsh --cmd cd)"   # replaces cd with smart z

# ── Prompt (Starship) ─────────────────────────
eval "$(starship init zsh)"
