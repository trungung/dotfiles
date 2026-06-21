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

# Enable trackpad tap-to-click.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable auto-capitalization.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable double-space period insertion.
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable spelling autocorrect.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable smart text substitutions and inline predictions.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticTextReplacementEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticTextReplacementEnabled -bool false

# Do not move windows aside when clicking the wallpaper.
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Store screenshots in ~/Screenshots.
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Apply changed settings.
killall cfprefsd 2>/dev/null || true
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
