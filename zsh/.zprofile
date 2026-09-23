# macOS-only login paths. Cross-platform Homebrew setup lives in .zshrc.
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  export PATH="$PATH:$HOME/.docker/bin"
  export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
  export PATH="$HOME/.local/bin:$PATH"

  # NVM default node
  export NVM_DIR="$HOME/.nvm"
  if [[ -d "$NVM_DIR/versions/node" ]]; then
    _nvm_default_version="$(<"$NVM_DIR/alias/default" 2>/dev/null)"
    if [[ -z "$_nvm_default_version" || ! -d "$NVM_DIR/versions/node/$_nvm_default_version/bin" ]]; then
      _nvm_default_version="$(command ls -1 "$NVM_DIR/versions/node" 2>/dev/null | tail -n 1)"
    fi
    if [[ -n "$_nvm_default_version" && -d "$NVM_DIR/versions/node/$_nvm_default_version/bin" ]]; then
      export PATH="$NVM_DIR/versions/node/$_nvm_default_version/bin:$PATH"
    fi
    unset _nvm_default_version
  fi
fi
