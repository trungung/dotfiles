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

# Terraform is currently disabled.
# brew tap hashicorp/tap

# Install lock-sensitive tools serially before brew bundle runs the full set.
echo "Installing bootstrap formulae serially..."
brew install \
  go \
  docker \
  stow
# brew install hashicorp/tap/terraform

echo "Running brew bundle..."
brew bundle --verbose --file Brewfile

echo "Preparing config directories..."
mkdir -p "$HOME/.config/git"
mkdir -p "$HOME/.pi/agent"

echo "Migrating Pi configuration..."
PI_TRACKED_DIR="$(cd "$(dirname "$0")" && pwd)/pi/.pi/agent"
if [ -d "$HOME/.pi/agent" ] && [ ! -L "$HOME/.pi/agent/settings.json" ]; then
  echo "  Backing up local-only Pi files..."
  PI_BACKUP="$(mktemp -d)"
  for f in auth.json trust.json; do
    [ -f "$HOME/.pi/agent/$f" ] && cp -a "$HOME/.pi/agent/$f" "$PI_BACKUP/" 2>/dev/null || true
  done
  for d in sessions npm; do
    [ -d "$HOME/.pi/agent/$d" ] && cp -a "$HOME/.pi/agent/$d" "$PI_BACKUP/" 2>/dev/null || true
  done
  # Remove existing tracked files so stow can symlink cleanly over them
  for f in settings.json themes/gruvbox.json; do
    [ -f "$HOME/.pi/agent/$f" ] && rm "$HOME/.pi/agent/$f" 2>/dev/null || true
  done
  for f in "$PI_TRACKED_DIR"/prompts/*.md; do
    [ -f "$HOME/.pi/agent/prompts/$(basename "$f")" ] && rm "$HOME/.pi/agent/prompts/$(basename "$f")" 2>/dev/null || true
  done
  echo "  Pi backup saved to $PI_BACKUP"
fi

echo "Stowing dotfiles..."
stow --restow --target="$HOME" \
  zsh \
  git \
  nvim \
  ghostty \
  lazygit \
  starship \
  opencode \
  pi

# Restore local-only Pi files after stow creates symlinks
if [ -n "${PI_BACKUP:-}" ] && [ -d "$PI_BACKUP" ]; then
  echo "  Restoring local-only Pi files..."
  for f in auth.json trust.json; do
    [ -f "$PI_BACKUP/$f" ] && cp -a "$PI_BACKUP/$f" "$HOME/.pi/agent/" 2>/dev/null || true
  done
  for d in sessions npm; do
    [ -d "$PI_BACKUP/$d" ] && cp -a "$PI_BACKUP/$d" "$HOME/.pi/agent/" 2>/dev/null || true
  done
  rm -rf "$PI_BACKUP"
  echo "  Pi migration complete."
fi

echo "Linking Firefox chrome..."
./scripts/firefox.sh

echo "Dotfiles installed."
echo "Manual follow-up: see README.md for local-only config, app sign-ins, and sanity checks."
