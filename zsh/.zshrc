# ─────────────────────────────────────────────
# ZSH CONFIG — platform: macOS + Linux
# ─────────────────────────────────────────────

# ── Platform detection ────────────────────────
case "$OSTYPE" in
  darwin*) OS=mac ;;
  linux*)  OS=linux ;;
  *)       OS=unknown ;;
esac

# Homebrew prefix — resolved once at startup, never shelled out again
# Linux brew lives in /home/linuxbrew or ~/.linuxbrew
BREW=""
if [[ $OS == mac ]]; then
  if   [[ -x /opt/homebrew/bin/brew ]];  then BREW=/opt/homebrew   # Apple Silicon
  elif [[ -x /usr/local/bin/brew ]];     then BREW=/usr/local       # Intel
  fi
elif [[ $OS == linux ]]; then
  if   [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then BREW=/home/linuxbrew/.linuxbrew
  elif [[ -x $HOME/.linuxbrew/bin/brew ]];            then BREW=$HOME/.linuxbrew
  fi
fi
[[ -n $BREW ]] && eval "$($BREW/bin/brew shellenv)" 2>/dev/null

# ── Completion ────────────────────────────────
fpath=(
  ${BREW:+$BREW/share/zsh-completions}
  ${BREW:+$BREW/share/zsh/site-functions}
  ~/.grok/completions/zsh(N/)
  $fpath
)
autoload -Uz compinit
# Rebuild completion dump at most once per day
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true

# ── History ───────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY

# ── Behaviour ─────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt INTERACTIVE_COMMENTS
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
bindkey '^H' backward-delete-char
bindkey '^?' backward-delete-char

# History search in both modes
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey -M vicmd 'k' history-search-backward
bindkey -M vicmd 'j' history-search-forward

# Navigation keys
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[^[[C' forward-word
bindkey '^[^[[D' backward-word

# v in normal mode → edit command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Cursor shape in vi mode (Starship handles prompt redraw and vi symbols natively)
_zvm_update() {
  case $KEYMAP in
    vicmd)      print -n '\e[2 q' ;;  # block
    viins|main) print -n '\e[6 q' ;;  # beam
  esac
}
zle -N zle-keymap-select _zvm_update
zle-line-init()   { print -n '\e[6 q' }
zle-line-finish() { print -n '\e[2 q' }
zle -N zle-line-init
zle -N zle-line-finish

# ── Editors ───────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim

# ── XDG base dirs (Linux standard; set explicitly so macOS tools honour them too) ──
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ── Path ──────────────────────────────────────
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/.grok/bin
  $HOME/.opencode/bin
  ${BREW:+$BREW/bin}
  $path
)

# macOS-only path entries
if [[ $OS == mac ]]; then
  path=(
    $HOME/.antigravity-ide/antigravity-ide/bin
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    $HOME/.lmstudio/bin
    $path
  )
fi

# ── pnpm ──────────────────────────────────────
if [[ $OS == mac ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$XDG_DATA_HOME/pnpm"
fi
path=($PNPM_HOME $path)

# ── NVM (lazy-load) ───────────────────────────
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm
  local nvm_sh
  if [[ $OS == mac && -n $BREW ]]; then
    nvm_sh="$BREW/opt/nvm/nvm.sh"
  else
    nvm_sh="$NVM_DIR/nvm.sh"   # Linux: installed by nvm install script
  fi
  [[ -s $nvm_sh ]] && source "$nvm_sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# ── Google Cloud SDK ──────────────────────────
_gcloud_inc() {
  local base
  if [[ $OS == mac && -n $BREW ]]; then
    base="$BREW/share/google-cloud-sdk"
  else
    base="${CLOUDSDK_ROOT_DIR:-$HOME/.local/share/google-cloud-sdk}"
  fi
  [[ -f "$base/path.zsh.inc" ]]        && source "$base/path.zsh.inc"
  [[ -f "$base/completion.zsh.inc" ]]  && source "$base/completion.zsh.inc"
}
_gcloud_inc
unfunction _gcloud_inc

# ── Aliases — navigation ──────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ── Aliases — listing (eza) ───────────────────
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
if command -v bat &>/dev/null; then
  alias cat='bat --style=plain --paging=never'
fi
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias df='df -h'
alias du='du -sh'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec zsh'
alias zshrc='$EDITOR ~/.zshrc'

# platform-appropriate open
if [[ $OS == mac ]]; then
  alias open='open'
else
  alias open='xdg-open'
fi

# listening ports
if [[ $OS == mac ]]; then
  alias ports='lsof -iTCP -sTCP:LISTEN -P'
else
  alias ports='ss -tlnp'
fi

# ── Functions ─────────────────────────────────

mkcd() { mkdir -p "$1" && cd "$1" }

port() {
  if [[ $OS == mac ]]; then
    lsof -iTCP:"$1" -sTCP:LISTEN -P
  else
    ss -tlnp "sport = :$1"
  fi
}

fcd() {
  local dir
  dir=$(zoxide query -l | fzf --height=40% --reverse --preview 'eza --tree --level=1 --icons {}' 2>/dev/null) && cd "$dir"
}

fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --height=40% | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill "${1:--15}"
}

gcob() {
  local branch
  branch=$(git branch -a | fzf --height=40% --reverse | sed 's/remotes\/origin\///' | tr -d '[:space:]*')
  [[ -n "$branch" ]] && git checkout "$branch"
}

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

serve() { python3 -m http.server "${1:-8000}" }

# ── Plugins ───────────────────────────────────
_source_plugin() {
  local name="$1"
  # Homebrew (macOS)
  if [[ -n $BREW && -f "$BREW/share/$name/$name.zsh" ]]; then
    source "$BREW/share/$name/$name.zsh"
    return
  fi
  # apt/dnf path (Linux)
  local linux_path="/usr/share/$name/$name.zsh"
  [[ -f $linux_path ]] && source "$linux_path" && return
  # fallback: ~/.zsh/<name>
  [[ -f "$HOME/.zsh/$name/$name.zsh" ]] && source "$HOME/.zsh/$name/$name.zsh"
}
_source_plugin zsh-autosuggestions
_source_plugin zsh-syntax-highlighting
unfunction _source_plugin

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
bindkey -M viins '^ ' autosuggest-accept
bindkey -M viins '^L' autosuggest-accept

# ── FZF ───────────────────────────────────────
# fzf --zsh requires ≥0.48; older distro packages use manual sourcing
if (( $+commands[fzf] )) && fzf --zsh &>/dev/null; then
  eval "$(fzf --zsh)"
else
  # Fallback: source shell integration files from common install locations
  local _fzf_base
  for _fzf_base in \
    "${BREW:+$BREW/opt/fzf}" \
    "$HOME/.fzf" \
    /usr/share/doc/fzf/examples \
    /usr/share/fzf; do
    [[ -z "$_fzf_base" ]] && continue
    [[ -f "$_fzf_base/shell/key-bindings.zsh" ]] && source "$_fzf_base/shell/key-bindings.zsh"
    [[ -f "$_fzf_base/shell/completion.zsh"   ]] && source "$_fzf_base/shell/completion.zsh"
    [[ -f "$_fzf_base/key-bindings.zsh"       ]] && source "$_fzf_base/key-bindings.zsh"
    [[ -f "$_fzf_base/completion.zsh"         ]] && source "$_fzf_base/completion.zsh"
  done
  unset _fzf_base
fi
export FZF_DEFAULT_OPTS="
  --height=50% --layout=reverse --border=rounded
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ── Zoxide ────────────────────────────────────
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ── Prompt (Starship) ─────────────────────────
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi
