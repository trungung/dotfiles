#!/usr/bin/env bash
set -euo pipefail

# macOS quality-of-life defaults. Run manually after reviewing.

# Hide Dock unless hovered.
defaults write com.apple.dock autohide -bool true

# Hide recent apps in Dock.
defaults write com.apple.dock show-recents -bool false

# Keep Spaces in manual order.
defaults write com.apple.dock mru-spaces -bool false

# Show Finder path bar.
defaults write com.apple.finder ShowPathbar -bool true

# Show file extensions globally.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Use Finder column view by default.
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Search current folder by default in Finder.
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable auto-capitalization.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable double-space period insertion.
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable spelling autocorrect.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Store screenshots in ~/Screenshots.
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Apply changed settings.
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
