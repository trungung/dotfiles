#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

brew_prefix="$(brew --prefix)"

if pgrep -f "${brew_prefix}/Library/Homebrew/.*/brew.rb" >/dev/null 2>&1; then
  echo "Another Homebrew process is already running." >&2
  echo "Wait for it to finish before running ./install.sh again." >&2
  exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Some Homebrew casks may need sudo to install helper tools."
  echo "Requesting sudo now so brew bundle does not appear to hang later."
  sudo -v -p "Password for sudo: "

  while true; do
    sudo -n true
    sleep 60
  done 2>/dev/null &
  sudo_keepalive_pid=$!
  trap 'kill "$sudo_keepalive_pid" 2>/dev/null || true' EXIT
fi

echo "Tapping HashiCorp Homebrew repository..."
brew tap hashicorp/tap

# Install lock-sensitive tools serially before brew bundle runs the full set.
echo "Installing bootstrap formulae serially..."
brew install \
  go \
  docker \
  stow \
  hashicorp/tap/terraform

echo "Running brew bundle..."
brew bundle --verbose --file Brewfile

echo "Preparing config directories..."
mkdir -p "$HOME/.config/git"

echo "Stowing dotfiles..."
stow --restow --target="$HOME" \
  zsh \
  git \
  nvim \
  ghostty \
  lazygit \
  starship \
  opencode

echo "Dotfiles installed."
echo "Manual follow-up:"
echo "- Install Bitwarden from the App Store, then create ~/.zshrc.private if needed."
echo "- Configure AltTab and its Command-Tab shortcut."
echo "- Configure Raycast and its shortcut."
