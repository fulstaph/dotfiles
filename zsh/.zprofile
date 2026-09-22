# macOS-only login paths. Cross-platform Homebrew setup lives in .zshrc.
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  export PATH="$PATH:$HOME/.docker/bin"
  export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
  export PATH="$HOME/.local/bin:$PATH"
fi
