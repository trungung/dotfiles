# Load antidote plugin manager
source /opt/homebrew/share/antidote/antidote.zsh

# Load plugins listed in ~/.zsh_plugins.txt
antidote load

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"


# zoxide alias  
alias c='z'
alias cd='z'

# eza aliases
alias ls='eza'
alias l='eza -lbF --git'
alias lt='eza --tree --level=2'