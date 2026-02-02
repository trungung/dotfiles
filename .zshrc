# Load antidote plugin manager
source /opt/homebrew/share/antidote/antidote.zsh

# Load plugins listed in ~/.zsh_plugins.txt
antidote load

if [[ -f "$HOME/.zshrc.private" ]]; then
  source "$HOME/.zshrc.private"
fi

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

alias c='claude'
alias co='copilot'
alias op='opencode'
alias lg='lazygit'

alias cd='z'
alias y='yazi'

alias ls='eza'
alias l='eza -lbF --git'
alias lt='eza --tree --level=2'

export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# OpenCode Azure Settings
export OPENCODE_EXPERIMENTAL_OXFMT=true
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
export EDITOR="code --wait"

# Added by Windsurf
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

dev() {
  local tool="${1:-op}"
  osascript <<EOF
tell application "System Events" to tell process "Ghostty"
  keystroke "${tool}"
  keystroke return
  delay 0.2
  keystroke "d" using {command down}
  delay 0.2
  keystroke "d" using {command down, shift down}
  delay 0.2
  keystroke "lazygit"
  keystroke return
  
  repeat 8 times
    key code 126 using {control down, command down}
  end repeat
end tell
EOF
}