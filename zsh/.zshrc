alias c='clear'
alias cat='bat'
alias ls='eza --color=always'
alias grep='rg'
alias vim='nvim'

eval "$(starship init zsh)"

. "$HOME/.cargo/env"

source ~/.xinitrc

[ -f "/home/fulstaph/.ghcup/env" ] && . "/home/fulstaph/.ghcup/env" # ghcup-env
