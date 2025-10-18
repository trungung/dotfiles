# Load antidote plugin manager
source /opt/homebrew/share/antidote/antidote.zsh

# Load plugins listed in ~/.zsh_plugins.txt
antidote load

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# zoxide alias  
alias c='z'

# eza aliases
alias ls='eza'
alias l='eza -lbF --git'
alias ll='eza -lbGF --git'
alias llm='eza -lbGd --git --sort=modified'
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale'
alias lS='eza -1'
alias lt='eza --tree --level=2'
alias l.="eza -a | grep -E '^\.'"