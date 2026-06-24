# Shell defaults shared across machines.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export EDITOR="${EDITOR:-code --wait}"
export PATH="$HOME/.local/bin:$PATH"

if [[ -d "$HOME/.local/share/bob/nvim-bin" ]]; then
  export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
fi

if [[ -f "$HOME/.zshrc.private" ]]; then
  source "$HOME/.zshrc.private"
fi

if [[ -f "${HOMEBREW_PREFIX:-}/share/antidote/antidote.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/share/antidote/antidote.zsh"
elif [[ -f /opt/homebrew/share/antidote/antidote.zsh ]]; then
  source /opt/homebrew/share/antidote/antidote.zsh
elif [[ -f /usr/local/share/antidote/antidote.zsh ]]; then
  source /usr/local/share/antidote/antidote.zsh
fi

if typeset -f antidote >/dev/null 2>&1; then
  [[ -f "$HOME/.zsh_plugins.txt" ]] && antidote load
fi

command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

alias lg='lazygit'
alias nv='nvim .'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias l='eza -lbF --git'
  alias lt='eza --tree --level=2'
fi

if command -v zoxide >/dev/null 2>&1; then
  alias j='z'
fi
export HOMEBREW_NO_ENV_HINTS=1
