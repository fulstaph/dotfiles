bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

# This will install Zinit in ~/.local/share/zinit/zinit.git. 
# .zshrc will be updated with three lines of code that will be added to the bottom. 
# The lines will be sourcing zinit.zsh and setting up completion for command zinit.

source ~/.zshrc

zinit self-update

