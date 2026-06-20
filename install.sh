#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew installation finished, but brew is not available in PATH." >&2
  echo "Open a new terminal and run ./install.sh again." >&2
  exit 1
fi

brew bundle --file Brewfile

mkdir -p "$HOME/.config/git"

stow --target="$HOME" \
  zsh \
  git \
  nvim \
  ghostty \
  lazygit \
  starship \
  opencode

echo "Dotfiles installed."
echo "Next: install Bitwarden from the App Store, then create ~/.zshrc.private if needed."
