# ==============================================================================
# Zsh Shell Initialization Settings
# Shared across environments and machines
# ==============================================================================

# ── Core Shell Environments ──────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export EDITOR="${EDITOR:-code --wait}"
export PATH="$HOME/.local/bin:$PATH"

# ── Private Configuration Fallback ────────────────────────────────────────────
# Load local/machine-specific environment variables and sensitive profiles
if [[ -f "$HOME/.zshrc.private" ]]; then
  source "$HOME/.zshrc.private"
fi

# ── Zsh Plugin Manager (Antidote) ─────────────────────────────────────────────
# Locate and source antidote.zsh dynamically across standard macOS/Homebrew paths
for antidote_path in \
  "${HOMEBREW_PREFIX:-}/share/antidote/antidote.zsh" \
  "/opt/homebrew/share/antidote/antidote.zsh" \
  "/usr/local/share/antidote/antidote.zsh"; do
  if [[ -f "$antidote_path" ]]; then
    source "$antidote_path"
    break
  fi
done

if typeset -f antidote >/dev/null 2>&1; then
  [[ -f "$HOME/.zsh_plugins.txt" ]] && antidote load
fi

# ── Zsh Autocomplete Helper Bindings ──────────────────────────────────────────
# Ensure pressing Enter submits the command immediately even when the popup
# autocomplete menu is actively highlighted.
bindkey -M menuselect '^M' .accept-line 2>/dev/null || true

# ── Modern Shell CLI Integrations ─────────────────────────────────────────────
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ── Custom Aliases ────────────────────────────────────────────────────────────
alias lg='lazygit'
alias nv='nvim .'

# Use eza (modern replacement for ls) if installed
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias l='eza -lbF --git'
  alias lt='eza --tree --level=2'
fi

if command -v zoxide >/dev/null 2>&1; then
  alias j='z'
fi

# ── Miscellanous Settings ─────────────────────────────────────────────────────
export HOMEBREW_NO_ENV_HINTS=1

# Prevent slow zsh completions from querying remote servers
zstyle ':completion:*' remote-access no
