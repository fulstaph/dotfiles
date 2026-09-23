[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# NVM default node (available to all zsh invocations)
if [[ -d "$HOME/.nvm/versions/node" ]]; then
  _nvm_default_version="$(<"$HOME/.nvm/alias/default" 2>/dev/null)"
  if [[ -z "$_nvm_default_version" || ! -d "$HOME/.nvm/versions/node/$_nvm_default_version/bin" ]]; then
    _nvm_default_version="$(command ls -1 "$HOME/.nvm/versions/node" 2>/dev/null | tail -n 1)"
  fi
  if [[ -n "$_nvm_default_version" && -d "$HOME/.nvm/versions/node/$_nvm_default_version/bin" ]]; then
    export PATH="$HOME/.nvm/versions/node/$_nvm_default_version/bin:$PATH"
  fi
  unset _nvm_default_version
fi
