alias c='clear'
alias cat='bat'
alias ls='eza --color=always'
alias grep='rg'
alias vim='nvim'

export EDITOR=nvim
export GOPATH=$HOME/go
export PATH=/home/fulstaph/.local/bin/:$PATH
export BB_LOGIN=g.bokovikov
export BB_TOKEN=BBDC-MDY0NTI3NjA3MDc2Opo7z78YEBElmhm3dNFPuYn07v8u
export GITLAB_LOGIN=g.bokovikov
export GITLAB_TOKEN=glpat-mzhc5fBz8fGw17c9fodr

eval "$(starship init zsh)"

. "$HOME/.cargo/env"

[ -f "/home/fulstaph/.ghcup/env" ] && . "/home/fulstaph/.ghcup/env" # ghcup-env
